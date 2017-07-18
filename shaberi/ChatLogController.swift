//
//  ChatLogController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId: String = "cellId"
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.sourceController = self
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        return view
    }()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var inputContainerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ConversationCell
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        
        setupConversation(for: cell, message: message)
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrame(for: message.text!).width + 32
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputContainerView.inputTextField.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrame(for: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    func handleSendMessage() {
        guard let messageText = inputContainerView.inputTextField.text,
            let toId = user?.id,
            let fromId = FIRAuth.auth()?.currentUser?.uid
        else { return }
        
        let timestamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        
        let ref = FIRDatabase.database().reference().child(Models.messages)
        let childRef = ref.childByAutoId()
        let values = ["text": messageText, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]

        childRef.updateChildValues(values) { (error, reference) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid,
            let toId = user?.id
        else { return }
        
        let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child(Models.messages).child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let message = Message()
                
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func setupCollectionView(){
        let contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = contentInset
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ConversationCell.self, forCellWithReuseIdentifier: cellId)

    }
    
    private func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func setupConversation(for cell: ConversationCell, message: Message) {
        if let profileImgUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCache(withUrl: profileImgUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            // outgoing message
            cell.bubbleView.backgroundColor = Colors.OUTGOING_MESSAGE
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            // in commning message
            cell.bubbleView.backgroundColor = Colors.INCOMMING_MESSAGE
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
}
