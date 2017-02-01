//
//  Helpers.swift
//  RDV
//
//  Created by Jay Chmilewski on 10/7/16.
//  Copyright © 2016 JAKT. All rights reserved.
//

import UIKit

class AppearanceHelper {
    class func enableDarkKeyboard() {
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    class func enableLightKeyboard() {
        UITextField.appearance().keyboardAppearance = .light
    }
    
    class func removeBackButtonTitle () {
        //remove title from back button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -80.0), for: .default)
    }
}

class RoundingHelper {
    class func roundAndBorderImageView(imageView : UIImageView?){
        if let imageView = imageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = true;
            imageView.layer.borderWidth = 2.0;
            imageView.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
    class func roundAndBorderButton(button : UIButton?){
        if let button = button {
            button.layer.cornerRadius = button.frame.size.width / 2
            button.clipsToBounds = true
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
}

// MARK: - Alert helper
class AlertHelper{
    // Show native ios alert
    class func showAlert(title: String, msg: String? = nil, controller: UIViewController) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message:
                msg, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            controller.present(alertController, animated: true, completion: nil)
        })
    }
    
    // Format error msgs
    class func formatErrorMsg(_ error: String) -> String{
        return StringHelper.capitalizedSentence(error) + "."
    }
    
    // alert with handler
    class func showAlertWithHandler(title: String, msg: String? = nil, controller: UIViewController, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message:
            msg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: handler))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // alert with custom handler
    class func showAlertWithCustomButtonHandler(title: String, msg: String? = nil, buttonTitle : String, controller: UIViewController, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message:
            msg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: handler))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - String helper
class StringHelper{
    class func capitalizedSentence(_ string: String) -> String{
        var formatted = string
        formatted.replaceSubrange(formatted.startIndex...formatted.startIndex, with: String(formatted[formatted.startIndex]).capitalized)
        return formatted
    }
    
    // Returns a valid string to represent the time interval since the post was modified. i.e "10 days ago"
    class func timeString(for date:Date) -> String {
        let diff = date.timeIntervalSinceNow
        let dateDifference = abs(diff / 60.0) // minutes
        var timeString = ""
        if Int(dateDifference) >= (60 * 24 * 2) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " days ago"
        } else if Int(dateDifference) >= (60 * 24) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " day ago"
        } else if Int(dateDifference) >= 120 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hrs ago"
        } else if Int(dateDifference) >= 60 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hr ago"
        } else if Int(dateDifference) >= 1 {
            timeString = String(format:"%i", Int(dateDifference)) + " min ago"
        } else {
            timeString = String(format:"%i", Int(dateDifference * 60.0)) + " sec ago"
        }
        return timeString
    }
    
    // Returns a valid string to represent the distance handed in (distance in is in form of FEET). i.e "25 ft away"
    class func distanceString(for distance:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        var distString = ""
        if Int(distance) >= (5280 * 2) {
            distString = numberFormatter.string(from: NSNumber(value: Int(distance / 5280)))! + " miles away"
        } else if Int(distance) >= 5280 {
            distString = numberFormatter.string(from: NSNumber(value: Int(distance / 5280)))! + " mile away"
        } else if Int(distance) >= 100 {
            distString = numberFormatter.string(from: NSNumber(value: Int(100.0 * round(distance / 100.0))))! + " ft away"
        } else {
            distString = "<100 ft away"
        }
        return distString
    }
    
    class func secondsToHoursMinutesSecondsString (seconds : Int) -> String {
        var sec = seconds
        if sec <= 0 { sec = 0 }
        
        let hours = sec / 3600
        let minutes = (sec % 3600) / 60
        let seconds = (sec % 3600) % 60
        
        return String(format:"%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - UIApplication helper extension
extension UIApplication {
    class func returnToRootViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        
        if let nav = base as? UINavigationController {
            returnToRootViewController(base: nav.visibleViewController)
            nav.popToRootViewController(animated: false)
        }
        
        if let presented = base?.presentedViewController {
            returnToRootViewController(base: presented)
            presented.dismiss(animated: false, completion: nil)
        }
        
    }
}

// MARK: - Color helper extension
extension UIColor {
    //    Swift 3.0
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var hexString:String {
        let colorRef = self.cgColor.components
        
        var r, b, g: CGFloat
        
        if colorRef?.count == 2 {
            r = colorRef![0]
            g = colorRef![0]
            b = colorRef![0]
        } else {
            r = colorRef![0]
            g = colorRef![1]
            b = colorRef![2]
        }
        return NSString(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255))) as String
    }
}

// MARK: - Loader helper
class LoaderHelper {
    static let activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
    class func showLoader(inView: UIView, userInteractionEnabled: Bool, style: UIActivityIndicatorViewStyle){
        activityIndicator.center = inView.center
        activityIndicator.activityIndicatorViewStyle = style
        activityIndicator.startAnimating()
        inView.addSubview(activityIndicator)
        inView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    class func hideLoader(inView: UIView){
        DispatchQueue.main.async {
            activityIndicator.removeFromSuperview()
            inView.isUserInteractionEnabled = true
        }
    }
}

// String helper
extension String {
    func toBool() -> Bool? {
        switch self {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            return false
        default:
            return nil
        }
    }
}
