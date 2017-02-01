//
//  ViewController.swift
//  VideoCallKitQuickStart
//
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit

import TwilioVideo
import CallKit
import PusherSwift

class ViewController: UIViewController {

    // MARK: View Controller Members
    
    // Configure access token manually for testing, if desired! Create one manually in the console
    // at https://www.twilio.com/user/account/video/dev-tools/testing-tools
    var _accessToken = ""
//        var _accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzdhMDA0MTgwODQ3MDM1Mjk5ZTA2ODk2ZDY5MWFiZWMxLTE0ODU5MjUwNzUiLCJpc3MiOiJTSzdhMDA0MTgwODQ3MDM1Mjk5ZTA2ODk2ZDY5MWFiZWMxIiwic3ViIjoiQUM0OGI1YWE0OGMyNzdmOTE2YTVkNjIxYmU4Y2NhMjcxZiIsImV4cCI6MTQ4NTkyODY3NSwiZ3JhbnRzIjp7ImlkZW50aXR5Ijoib25lb25lIiwicnRjIjp7ImNvbmZpZ3VyYXRpb25fcHJvZmlsZV9zaWQiOiJWUzVkMDI2MDQxNzNmZWVhYzM0MTIyOTIxZjQzNDc4N2JkIn19fQ.cyMsiZSHckOcvQobduRso5wwnLbA03XWAMiSvNNdCtI"
//    var _accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzdhMDA0MTgwODQ3MDM1Mjk5ZTA2ODk2ZDY5MWFiZWMxLTE0ODU5MDA3NjIiLCJpc3MiOiJTSzdhMDA0MTgwODQ3MDM1Mjk5ZTA2ODk2ZDY5MWFiZWMxIiwic3ViIjoiQUM0OGI1YWE0OGMyNzdmOTE2YTVkNjIxYmU4Y2NhMjcxZiIsImV4cCI6MTQ4NTkwNDM2MiwiZ3JhbnRzIjp7ImlkZW50aXR5Ijoib25lIiwicnRjIjp7ImNvbmZpZ3VyYXRpb25fcHJvZmlsZV9zaWQiOiJWUzVkMDI2MDQxNzNmZWVhYzM0MTIyOTIxZjQzNDc4N2JkIn19fQ.Eh6EcZaG1SJPF3T5tLtZHuJj2Pce10GpmRC3v8RdgRM"
    var accessToken:String {
        get {
//            print(_accessToken)
            return _accessToken
        }
        set {
            _accessToken = newValue
            client = nil
        }
    }
    var callList:[Call] = [] // List of all rooms of calls received
    
    // Configure remote URL to fetch token from
    var tokenUrl = "http://localhost:8000/token.php"
    
    // Video SDK components
    var client: TVIVideoClient?
    var room: TVIRoom?
    var localMedia: TVILocalMedia?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?

    // CallKit components
    let callKitProvider:CXProvider
    let callKitCallController:CXCallController
    var callKitCompletionHandler: ((Bool)->Swift.Void?)? = nil

    // MARK: UI Element Outlets and handles
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var simulateIncomingButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet var roomLines: [UIView]!
    @IBOutlet var roomLabels: [UILabel]!
    @IBOutlet weak var micButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        let configuration = CXProviderConfiguration(localizedName: "CallKit Quickstart")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportsVideo = true
        if let callKitIcon = UIImage(named: "iconMask80") {
            configuration.iconTemplateImageData = UIImagePNGRepresentation(callKitIcon)
        }

        callKitProvider = CXProvider(configuration: configuration)
        callKitCallController = CXCallController()

        super.init(coder: aDecoder)

        callKitProvider.setDelegate(self, queue: nil)
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LocalMedia represents the collection of tracks that we are sending to other Participants from our VideoClient.
        localMedia = TVILocalMedia()
        
        if PlatformUtils.isSimulator {
            self.previewView.removeFromSuperview()
        } else {
            // Preview our local camera track in the local video preview view.
            self.startPreview()
        }
        
        // Disconnect and mic button will be displayed when the Client is connected to a Room.
        self.disconnectButton.isHidden = true
        self.micButton.isHidden = true
        
        self.roomTextField.delegate = self
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
        
        if let token = UserDefaults.standard.value(forKey: "token") as? String {
            tokenTextField.text = token
            accessToken = token
        }
        
