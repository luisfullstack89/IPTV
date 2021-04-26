//
//  CyberFMRootViewController.swift
//  Created by Cyber FM on 3/7/19.
//  Copyright © 2019 Cyber FM. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Toast_Swift
import AFNetworking

protocol NetworkDelegate {
    func onNetworkState(_ isConnect: Bool)
}

class YPYRootViewController: UIViewController {
    
    private var progressBar:JGProgressHUD?
    private var isAddObserver = false
    private var isAddObserverForeBack = false
    private var networkDelegate: NetworkDelegate?
    let deviceName = Display.deviceName
    private var tapOutSide : UITapGestureRecognizer?
    
    //set parent view controller
    var parentVC: YPYRootViewController?
    
    var keyword: String?
    var isChildInContainer: Bool = false
    
    class func create() -> YPYRootViewController {
        let mainStoryboard = UIStoryboard(name: IYPYConstants.STORYBOARD_MAIN, bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! YPYRootViewController
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        ToastManager.shared.isQueueEnabled = true
        ToastManager.shared.isTapToDismissEnabled = false
        self.setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.updateCustomizeViewConstraint()
    }

    
    func updateCustomizeViewConstraint() {
        
    }
    
    func registerObserverBackForeGround(){
        if !self.isAddObserverForeBack {
            self.isAddObserverForeBack = true
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    func unregisterObserverBackForeGround(){
        if self.isAddObserverForeBack {
            self.isAddObserverForeBack = false
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    @objc private func appMovedToBackground() {
        YPYLog.logD("app enters background")
        onMoveToBackground()
    }
    func onMoveToBackground(){
    
    }
    
    @objc private func appCameToForeground() {
        YPYLog.logD("app go back foreground")
        onMoveToForeground()
    }
    
    func onMoveToForeground(){
        
    }
    
    func setUpUI() {
        
    }
   
    func showProgress() {
        showProgress(getString(StringRes.info_loading))
    }
    
    func showProgress(_ msg: String) {
        if self.progressBar == nil {
            self.progressBar = JGProgressHUD(style: .dark)
            self.progressBar?.interactionType = .blockAllTouches
        }
        if self.progressBar != nil && !msg.isEmpty && !self.progressBar!.isVisible {
            self.progressBar!.textLabel.text = msg
            self.progressBar!.show(in: self.view)
        }
    }
    
    func dismissProgress() {
        if self.progressBar != nil  && self.progressBar!.isVisible {
            self.progressBar!.dismiss()
        }
    }
    
    func showToast(withResId msgId: String){
        showToast(with: getString(msgId))
    }
    
    func showToast(with msg: String){
        self.view.makeToast(msg, duration: 2.0, position: .bottom)
    }
    
    func registerObserverNetworkChange (networkDelegate: NetworkDelegate? = nil)  {
        if !isAddObserver {
            isAddObserver = true
            NotificationCenter.default.addObserver(self, selector: #selector(onNetworkChanged(notification:)), name: NSNotification.Name(rawValue: IYPYConstants.BROADCAST_NETWORK_CHANGE), object: nil)
            self.networkDelegate = networkDelegate
        }
    }
    
    @objc func onNetworkChanged (notification:Notification) -> Void {
        guard let isConnect: Bool = notification.userInfo![IYPYConstants.KEY_IS_CONNECT] as? Bool else {
            AFNetworkReachabilityManager.shared().startMonitoring()
            return
        }
        if networkDelegate != nil {
            self.networkDelegate!.onNetworkState(isConnect)
        }
        
    }
    
    func processLeftRight() {
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft{
            onUpdateUIWhenSupportRTL()
        }
    }
    func onUpdateUIWhenSupportRTL() {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func isCheapDevice() -> Bool {
        return deviceName == .iphone4  || deviceName == .iphone5 || deviceName == .iphone6
    }

    func registerTapOutSideRecognizer() {
        self.tapOutSide = UITapGestureRecognizer(target: self, action: #selector(checkHideVirtualKeyboard))
        self.view.addGestureRecognizer(tapOutSide!)
    }
    
    func unregisterTapOutSideRecognizer(){
        if let gesture = self.tapOutSide {
            self.view.removeGestureRecognizer(gesture)
        }
        self.view.endEditing(true)
    }
    
    @objc private func checkHideVirtualKeyboard(){
        self.hideVirtualKeyboard()
    }
    
    func hideVirtualKeyboard(){
        if self.tapOutSide != nil {
            self.view.endEditing(true)
        }
    }
    
    func justHideKeyboard() {
        self.view.endEditing(true)
        self.unregisterTapOutSideRecognizer()
    }
    
    func backStack(completion: (() -> Void)? = nil, fromChildVC: Bool? = false) -> Bool {
        let fromChild = fromChildVC ?? false
        if fromChild {
            return false
        }
        if isChildInContainer {
            self.view.removeFromSuperview()
            self.dismiss(animated: true, completion: completion)
        }
        else{
            self.dismissDetail()
        }
        return true
    }
    
    func addViewControllerToRootView(controller : UIViewController, rootLayout: UIView){
        if controller is YPYRootViewController {
            let rootVC = controller as! YPYRootViewController
            rootVC.isChildInContainer = true
            rootVC.parentVC = self
        }
        controller.view.frame = CGRect(x: 0, y: 0, width: rootLayout.bounds.width, height: rootLayout.bounds.height)
        self.addChild(controller)
        rootLayout.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func getTopChildController() -> UIViewController? {
        let listVC = self.children
        if listVC.count > 0 {
            return listVC[listVC.count-1]
        }
        return nil
    }
    
    func shareModel(_ model: AbstractModel, _ appId: String,_ pivotView: UIView? = nil){
        let strShare = model.getShareStr()
        if strShare != nil && !strShare!.isEmpty {
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            self.shareContent(strShare,appId, isPad ? pivotView: nil)
        }
    }
    
    func resetSearch() {
        if self.isSearching() {
            self.keyword = nil
        }
    }
    
    func updateKeywordSearch(_ keyword: String) {
        self.keyword = keyword
    }
    
    func startSearch (_ keyword: String, _ isClose: Bool){
        if !keyword.isEmpty || isClose {
            self.keyword = keyword
        }
    }
    
    func isSearching() -> Bool {
        return keyword != nil && !keyword!.isEmpty
    }
    
 
}
