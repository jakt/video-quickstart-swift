//
//  Call.swift
//  VideoCallKitQuickStart
//
//  Created by Jay Chmilewski on 2/1/17.
//  Copyright © 2017 Twilio. All rights reserved.
//

import Foundation

public class Call {
    let roomId:String
    let uuid:UUID
    let receiverName:String
    let senderName:String
    
    let rawInfo:[String:Any]
    
    var timeStarted:Date?
    var isOwn:Bool {
        let ownId = PusherManager.shared.userId
        return ownId == senderName
    }
    
    init?(userInfo:[String:Any]) {
        guard let roomId = userInfo["roomId"] as? String,
            let uuidString = userInfo["uuid"] as? String,
            let uuid = UUID(uuidString: uuidString),
            let senderName = userInfo["sender"] as? String,
            let receiverName = userInfo["receiver"] as? String else {
                return nil
        }
        
        self.rawInfo = userInfo
        self.roomId = roomId
        self.uuid = uuid
        self.senderName = senderName
        self.receiverName = receiverName
    }
}
