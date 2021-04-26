//
//  ParentViewController.swift
//  Created by YPY Global on 4/10/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import Kingfisher

class ParentViewController: YPYRootViewController {
    
    @IBOutlet weak var imgBackground: UIImageView?
    
    //Config Ads view
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var counting :Int = 0
    
    var totalDataMng = TotalDataManager.shared
    
    override func setUpUI() {
        super.setUpUI()
        self.onDoWhenDone()
    }
    func onDoWhenDone() {
        if ApplicationUtils.isOnline() {
            self.onDoWhenNetworkOn()
        }
        self.registerObserverNetworkChange(networkDelegate: self)
    }
    
    
    func onDoWhenNetworkOn() {
        
    }
    
    func onDoWhenNetworkOff() {
        
    }

    func onInterstitialAdClose() {
        
    }
    
    func resetAds(){
        self.bannerHeight.constant = 0
        self.containerView.layoutIfNeeded()
    }
  
    func addControllerOnRootView(controller : UIViewController, rootLayout: UIView){
        controller.view.frame = CGRect(x: 0, y: 0, width: rootLayout.bounds.width, height: rootLayout.bounds.height)
        self.addChild(controller)
        rootLayout.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    

    func onProcessExtraMenuItem(_ id: Int){
        
    }
    
}

extension ParentViewController: NetworkDelegate{
    func onNetworkState(_ isConnect: Bool) {
        if isConnect {
            onDoWhenNetworkOn()
        }
        else {
            onDoWhenNetworkOff()
        }
    }
}


