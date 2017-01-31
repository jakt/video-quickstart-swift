//
//  ViewController+SimulateIncomingCall.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit

// MARK: Simulate Incoming Call
extension ViewController {
    
    @IBAction func simulateIncomingCall(sender: AnyObject) {
        
        if accessToken == "TWILIO_ACCESS_TOKEN" {
            // prompt user to input new token
            EntryManager.presentEntry(fieldName: "Token", viewController: self, completion: { (result) in
                EntryManager.presentEntry(fieldName: "User ID", viewController: self, completion: { (userId) in
                    guard let userId = userId else {return}
                    PusherManager.shared.sendMessage(type: PusherManager.MessageType.call, userId: userId)
                    self.performStartCallAction(uuid: UUID.init(), roomName: "Goji-room")
                })
            })
        } else {
            EntryManager.presentEntry(fieldName: "User ID of receiver", viewController: self, completion: { (userId) in
                guard let userId = userId else {return}
                PusherManager.shared.sendMessage(type: PusherManager.MessageType.call, userId: userId)
                self.performStartCallAction(uuid: UUID.init(), roomName: "Goji-room")
            })
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
