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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupInputComponents()
    }
    
    func setupNavigationBar() {
        navigationController?.title = "Chat"
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
        print(312)
        guard let messageText = inputContainerView.inputTextField.text else { return }
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text": messageText, "name": "Minae"]
        
        childRef.updateChildValues(values)
    }
}
