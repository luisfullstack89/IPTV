//
//  BundleCell.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/14/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit
protocol MenuBundleDelegate {
    func showMenu(_ view: UIView, _ bundle: BundleModel)
}
class BundleCell : UICollectionViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var rootImg: UIView!
    
    var bundle: BundleModel?
    var menuDelegate: MenuBundleDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblInfo.isHidden = true
    }
    
    func updateUI(_ bundle: BundleModel) {
        self.bundle = bundle
        self.lblName.text = self.bundle?.name
        self.lblInfo.text = self.bundle?.uri
        let imgName = bundle.isM3u == 1 ? ImageRes.ic_m3u_36dp : ImageRes.ic_bundle_36dp
        self.imgIcon.image = UIImage(named: imgName)
        self.rootImg.backgroundColor = getColor(hex: bundle.isM3u == 1 ? ColorRes.bg_m3u_color : ColorRes.bg_bundle_color)
    }
    
    @IBAction func menuTap(_ sender: Any) {
        if self.bundle != nil {
            self.menuDelegate?.showMenu(self.btnMenu, self.bundle!)
        }
    }
}
