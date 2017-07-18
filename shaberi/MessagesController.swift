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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        checkIfUserIsLoggedIn()
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleCreateNewMessage))
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
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarTitle(withUser: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarTitle(withUser user: User) {
        let titleView: NavigationBar = {
            let view = NavigationBar()
            view.sourceController = self
            
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
    
    func handleShowChatLogController() {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        
        navigationController?.pushViewController(chatLogController, animated: true)
    }

}

