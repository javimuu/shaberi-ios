//
//  LoginController.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/06.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
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
            
            let ref = FIRDatabase.database().reference(fromURL: "https://shaberi-a249e.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            })
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
            
            self.dismiss(animated: true, completion: nil)
        })
    }
}
