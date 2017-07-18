//
//  Message.swift
//  shaberi
//
//  Created by muu van duy on 2017/02/07.
//  Copyright © 2017 muuvanduy. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    
    func getChatPartnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
