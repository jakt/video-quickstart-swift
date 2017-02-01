//
//  ViewController+SimulateIncomingCall.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit

// MARK: Simulate Incoming Call
extension ViewController {
    
    @IBAction func performOutgoingCall(sender: AnyObject) {
        if let userId = userIdTextField.text, userId.characters.count > 0 {
            if accessToken.characters.count > 0 {
                if let receiverId = roomTextField.text, receiverId.characters.count > 0 {
                    // Successful. Create call object and start call
                    
                    let roomId = "GOJI: "+userId
                    let uuid = UUID.init()
                    let info = ["roomId":roomId, "uuid":uuid.uuidString, "sender":userId, "receiver":receiverId]
                    let newCall = Call(userInfo: info)!
                    self.callList.append(newCall)
                    PusherManager.shared.sendMessage(type: PusherManager.MessageType.call, callObject: newCall)
                    self.performStartCallAction(uuid: UUID.init(), roomName: roomId)
                } else {
                    AlertHelper.showAlert(title: "Please enter the ID of a user to call", controller: self)
                }
            } else {
                AlertHelper.showAlert(title: "Please enter your twilio token before making a call", controller: self)
            }
        } else {
            AlertHelper.showAlert(title: "Please enter your own ID before making a call", controller: self)
        }
    }
//    
//    func presentPopup() {
//        let alertController = UIAlertController(title: "Simulate Incoming Call", message: nil, preferredStyle: .alert)
//        
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
//            
//            let roomNameTextField = alertController.textFields![0] as UITextField
//            let delayTextField = alertController.textFields![1] as UITextField
//            
//            let roomName = roomNameTextField.text
//            self.roomTextField.text = roomName
//            
//            var delay = 5.0
//            if let delayString = delayTextField.text, let delayFromString = Double(delayString) {
//                delay = delayFromString
//            }
//            
//            self.logMessage(messageText: "Simulating Incoming Call for room: \(roomName) after a \(delay) second delay")
//            
//            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + delay) {
//                self.reportIncomingCall(uuid: UUID(), roomName: self.roomTextField.text) { _ in
//                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//                }
//            }
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            (action : UIAlertAction!) -> Void in
//        })
//        
//        alertController.addTextField  { (textField : UITextField!) -> Void in
//            textField.placeholder = "Room Name"
//        }
//        
//        alertController.addTextField  { (textField : UITextField!) -> Void in
//            textField.placeholder = "Delay in seconds (defaults is 5)"
//        }
//        
//        alertController.addAction(okAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
//    }
}
