//
//  ViewControllerExtension.swift
//  Xradio
//
//  Created by YPY Global on 1/26/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//


import Foundation
import UIKit

//show dialog extension
extension UIViewController{
    

    func presentDetail(_ viewControllerToPresent: UIViewController, completion: (() -> Swift.Void)? = nil) {
        self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
    }
    
    func dismissDetail() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertWithResId(titleId: String, messageId: String, positiveId: String? = nil,negativeId: String? = nil , completion: (() -> Void)? = nil, cancel: (() -> Void)? = nil) {
        let title: String = getString(titleId, comment: "")
        let msg: String = getString(messageId, comment: "")
        let positiveBt: String = positiveId != nil && !positiveId!.isEmpty ? getString(positiveId!, comment: ""): ""
         let negativeBt: String = negativeId != nil && !negativeId!.isEmpty ? getString(negativeId!, comment: ""): ""
        return showAlertWith(title: title, message: msg, positive: positiveBt, negative: negativeBt , completion: completion, cancel:cancel)
    }
    
    func showAlertWith(title: String, message: String,  positive: String? = nil,negative: String? = nil,
                       completion: (() -> Void)? = nil, cancel: (() -> Void)? = nil){
        let positiveBt = positive != nil && !positive!.isEmpty ? positive : getString("title_ok")
        let negativeBt = negative != nil && !negative!.isEmpty ? negative : ""
        showFullAlertWith(title: title, message: message, positive: positiveBt!, negavite: negativeBt!, completion: completion, cancel: cancel)
        
    }
    
    func showAndReturnAlertWith(title: String,message: String,  positive: String, negavite: String? = nil, completion: (() -> Void)? = nil, cancel: (() -> Void)? = nil) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: positive, style: .default, handler: { action in
            if completion != nil {
                completion!()
            }
        }))
        if negavite != nil && !negavite!.isEmpty {
            ac.addAction(UIAlertAction(title: negavite, style: .default, handler: { action in
                if cancel != nil {
                    cancel!()
                }
            }))
        }
        self.present(ac, animated: true)
        return ac
    }
    
    func showFullAlertWith(title: String, message: String, positive: String, negavite: String? = nil, completion: (() -> Void)? = nil, cancel: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: positive, style: .default, handler: { action in
            if completion != nil {
                completion!()
            }
        }))
        if negavite != nil && !negavite!.isEmpty {
            ac.addAction(UIAlertAction(title: negavite, style: .default, handler: { action in
                if cancel != nil {
                    cancel!()
                }
            }))
        }
        self.present(ac, animated: true)
    }
}




