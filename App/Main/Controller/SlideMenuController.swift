//
//  SlideMenuController.swift
//  RadioApp
//
//  Created by Do Trung Bao on 2/3/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class SlideMenuController: YPYRootViewController {
    
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
        
    @IBOutlet weak var lblRateUs: UILabel!
    @IBOutlet weak var lblTellAfriend: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblContactUs: UILabel!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    @IBOutlet weak var lblTos: UILabel!
    
    @IBOutlet weak var imgTellAfriend: UIImageView!
    @IBOutlet weak var imgWebsite: UIImageView!
    
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var imgPrivacy: UIImageView!
    @IBOutlet weak var imgTos: UIImageView!
    
    @IBOutlet weak var btnWebsite: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var btnTos: UIView!
    @IBOutlet weak var btnPrivacy: UIView!
    
    var delegate : ItemIdDelegate?
    
    override func setUpUI() {
        super.setUpUI()
        self.lblAppName.text = getString(StringRes.app_name)
        self.lblVersion.text = String.init(format: getString(StringRes.format_version), ApplicationUtils.getAppVersion())
    }

    @IBAction func rateUsTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_RATE_US)
    }
    
    
    @IBAction func tellAFriendTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_TELL_A_FRIEND)
    }
   
    
    @IBAction func websiteTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_VISIT_WEBSITE)
    }
    
    @IBAction func contactUsTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_CONTACT_US)
    }
    
    @IBAction func privacyTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_PRIVACY_POLICY)
    }
    
    @IBAction func tosTap(_ sender: Any) {
        self.selectedItem(IPTVConstants.ID_TERM_OF_USE)
    }
    
    private func selectedItem(_ id: Int) {
       self.dismiss(animated: true, completion: {
           if self.delegate != nil {
               self.delegate?.onItemIdClick(id)
           }
       })
    }

}
