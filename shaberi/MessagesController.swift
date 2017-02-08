//
//  MessagesController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/06.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId: String = "cellId"
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        checkIfUserIsLoggedIn()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.item]
        
        guard let chatPartnerId = message.getChatPartnerId() else { return }
        
        let ref = FIRDatabase.database().reference().child(Models.users).child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User()
            
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            
            self.handleShowChatLogController(for: user)
            
        }, withCancel: nil)
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleCreateNewMessage))
    }
    
    func setupTableView() {
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: cellId)
    }
    
    func observerUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child(Models.user_messages).child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(uid).child(userId)
            
            userMessagesRef.observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessage(withMessageId: messageId)
            
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserLoggedIn()
        }
    }
    
    func fetchUserLoggedIn() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child(Models.users).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarTitle(withUser: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarTitle(withUser user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observerUserMessages()
        
        let titleView: NavigationBar = {
            let view = NavigationBar()
            
            return view
        }()
        
        if let profileImageUrl = user.profileImageUrl {
            titleView.profileImageView.loadImageUsingCache(withUrl: profileImageUrl)
        }
        
        if let name = user.name {
            titleView.nameLabel.text = name
        }
        self.navigationItem.titleView = titleView
    }
    
    func handleCreateNewMessage() {
        let createNewMessageController = CreateNewMessageController()
        createNewMessageController.messageController = self
        let navigationController = UINavigationController(rootViewController: createNewMessageController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        let loginController = LoginController()
        
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func handleShowChatLogController(for user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    private func fetchMessage(withMessageId messageId: String) {
        let messageReference = FIRDatabase.database().reference().child(Models.messages).child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)

                if let chatPartnerId = message.getChatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
}

