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
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?
    
    func getChatPartnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
    }
}
