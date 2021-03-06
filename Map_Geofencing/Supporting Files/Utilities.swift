//
//  Utilities.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 1/4/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIViewController {
    
    func showAlertWithError(title: String, error: Error) {
        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Activity Indicator related codes below refers to the solution from
    // https://coderwall.com/p/su1t1a/ios-customized-activity-indicator-with-swift
    
    func showActivityIndicator(view: UIView) {
        
        let container: UIView = UIView()
        let loadingView: UIView = UIView()
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        var loadingLabel = UILabel()
        
        container.frame = view.frame
        container.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        container.backgroundColor = UIColor.whiteBackground
        container.tag = 1
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        loadingView.backgroundColor = UIColor.grayBackground
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: 30)
        activityIndicator.tag = 2
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 80, height: 15))
        loadingLabel.text = "Loading"
        loadingLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15)!
        loadingLabel.textColor = UIColor.lightGray
        loadingLabel.textAlignment = .center
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(view: UIView) {

        let container = view.viewWithTag(1)
        let acvitityIndicator = view.viewWithTag(2) as? UIActivityIndicatorView
        acvitityIndicator?.stopAnimating()
        container?.removeFromSuperview()
    }
}

extension UIView {
    
    
    
}

//  // The notification related codes below refers to the solution from
// https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url

extension UNNotificationAttachment {
    
    static func create(identifier: String, imageData: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)

            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
