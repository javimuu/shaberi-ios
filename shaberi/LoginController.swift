//
//  LoginController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/06.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messageController: MessagesController?
    
    lazy var loginForm: LoginForm = {
        let lf = LoginForm()
        lf.translatesAutoresizingMaskIntoConstraints = false
        lf.sourceController = self
        
        return lf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.rgb(red: 61, green: 91, blue: 151)

        setupViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    
    func setupViews() {
        view.addSubview(loginForm)
        
        loginForm.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginForm.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginForm.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        loginForm.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func handleSelectProfileImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]  as? UIImage {
            selectedImageFromPicker = editedImage
        
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            loginForm.profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() throws {
        guard let email = loginForm.emailTextField.text,
            let password = loginForm.passwordTextField.text,
            let name = loginForm.nameTextField.text
        else {
            throw AuthenticationError.invalid("Invalid email or password")
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else { return }
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.loginForm.profileImageView.image,
                let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadatsa, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadatsa?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabase(withUid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    func handleLogin() throws {
        guard let email = loginForm.emailTextField.text,
            let password = loginForm.passwordTextField.text
        else {
            throw AuthenticationError.invalid("Invalid email or password")
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            self.messageController?.fetchUserLoggedIn()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func registerUserIntoDatabase(withUid uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://shaberi-a249e.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
            let user = User()
            user.setValuesForKeys(values)
            self.messageController?.setupNavBarTitle(withUser: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
}
