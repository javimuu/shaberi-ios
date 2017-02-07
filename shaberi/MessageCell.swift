//
//  MessageCell.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UserCell {
    
    var message: Message? {
        didSet {
            
            setupProfileInfo()
            
            if let seconds =  message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm a"
                
                timeLabel.text = dateFormater.string(from: timestampDate as Date)
            }
            
            detailTextLabel?.text = message?.text
        }
    }
    
    let timeLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .darkGray
        lb.font = UIFont.systemFont(ofSize: 12)
        
        return lb
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(timeLabel)
        
        // set timeLabel  constraints
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    private func setupProfileInfo() {
        let chatPartnerId: String?
        
        if message?.fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerId  = message?.toId
        } else {
            chatPartnerId  = message?.fromId
        }
        
        if let id = chatPartnerId {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCache(withUrl: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
}

