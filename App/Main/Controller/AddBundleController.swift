//
//  AddBundleController.swift
//  iptv-pro
//  Created by YPY Global on 8/14/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class AddBundleController: YPYRootViewController {
    
    @IBOutlet weak var tfBundleName: AutoFillTextField!
    @IBOutlet weak var tfBundleUrl: AutoFillTextField!
    @IBOutlet weak var btnAdd: AutoFillButton!
    @IBOutlet weak var actionBarConstraint: NSLayoutConstraint!
    
    var databaseMng = DatabaseManager.shared
    
    override func setUpUI() {
        super.setUpUI()
        self.tfBundleName.delegate = self
        self.tfBundleUrl.delegate = self
        
        self.tfBundleUrl.placeholder = getString(StringRes.info_hint_bundle_uri)
        self.tfBundleName.placeholder = getString(StringRes.info_hint_bundle_name)
        self.tfBundleUrl.placeholderColor(color: getColor(hex: ColorRes.main_second_text_color))
        self.tfBundleName.placeholderColor(color: getColor(hex: ColorRes.main_second_text_color))
        
        self.registerTapOutSideRecognizer()
    }
    
    override func updateCustomizeViewConstraint() {
        self.actionBarConstraint.constant = getDimen(DimenRes.action_bar_sizes)
    }
    
    @IBAction func closeTap(_ sender: Any) {
        self.unregisterTapOutSideRecognizer()
        if self.backStack() {
            return
        }
    }
    
    @IBAction func addTap(_ sender: Any) {
        self.hideVirtualKeyboard()
        let name = (self.tfBundleName.text ?? "").trimmingCharacters(in: .whitespaces)
        let url = (self.tfBundleUrl.text ?? "").trimmingCharacters(in: .whitespaces)
        let format = getString(StringRes.format_empty_field)
        if url.isEmpty {
            self.showToast(with: String(format: format, getString(StringRes.title_bundle_url)))
            return
        }
        if !StringUtils.checkUrl(url){
            self.showToast(withResId: StringRes.info_invalid_url)
            return
        }
        let fileExtention = (url as NSString).pathExtension
        let lastPath = (url as NSString).lastPathComponent
        if !lastPath.elementsEqual(url) && !fileExtention.lowercased().elementsEqual("m3u") {
            self.showToast(withResId: StringRes.info_invalid_url_m3u)
            return
        }
        let nameBundle = !name.isEmpty ? name : url.fileName()
        let isM3u = !lastPath.elementsEqual(url) && fileExtention.lowercased().elementsEqual("m3u")
        if !ApplicationUtils.isOnline() {
            self.showToast(withResId: StringRes.info_lose_internet)
            return
        }
        self.showProgress()
        DispatchQueue.global().async {
            let oldBundle = self.databaseMng.appDatabase?.bundleDAO?.getBundleWithUri(url)
            if oldBundle != nil {
                self.onBundleAlreadyExisted()
                return
            }
            let bundle = BundleModel(nameBundle,url)
            bundle.isM3u = isM3u ? 1 : 0
            var rowId: Int64 = 0
            if isM3u {
                let listModels = IPTVNetUtils.getListM3UModels(url)
                let size = listModels?.count ?? -1
                if size > 0 {
                    rowId = self.databaseMng.insertBundle(bundle)
                    if rowId > 0 {
                        for m3u in listModels! {
                            m3u.bundleId = rowId
                            YPYLog.logE("===>group=\(m3u.group)====>name=\(m3u.name)")
                            m3u.id = self.databaseMng.insertM3uModel(m3u)
                        }
                    }
                }
                self.onFinishAddBundle(rowId)
            }
            else{
                IPTVNetUtils.getIptvApp(url) { (result) in
                    if let first = result?.getFirstModel() as? BundleModel {
                        first.uri = url
                        first.name = nameBundle
                        rowId = self.databaseMng.insertBundle(first)
                        SettingManager.saveBundle(first)
                    }
                    YPYLog.logE("====>getIptvApp rowId =\(rowId)")
                    self.onFinishAddBundle(rowId)
                }
            }
        }
        
    }
    
    private func onBundleError(){
        DispatchQueue.main.async {
            self.dismissProgress()
            self.showToast(withResId: StringRes.info_bundle_existed)
        }
    }
    
    private func onBundleAlreadyExisted(){
        DispatchQueue.main.async {
            self.dismissProgress()
            self.showToast(withResId: StringRes.info_bundle_existed)
        }
    }
    
    private func onFinishAddBundle(_ rowId: Int64){
        DispatchQueue.main.async {
            self.dismissProgress()
            self.showToast(withResId: rowId > 0 ? StringRes.info_save_url_success : StringRes.info_save_url_error)
            if rowId > 0 {
                self.resetData()
                (self.parentVC as? MainController)?.reloadBundle()
            }
        }
    }
    
    private func resetData(){
        self.tfBundleUrl.text = ""
        self.tfBundleName.text = ""
    }

}

extension AddBundleController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           if(textField == self.tfBundleUrl){
            self.tfBundleName.becomeFirstResponder()
        }
        else if(textField == self.tfBundleName){
            textField.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
}