        if let userId = UserDefaults.standard.value(forKey: "userId") as? String {
            userIdTextField.text = userId
            PusherManager.shared.userId = userId
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didRecieveCall(_:)), name: NSNotification.Name(rawValue: "call"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didReceiveHangUp(_:)), name: NSNotification.Name(rawValue: "hangup"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func didRecieveCall(_ notification:Notification) {
        guard let info = notification.userInfo as? [String : Any],
            let call = Call(userInfo: info) else {return}
        
        // Add the room name to the list of calls
        self.callList.append(call)
        
        self.reportIncomingCall(uuid: call.uuid, roomName: call.roomId) { _ in
            //
        }
    }
    
    func didReceiveHangUp(_ notification:Notification) {
        AlertHelper.showAlert(title: "User declined call", controller: self)
        disconnect(sender: self)
    }

    @IBAction func disconnect(sender: AnyObject) {
        if let room = room, let uuid = room.uuid {
            logMessage(messageText: "Attempting to disconnect from room \(room.name)")
            performEndCallAction(uuid: uuid)
        }
    }
    
    @IBAction func toggleMic(sender: AnyObject) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            // Update the button title
            if (self.localAudioTrack?.isEnabled == true) {
                self.micButton.setTitle("Mute", for: .normal)
            } else {
                self.micButton.setTitle("Unmute", for: .normal)
            }
        }
    }

    // MARK: Private
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }

        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer()
        localVideoTrack = localMedia?.addVideoTrack(true, capturer: camera!)
        if (localVideoTrack == nil) {
            logMessage(messageText: "Failed to add video track")
        } else {
            // Attach view to video track for local preview
            localVideoTrack!.attach(self.previewView)

            logMessage(messageText: "Video track added to localMedia")

            // We will flip camera on tap.
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }

    func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }

    func prepareLocalMedia() {

        // We will offer local audio and video when we connect to room.

        // Adding local audio track to localMedia
        if (localAudioTrack == nil) {
            localAudioTrack = localMedia?.addAudioTrack(true)
        }

        // Adding local video track to localMedia and starting local preview if it is not already started.
        if (localMedia?.videoTracks.count == 0) {
            self.startPreview()
        }
    }

    // Update our UI based upon if we are in a Room or not
    func showRoomUI(inRoom: Bool) {
        self.simulateIncomingButton.isHidden = inRoom
        self.simulateIncomingButton.isHidden = inRoom
        self.simulateIncomingButton.isHidden = inRoom
        self.simulateIncomingButton.isHidden = inRoom
        self.roomTextField.isHidden = inRoom
        roomLines.forEach({$0.isHidden = inRoom})
        roomLabels.forEach({$0.isHidden = inRoom})
        userIdTextField.isHidden = inRoom
        tokenTextField.isHidden = inRoom
        self.micButton.isHidden = !inRoom
        self.disconnectButton.isHidden = !inRoom
        UIApplication.shared.isIdleTimerDisabled = inRoom
    }
    
    func dismissKeyboard() {
        if (self.roomTextField.isFirstResponder) {
            self.roomTextField.resignFirstResponder()
        }
    }
    
    func cleanupRemoteParticipant() {
        if ((self.participant) != nil) {
            if ((self.participant?.media.videoTracks.count)! > 0) {
                self.participant?.media.videoTracks[0].detach(self.remoteView)
            }
        }
        self.participant = nil
    }
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        messageLabel.text = messageText
    }

    func holdCall(onHold: Bool) {
        localAudioTrack?.isEnabled = !onHold
        localVideoTrack?.isEnabled = !onHold
    }
}

// MARK: UITextFieldDelegate
extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userIdTextField, let userId = textField.text {
            PusherManager.shared.userId = userId
            UserDefaults.standard.set(userId, forKey: "userId")
        } else if textField == tokenTextField, let token = textField.text {
            UserDefaults.standard.set(token, forKey: "token")
            accessToken = token
        }
        textField.resignFirstResponder()
        return false
    }
}

// MARK: TVIRoomDelegate
extension ViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity)")
        
        if (room.participants.count > 0) {
            self.participant = room.participants[0]
            self.participant?.delegate = self
        }
        
        if let callObject = callList.filter({$0.roomId == room.name}).first {
            callObject.timeStarted = Date()
        }

        let cxObserver = callKitCallController.callObserver
        let calls = cxObserver.calls

        // Let the call provider know that the outgoing call has connected
        if let uuid = room.uuid, let call = calls.first(where:{$0.uuid == uuid}) {
            if call.isOutgoing {
                callKitProvider.reportOutgoingCall(with: uuid, connectedAt: nil)
            }
        }
        
        self.callKitCompletionHandler!(true)
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        logMessage(messageText: "Disconncted from room \(room.name), error = \(error)")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        self.showRoomUI(inRoom: false)
        self.callKitCompletionHandler = nil
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        logMessage(messageText: "Failed to connect to room with error: \(error.localizedDescription)")

        self.callKitCompletionHandler!(false)
        self.room = nil
        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        if (self.participant == nil) {
            self.participant = participant
            self.participant?.delegate = self
        }
       logMessage(messageText: "Room \(room.name), Participant \(participant.identity) connected")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
        if (self.participant == participant) {
            cleanupRemoteParticipant()
            // End call
            disconnect(sender: self)
        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIParticipantDelegate
extension ViewController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
        logMessage(messageText: "Participant \(participant.identity) added video track")

        if (self.participant == participant) {
            videoTrack.attach(self.remoteView)
        }
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
        logMessage(messageText: "Participant \(participant.identity) removed video track")

        if (self.participant == participant) {
            videoTrack.detach(self.remoteView)
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
        logMessage(messageText: "Participant \(participant.identity) added audio track")

    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
        logMessage(messageText: "Participant \(participant.identity) removed audio track")
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        logMessage(messageText: "Participant \(participant.identity) enabled \(type) track")
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        logMessage(messageText: "Participant \(participant.identity) disabled \(type) track")
    }
}
