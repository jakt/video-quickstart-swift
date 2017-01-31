//
//  AppDelegate.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit
import Intents
import PusherSwift
import SocketIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        let url = URL(string: "")!
//        let config = SocketIOClientConfiguration()
//        let socket = SocketIOClient(socketURL: url, config: config)
//        
//        socket.on("connect") { (data:[Any], ack:SocketAckEmitter) in
//            print("test")
//        }
        
        PusherManager.shared.setupPusher()
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let viewController = window?.rootViewController as? ViewController, let interaction = userActivity.interaction else {
            return false
        }

        var personHandle: INPersonHandle?

        if let startVideoCallIntent = interaction.intent as? INStartVideoCallIntent {
            personHandle = startVideoCallIntent.contacts?[0].personHandle
        } else if let startAudioCallIntent = interaction.intent as? INStartAudioCallIntent {
            personHandle = startAudioCallIntent.contacts?[0].personHandle
        }

        if let personHandle = personHandle {
            viewController.performStartCallAction(uuid: UUID(), roomName: personHandle.value)
        }

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        PusherManager.shared.updateBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        PusherManager.shared.invalidateBackgroundTask()
    }
}

class AuthRequestBuilderOld: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channel: PusherChannel) -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(url: URL(string: "http://localhost:9292/pusher/auth")!)
        request.httpMethod = "POST"
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channel.name)".data(using: String.Encoding.utf8)
        return request
    }
}

class AuthRequestBuilder: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channelName: String) -> URLRequest? {
        var request = URLRequest(url: URL(string: "http://localhost:9292/pusher/auth")!)
        request.httpMethod = "POST"
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: String.Encoding.utf8)
        return request
    }
}
