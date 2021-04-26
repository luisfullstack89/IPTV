//
//  ShareActionUtils.swift
//  Created by YPY Global on 2/19/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

open class ShareActionUtils {
    
    static let FORMAT_SHARE_APP_URL = "itms-apps://itunes.apple.com/app/%@"
    static let FORMAT_URL_LINK_APP = "https://itunes.apple.com/app/id%@"

    public static func goToURL(linkUrl: String) {
        if !linkUrl.isEmpty {
            if let url = URL(string: linkUrl), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    public static func rateMe(appId: String) {
        let rateUrl = String.init(format: FORMAT_SHARE_APP_URL, appId)
        goToURL(linkUrl: rateUrl)
    }
    
}

extension UIViewController : MFMailComposeViewControllerDelegate {
    
    public func shareViaEmail (recipients : [String]?, subject :
        String?, body : String?, _ isHtml : Bool = false){
        if recipients != nil {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(recipients!)
            if subject != nil && !(subject?.isEmpty)! {
                mailComposerVC.setSubject(subject!)
            }
            if body != nil && !(body?.isEmpty)! {
                mailComposerVC.setMessageBody(body!, isHTML: isHtml)
            }
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC,animated: true, completion: nil)
            }
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        switch (result) {
        case .cancelled:
            self.dismiss(animated: true, completion: nil)
        case .sent:
            self.dismiss(animated: true, completion: nil)
        case .failed:
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
    public func shareContent(_ msg: String?, _ appId: String, _ pivotView: UIView? = nil){
        if msg != nil && !msg!.isEmpty {
            let shareContent = msg! + "\n" + String.init(format: ShareActionUtils.FORMAT_URL_LINK_APP, appId)
            var objectToShare = [String]()
            objectToShare.append(shareContent)
            let activityViewController = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
            if pivotView != nil {
                activityViewController.popoverPresentationController?.sourceView = pivotView!
            }
            else{
                activityViewController.popoverPresentationController?.sourceView = self.view
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    public func copyToClipboard (withContent content: String?){
        if content != nil && !content!.isEmpty {
            let pasteboard = UIPasteboard.general
            pasteboard.string = content
        }
    }
}
