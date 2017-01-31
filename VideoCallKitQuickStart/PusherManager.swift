//
//  PusherManager.swift
//  VideoCallKitQuickStart
//
//  Created by Jay Chmilewski on 1/30/17.
//  Copyright © 2017 Twilio. All rights reserved.
//

import Foundation
import PusherSwift

public class PusherManager {
    public static let shared = PusherManager()
    public var userId:String? {
        didSet {
            guard let userId = userId else {return}
            subscribeToCallInfo(for: "private-" + userId)
        }
    }
    
    private var pusher:Pusher!
    
    public func setupPusher() {
        let pusherClientOptions = PusherClientOptions(authMethod: .inline(secret: "f537471b8e2b1e257bb7"))
        pusher = Pusher(key: "f6977b7e807c8bc84884", options: pusherClientOptions)
        
        //        pusher.delegate = self
        
        pusher.connect()
        
        let _ = pusher.bind({ (message: Any?) in
            if let message = message as? [String: AnyObject] {
                if let eventName = message["event"] as? String, eventName == "pusher:error" {
                    if let data = message["data"] as? [String: AnyObject], let errorMessage = data["message"] as? String {
                        print("Error message: \(errorMessage)")
                    }
                }
            }
        })
    }
    
    // MARK: Background tasks
    private var backgroundTaskIdentifier:UIBackgroundTaskIdentifier?

    func invalidateBackgroundTask() {
        if let identifier = self.backgroundTaskIdentifier { UIApplication.shared.endBackgroundTask(identifier) }
    }
    
    func updateBackgroundTask() {
        invalidateBackgroundTask()
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
    }
    
    // MARK: Subscribe
    
    func subscribeToCallInfo(for channel:String) {
        let chan = pusher.subscribe(channel)
        
        chan.bind(eventName: "client-call", callback: { data in
            print(data)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "call"), object: nil, userInfo: nil)
        })
        
        chan.bind(eventName: "client-hangup", callback: { data in
            print(data)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hangup"), object: nil, userInfo: nil)
        })
        
        chan.bind(eventName: "client-ack", callback: { data in
            print(data)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ack"), object: nil, userInfo: nil)
        })
        
        chan.bind(eventName: "client-test", callback: { data in
            print(data)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "test"), object: nil, userInfo: nil)
        })
    }
    
    public enum MessageType {
        case call
        case hangup
        case ack
        case test
    }
    
    public func sendMessage(type:MessageType, userId:String) {
        // triggers a client event
        let chan = pusher.subscribe("private-" + userId)

        switch type {
        case .call:
            chan.trigger(eventName: "client-call", data: ["test": "some value"])
        case .hangup:
            chan.trigger(eventName: "client-hangup", data: ["test": "some value"])
        case .ack:
            chan.trigger(eventName: "client-ack", data: ["test": "some value"])
        case .test:
            chan.trigger(eventName: "client-test", data: ["test": "some value"])
        }
    }
}

class EntryManager {
    
    static func presentEntry(fieldName:String, viewController:UIViewController, completion:@escaping (String?)->Void) {
        let alertController = UIAlertController(title: "Enter " + fieldName, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
            
            let field = alertController.textFields![0] as UITextField
            
            completion(field.text)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alertController.addTextField  { (textField : UITextField!) -> Void in
            textField.placeholder = fieldName
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
