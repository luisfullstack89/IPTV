//
//  ActionBarCollectionController.swift
//  iptv-pro
//  Created by YPY Global on 8/18/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class ActionBarCollectionController: BaseCollectionController {
    
    @IBOutlet weak var actionBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutActionBar: UIView!

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var lblTitleScreen: UILabel!
    @IBOutlet weak var btnSearch: UIButton!

    
    override func updateCustomizeViewConstraint() {
        super.updateCustomizeViewConstraint()
        self.actionBarConstraint.constant = getDimen(DimenRes.action_bar_sizes)
        self.layoutActionBar.layoutIfNeeded()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpSearch()
    }
    
    private func setUpSearch() {
        self.tfSearch.delegate = self
        self.tfSearch.placeholderColor(color: getColor(hex: ColorRes.color_search_place_holder))
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        self.showSearchView(true)
    }
    
    override func hideVirtualKeyboard() {
        super.hideVirtualKeyboard()
        let text = self.tfSearch.text!
        if text.isEmpty{
            self.showSearchView(false)
            self.startSearch("", true)
        }
        self.unregisterTapOutSideRecognizer()
    }
    
    @IBAction func searchChanged(_ sender: Any) {
        let keyword = self.tfSearch.text!
        if !keyword.isEmpty {
            self.startSearch(keyword, false)
        }
    }
    
    @IBAction func backTap(_ sender: Any) {
        if !self.searchView.isHidden {
            self.tfSearch.text = ""
            self.hideVirtualKeyboard()
        }
        else{
            if self.backStack(){
                return
            }
        }
    }
    
    func showSearchView(_ isShow: Bool){
        self.searchView.isHidden = !isShow
        self.btnSearch.isHidden = isShow
        self.lblTitleScreen.isHidden = isShow
        if isShow {
            self.tfSearch.becomeFirstResponder()
            self.registerTapOutSideRecognizer()
        }
    }
    
    override func startSearch(_ keyword: String, _ isClose: Bool) {
        super.startSearch(keyword, isClose)
        self.isLoadedData = false
        self.startLoadData()
    }
}

//delegate for search view
extension ActionBarCollectionController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.hideVirtualKeyboard()
        let keyword = self.tfSearch.text!
        self.startSearch(keyword, false)
        return true
    }
    
}
