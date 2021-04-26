//
//  GDPRUtils.swift
//  Created by YPY Global on 2/15/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

//import Foundation
//import PersonalizedAdConsent
//import UIKit
//
//open class GDPRUtils {
//
//    public static func checkGDPR (_ viewController: UIViewController!, _ pubId: String!,_ urlPolicy: String!, _ testId: String?, _ completion : (()->Void)? = nil) {
//        if !pubId.isEmpty {
//            if testId != nil && !testId!.isEmpty {
//                PACConsentInformation.sharedInstance.debugIdentifiers = [testId] as? [String]
//                PACConsentInformation.sharedInstance.debugGeography = PACDebugGeography.EEA
//            }
//            PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
//            forPublisherIdentifiers: [pubId]){(_ error: Error?) -> Void in
//                if let error = error {
//                    YPYLog.logE("======> error GDPR = \(error.localizedDescription)")
//                    completion?()
//
//                }
//                else {
//                    let status = PACConsentInformation.sharedInstance.consentStatus
//                    if status == PACConsentStatus.unknown {
//                        showDialogConsentGDPR(viewController,urlPolicy, completion)
//                    }
//                    else{
//                        completion?()
//                    }
//                }
//            }
//            return
//        }
//        completion?()
//    }
//
//    public static func showDialogConsentGDPR (_ viewController: UIViewController!, _ urlPolicy: String!,_ completion : (()->Void)? = nil) {
//        guard let privacyUrl = URL(string: urlPolicy),
//            let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
//                YPYLog.logE("======>incorrect privacy URL.")
//                return
//        }
//        form.shouldOfferPersonalizedAds = true
//        form.shouldOfferNonPersonalizedAds = true
//        form.load {(_ error: Error?) -> Void in
//            if let error = error {
//                YPYLog.logE("Error loading form: \(error.localizedDescription)")
//                completion?()
//            }
//            else {
//                form.present(from: viewController) { (error, userPrefersAdFree) in
//                    if let error = error {
//                        YPYLog.logE("showDialogConsentGDPR present: \(error.localizedDescription)")
//                    }
//                    else {
//                        let status = PACConsentInformation.sharedInstance.consentStatus
//                        YPYLog.logD("======>consentStatus = \(status.rawValue)")
//                    }
//                    completion?()
//                }
//            }
//        }
//
//    }
//}
