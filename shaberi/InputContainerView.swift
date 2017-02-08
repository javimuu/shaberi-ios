//
//  InputContainerView.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit

class InputContainerView: BaseView, UITextFieldDelegate {
    
    var sourceController: ChatLogController?
    
    lazy var uploadImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = #imageLiteral(resourceName: "ic_gallery")
        imgView.contentMode = .scaleAspectFill
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendMessage)))
        btn.isUserInteractionEnabled = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message..."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        
        return tf
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(seperatorLineView)
        addSubview(uploadImageView)
        
        // set uploadImageView constraints
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // set sendButton contraints
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // set inputTextField contraints
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 12).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

        // set seperatorLineView contraints
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }
    
    func handleSendMessage() {
        sourceController?.handleSendMessage()
    }
    
    func handleUploadImage() {
        sourceController?.handleUploadImage()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
