//
//  YPYRootTabController.swift
//  Created by YPY Global on 9/3/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class YPYRootTabController: YPYRootAdsController {
    
    @IBOutlet weak var tabLayout: Segmentio!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var tabControllers: [UIViewController] = []
    private var tabTitles: [SegmentioItem] = []
    var selectIndex: Int = 0
    private var isFirstTime = false
    
    private var tabType: SegmentioStyle?
    private var tabOptions: SegmentioOptions?
    
    override func setUpUI() {
        super.setUpUI()
        self.tabControllers = prepareControllers()
        self.tabTitles = prepareTabs()
        self.tabType = self.getTabType()
        self.tabOptions = self.getTabOptions()
    }
    
    func getTabType() -> SegmentioStyle {
        return SegmentioStyle.onlyLabel
    }
    
    func getTabOptions() -> SegmentioOptions {
        var imageContentMode = UIView.ContentMode.center
        let segmentioStyle = self.getTabType()
        switch segmentioStyle {
        case .imageBeforeLabel, .imageAfterLabel:
            imageContentMode = .scaleAspectFit
        default:
            break
        }
        var options = SegmentioOptions()
        options.backgroundColor = UIColor.clear
        options.maxVisibleItems = self.tabControllers.count
        options.scrollEnabled = true
        options.imageContentMode = imageContentMode
        options.labelTextAlignment = .center
        options.labelTextNumberOfLines = 1
        options.animationDuration = 0.2
        return options
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isFirstTime {
            self.isFirstTime = true
            self.setUpScrollView()
            self.setUpTab()
        }
    
    }
    
    fileprivate func setUpScrollView() {
        self.scrollView.contentSize = CGSize(
            width: UIScreen.main.bounds.width * CGFloat(tabControllers.count),
            height: containerView.frame.height
        )
        for (index, viewController) in self.tabControllers.enumerated() {
            viewController.view.frame = CGRect(
                x: UIScreen.main.bounds.width * CGFloat(index),
                y: 0,
                width: self.scrollView.frame.width,
                height: scrollView.frame.height
            )
            addChild(viewController)
            self.scrollView.addSubview(viewController.view, options: .useAutoresize)
            viewController.didMove(toParent: self)
        }
        self.scrollView.delegate = self
    }
    
    private func setUpTab(){
        self.tabLayout.setup(
            content: tabTitles,
            style: self.tabType!,
            options: self.tabOptions
        )
        self.tabLayout.selectedSegmentioIndex = self.selectIndex
        self.tabLayout.valueDidChange = { [weak self] _, segmentIndex in
            if segmentIndex >= 0 && segmentIndex < (self?.tabControllers.count)! {
                self?.selectTab(segmentIndex)
            }
        }
        //stupid line code to advoid ugly problem when initting tab layout (It is hidden in storyboard)
        self.tabLayout.isHidden = false
        
        //select the page if it is >0
        if self.selectIndex > 0 {
            self.selectTab(self.selectIndex)
        }
        
    }
    
    func selectTab(_ tabIndex: Int){
        if self.scrollView == nil {
            return
        }
        self.selectIndex = tabIndex
        self.tabLayout.selectedSegmentioIndex = self.selectIndex
        let scrollViewWidth = self.scrollView.frame.width
        let contentOffsetX = scrollViewWidth * CGFloat(tabIndex)
        self.scrollView.setContentOffset(
            CGPoint(x: contentOffsetX, y: 0),
            animated: true
        )
        self.onTabChange()
    }
    
    func onTabChange(){
        
    }
    
    func prepareTabs() -> [SegmentioItem] {
        return [SegmentioItem]()
    }
    
    func prepareControllers() -> [UIViewController]  {
        return [UIViewController]()
    }
  
}
//delegate for scrollview in tab content
extension YPYRootTabController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = floor(scrollView.contentOffset.x / scrollView.frame.width)
        tabLayout.selectedSegmentioIndex = Int(currentPage)
    }

    fileprivate func selectedSegmentioIndex() -> Int {
        return selectIndex
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: 0)
    }
    
    fileprivate func goToControllerAtIndex(_ index: Int) {
        self.tabLayout.selectedSegmentioIndex = index
    }

}
