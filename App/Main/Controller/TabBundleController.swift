//
//  PlaylistController.swift
//  NewAppRadio
//
//  Created by Do Trung Bao on 7/9/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import Sheeeeeeeeet

class TabBundleController: BaseCollectionController {

    override func setUpUI() {
        self.isAllowAddObserver = false
        super.setUpUI()
    }
    
    override func getUIType() -> UIType {
        return .FlatList
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: BundleCell.self)
    }
    
    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        let database = DatabaseManager.shared
        let listModel = database.appDatabase?.bundleDAO.getListModels(BundleModel.self) ?? []
        let result = self.convertListModelToResult(listModel)
        completion(result)
    }
    
    override func renderModel(cell: UICollectionViewCell, model: JsonModel) {
        let item = model as! BundleModel
        let cell = cell as! BundleCell
        cell.menuDelegate = self
        cell.updateUI(item)
    }
    
}
extension TabBundleController: MenuBundleDelegate {
    
    func showMenu(_ view: UIView, _ bundle: BundleModel) {
        var items:[MenuItem] = []
        let menuTitle = MenuTitle(title: getString(StringRes.title_options))
        items.append(menuTitle)
        
        if bundle.isM3u == 1 {
            self.addMenuItem(&items,IPTVConstants.ID_MENU_RELOAD_BUNDLE,StringRes.title_reload_bundle)
        }
        self.addMenuItem(&items,IPTVConstants.ID_MENU_SHARE,StringRes.title_share_bundle)
        self.addMenuItem(&items,IPTVConstants.ID_MENU_DELETE,StringRes.title_delete_bundle)
        
        let menu = Menu(items: items)
        let sheet = menu.toActionSheet { (sheet, menuItem) in
            if let id = menuItem.value as? Int {
                self.processAction(view, bundle,id)
            }
            
        }
        sheet.present(in: self, from: view)
    }
    
    private func addMenuItem(_ items: inout [MenuItem], _ id: Int,_ resId: String){
        let menuItem = MenuItem(title: getString(resId), value: id)
        items.append(menuItem)
    }
    
    private func processAction(_ view: UIView, _ model: BundleModel, _ id: Int){
        if id == IPTVConstants.ID_MENU_SHARE{
            self.shareModel(model, IPTVConstants.APP_ID,view)
        }
        else if id == IPTVConstants.ID_MENU_DELETE {
            self.showDialogDeleteBundle(model)
        }
        else if id == IPTVConstants.ID_MENU_RELOAD_BUNDLE {
            self.showDialogReloadBundle(model)
        }
    }
    
    func showDialogDeleteBundle(_ bundle: BundleModel) {
        let msg = getString(StringRes.info_confirm_delete_bundle)
        let titleCancel = getString(StringRes.title_cancel)
        let titleDelete = getString(StringRes.title_delete)
        self.showAlertWith(title: getString(StringRes.title_confirm), message: msg, positive: titleDelete, negative: titleCancel, completion: {
            self.onDeleteBundle(bundle)
        })
    }
    
    func onDeleteBundle(_ bundle: BundleModel) {
        self.showProgress()
        DispatchQueue.global().async {
            let database = DatabaseManager.shared
            let rowId = database.appDatabase?.bundleDAO.delete(bundle.id) ?? 0
            if rowId != 0 {
                database.appDatabase?.m3uDAO.deleteAllWithBundleId(bundle.id)
            }
            if bundle.uri == SettingManager.getUrlEnpoint() {
                self.totalDataMng.onResetBundle()
            }
            DispatchQueue.main.async {
                self.dismissProgress()
                if rowId != 0 {
                    self.deleteModel(bundle)
                    self.showToast(withResId: StringRes.info_delete_successfully)
                    if bundle.uri == SettingManager.getUrlEnpoint() && bundle.isM3u == 0 {
                        SettingManager.resetBundle()
                        (self.parentVC as? MainController)?.reloadTabHome()
                        (self.parentVC as? MainController)?.reloadTabFavorite()
                    }
                }
                
            }
        }
    }
    func showDialogReloadBundle(_ bundle: BundleModel) {
        let msg = getString(StringRes.info_confirm_reload_bundle)
        let titleCancel = getString(StringRes.title_cancel)
        let titleDelete = getString(StringRes.title_reload)
        self.showAlertWith(title: getString(StringRes.title_confirm), message: msg, positive: titleDelete, negative: titleCancel, completion: {
            self.onReloadBundle(bundle)
        })
    }
    
    func onReloadBundle(_ bundle: BundleModel) {
        if !ApplicationUtils.isOnline() {
            self.showToast(withResId: StringRes.info_lose_internet)
            return
        }
        self.showProgress()
        DispatchQueue.global().async {
            let url = bundle.uri
            let listModels = IPTVNetUtils.getListM3UModels(url)
            let sizeBundle = listModels?.count ?? -1
            if sizeBundle > 0 {
                let databaseMng = DatabaseManager.shared
                //delete the old bundle
                databaseMng.appDatabase?.m3uDAO.deleteAllWithBundleId(bundle.id)
                for m3u in listModels! {
                    m3u.bundleId = bundle.id
                    m3u.id = databaseMng.insertM3uModel(m3u)
                }
            }
            DispatchQueue.main.async {
                self.dismissProgress()
                self.showToast(withResId: sizeBundle > 0 ? StringRes.info_reload_success : StringRes.info_reload_error)
            }
        }
    }
}
