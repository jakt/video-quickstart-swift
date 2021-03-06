//
//  ViewController.swift
//  CustomScreenCapturerExample
//
//  Copyright © 2016 Twilio Inc. All rights reserved.
//

import TwilioVideo
import UIKit
import WebKit

class ViewController : UIViewController {

    var localMedia: TVILocalMedia?
    var remoteRenderer: TVIVideoViewRenderer?
    var screenCapturer: ExampleScreenCapturer?
    var webView: WKWebView?
    var webNavigation: WKNavigation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup a WKWebView, and request Twilio's website
        webView = WKWebView.init(frame: view.frame)
        webView?.navigationDelegate = self
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.allowsBackForwardNavigationGestures = true
        self.view.addSubview(webView!)

        let requestURL: URL = URL(string: "https://twilio.com")!
        let request = URLRequest.init(url: requestURL)
        webNavigation = webView?.load(request)

        setupLocalMedia()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        webView?.frame = self.view.bounds

        // Layout the remote video using frame based techniques. It's also possible to do this using autolayout
        if ((remoteRenderer?.hasVideoData)!) {
            let dimensions = remoteRenderer?.videoFrameDimensions
            let remoteRect = remoteViewSize()
            let aspect = CGSize(width: CGFloat((dimensions?.width)!), height: CGFloat((dimensions?.height)!))
            let padding : CGFloat = 10.0
            let boundedRect = AVMakeRect(aspectRatio: aspect, insideRect: remoteRect).integral
            remoteRenderer?.view.frame = CGRect(x: self.view.bounds.width - boundedRect.width - padding,
                                                y: self.view.bounds.height - boundedRect.height - padding,
                                                width: boundedRect.width,
                                                height: boundedRect.height)
        } else {
            remoteRenderer?.view.frame = CGRect.zero
        }
    }

    func setupLocalMedia() {
        localMedia = TVILocalMedia()

        // Setup screen capturer
        let capturer: ExampleScreenCapturer = ExampleScreenCapturer.init(aView: self.webView!)
        let videoTrack: TVIVideoTrack? = localMedia?.addVideoTrack(true, capturer: capturer)

        if (videoTrack == nil) {
            presentError(message: "Failed to add screen capturer track!")
            return;
        }

        screenCapturer = capturer;

        // Setup rendering
        remoteRenderer = TVIVideoViewRenderer(delegate: self)
        videoTrack?.addRenderer(remoteRenderer!)

        remoteRenderer?.view.isHidden = true
        self.view.addSubview((remoteRenderer?.view)!)
        self.view.setNeedsLayout()
    }

    func presentError( message: String) {
        print(message)
    }

    func remoteViewSize() -> CGRect {
        let traits = self.traitCollection
        let width = traits.horizontalSizeClass == UIUserInterfaceSizeClass.regular ? 188 : 160;
        let height = traits.horizontalSizeClass == UIUserInterfaceSizeClass.regular ? 188 : 120;
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}

// MARK: WKNavigationDelegate
extension ViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView:", webView, "finished navigation:", navigation)

        self.navigationItem.title = webView.title
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let message = String(format: "WebView:", webView, "did fail navigation:", navigation, error as CVarArg)
        presentError(message: message)
    }
}

// MARK: TVIVideoRendererDelegate
extension ViewController : TVIVideoViewRendererDelegate {
    func rendererDidReceiveVideoData(_ renderer: TVIVideoViewRenderer) {
        if (renderer == remoteRenderer) {
            remoteRenderer?.view.isHidden = false
            self.view.setNeedsLayout()
        }
    }

    func renderer(_ renderer: TVIVideoViewRenderer, dimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}
