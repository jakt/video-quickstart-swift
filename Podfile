source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/twilio/cocoapod-specs'
platform :ios, '10.0'
use_frameworks!

workspace 'VideoQuickStart'

abstract_target 'TwilioVideo' do
    pod 'TwilioVideo', '1.0.0-beta5'
    pod 'PusherSwift'
    pod 'Socket.IO-Client-Swift'
    
    target 'VideoQuickStart' do
        project 'VideoQuickStart.xcproject'
    end
    
    target 'VideoCallKitQuickStart' do
        project 'VideoCallKitQuickStart.xcproject'
    end
    
    target 'CustomScreenCapturerExample' do
        project 'CustomScreenCapturerExample.xcproject'
    end
end
