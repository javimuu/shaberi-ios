//
//  ChatLogController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.sourceController = self
        
        return view
    }()
    
    var user: User? {
        didSet {
            navigationController?.title = user?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupInputComponents()
    }
    
    func setupInputComponents() {
        view.addSubview(inputContainerView)
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // set inputContainerView constraints
        inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
            
            let userMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child(Models.user_messages).child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
}
