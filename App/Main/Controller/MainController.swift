//
//  MultiRadioController.swift
//  Created by YPY Global on 4/10/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import MediaPlayer
import MarqueeLabel
import NVActivityIndicatorView
import AFNetworking
import SideMenu
import Sheeeeeeeeet
import GoogleCast

protocol ItemIdDelegate {
    func onItemIdClick(_ id: Int)
}

protocol FavoriteDelegate {
    func updateFavorite (_ movie: MovieModel, _ isFav: Bool , _ typeVC: Int)
}

class MainController: YPYRootTabController {
        
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnSlideMenu: UIButton!
    @IBOutlet weak var lblTitleScreen: UILabel!
    @IBOutlet weak var actionBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionBar: UIView!
    @IBOutlet weak var tabConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIStackView!
    
    @IBOutlet weak var btnCast: GCKUICastButton!
    @IBOutlet weak var pivotIpadMenu: UIView!
    
    private var sideMenu: SlideMenuController?
    private var sideMenuNav: SideMenuNavigationController!
    
    let textTabNormalColor = getColor(hex: ColorRes.tab_text_normal_color)
    let textTabFocusColor = getColor(hex: ColorRes.tab_text_focus_color)
    let indicatorTabColor = getColor(hex: ColorRes.tab_indicator_color)
    let indicatorHeight = getDimen(DimenRes.tab_indicator_sizes)
    
    var tabHomeVC: TabHomeController?
    var tabBundleVC: TabBundleController?
    var tabFavoriteVC: TabFavoriteController?
    
    var listClick: [JsonModel]?
    var currentClick: JsonModel?
    var position = 0
    
    @IBOutlet weak var castMiniPlayerView: UIView!
    @IBOutlet weak var castHeightConstraint: NSLayoutConstraint!
    private var castMiniController: GCKUIMiniMediaControlsViewController!
    var castSession: GoogleCastSession?
    
    override func setUpUI() {
        self.initGoogleCast()
        super.setUpUI()
    }
    
    func initGoogleCast() {
        self.castSession = GoogleCastManager.shared.addSession(self, self.btnCast, self)
        self.castMiniController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
        self.castMiniController.delegate = self
        self.addViewControllerToRootView(controller: castMiniController, rootLayout: castMiniPlayerView)
        self.updateControlBarsVisibility()
    }
    
    override func updateCustomizeViewConstraint() {
        self.actionBarConstraint.constant = getDimen(DimenRes.action_bar_sizes)
        self.tabConstraint.constant = getDimen(DimenRes.tab_height_sizes)
        self.headerView.layoutIfNeeded()
    }
    
    override func onDoWhenDone() {
        super.onDoWhenDone()
        self.initSideMenu()
        self.pivotIpadMenu.isHidden = !Display.pad
    }
    
    override func getTabOptions() -> SegmentioOptions {
        var options = super.getTabOptions()
        let fontSize = getDimen(DimenRes.tab_font_sizes)
        let font = UIFont(name: IPTVConstants.FONT_BOLD, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        options.indicatorOptions =  TabBuilder.segmentioIndicatorOptions(indicatorTabColor,indicatorHeight)
        options.horizontalSeparatorOptions =  TabBuilder.segmentioHorizontalSeparatorOptions(UIColor.clear)
        options.verticalSeparatorOptions =  TabBuilder.segmentioVerticalSeparatorOptions(UIColor.clear)
        options.states = TabBuilder.segmentioStates(font,textTabNormalColor,textTabFocusColor)
        return options
    }
    
    private func initSideMenu(){
       self.sideMenu = SlideMenuController.create() as? SlideMenuController
       self.sideMenu?.delegate = self

       self.sideMenuNav = SideMenuNavigationController(rootViewController: self.sideMenu!)
       self.sideMenuNav.menuWidth = self.view.frame.width - DimenRes.padding_right_slide_menu
       self.sideMenuNav.presentationStyle = .menuSlideIn
       self.sideMenuNav.isNavigationBarHidden = true
       SideMenuManager.default.leftMenuNavigationController = self.sideMenuNav
       SideMenuManager.default.addPanGestureToPresent(toView: self.view)
       SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view, forMenu: .left)
       self.sideMenuNav.statusBarEndAlpha = 0
    }
    
    override func prepareTabs() -> [SegmentioItem] {
        var tabs = super.prepareTabs()
        tabs.append(SegmentioItem(title: getString(StringRes.title_tab_home).uppercased(),image: nil))
        tabs.append(SegmentioItem(title: getString(StringRes.title_tab_bundles).uppercased(),image: nil))
        tabs.append(SegmentioItem(title: getString(StringRes.title_tab_favorite).uppercased(),image: nil))
        return tabs
    }
    
    override func prepareControllers() -> [UIViewController] {
        var controllers = super.prepareControllers()
        self.tabHomeVC = TabHomeController.create() as? TabHomeController
        self.tabHomeVC?.itemDelegate = self
        self.tabHomeVC?.itemIdDelegate = self
        self.tabHomeVC?.favDelegate = self
        controllers.append(self.tabHomeVC!)
        
        //setup delegate
        let bundleVC = TabBundleController.create() as! TabBundleController
        bundleVC.typeVC = IPTVConstants.TYPE_VC_BUNDLE
        bundleVC.itemDelegate = self
        bundleVC.isTab = true
        bundleVC.parentVC = self
        controllers.append(bundleVC)
        self.tabBundleVC = bundleVC
        
        let favoriteVC = TabFavoriteController.create() as! TabFavoriteController
        favoriteVC.typeVC = IPTVConstants.TYPE_VC_FAVORITE
        favoriteVC.itemDelegate = self
        favoriteVC.isTab = true
        favoriteVC.isAllowRefresh = false
        favoriteVC.favDelegate = self
        favoriteVC.isOfflineData = true
        controllers.append(favoriteVC)
        self.tabFavoriteVC = favoriteVC
        
        return controllers
    }
    
    override func onTabChange() {
        if let itemVC = self.tabControllers[self.selectIndex] as? BaseCollectionController {
            itemVC.startLoadData()
        }
        if let itemVC = self.tabControllers[self.selectIndex] as? TabHomeController {
            itemVC.startLoadData()
        }
    }
    
    override func onCreateAdsModel() -> AdsModel? {
        let typeAds = SettingManager.getAdsType()
        if typeAds == AdsModel.TYPE_ADS_FB {
            let adsModel = AdsModel(isAllowShow: IPTVConstants.SHOW_ADS, banner: IPTVConstants.FACEBOOK_BANNER_ID, interstitial: IPTVConstants.FACEBOOK_INTERSTITIAL_ID)
            adsModel.addTestId(IPTVConstants.FACEBOOK_TEST_ID)
            adsModel.typeAds = typeAds
            return adsModel
        }
        else{
            let adsModel = AdsModel(isAllowShow: IPTVConstants.SHOW_ADS, banner: IPTVConstants.ADMOB_BANNER_ID, interstitial: IPTVConstants.ADMOB_INTERSTITIAL_ID)
            adsModel.addTestId(IPTVConstants.ADMOB_TEST_ID)
            adsModel.typeAds = typeAds
            return adsModel
        }
    }
    
    func reloadBundle() {
        self.tabBundleVC!.isLoadedData = false
        if self.tabBundleVC != nil && self.selectIndex == self.tabControllers.firstIndex(of: self.tabBundleVC!) {
            self.tabBundleVC!.startLoadData()
        }
        self.reloadTabHome()
    }
    
    func reloadTabHome(){
        self.tabHomeVC?.isLoadedData = false
        if self.tabHomeVC != nil && self.selectIndex == self.tabControllers.firstIndex(of: self.tabHomeVC!) {
            self.tabHomeVC!.startLoadData()
        }
    }
    
    func reloadTabFavorite(){
        self.tabFavoriteVC?.isLoadedData = false
    }
  
    @IBAction func addTap(_ sender: Any) {
        let addBundle = AddBundleController.create() as! AddBundleController
        self.addViewControllerToRootView(controller: addBundle, rootLayout: self.containerView)
    }

    @IBAction func menuTap(_ sender: Any) {
        self.present(self.sideMenuNav, animated: true, completion: nil)
    }
    
    
}

//side navigation item id selected
extension MainController: ItemIdDelegate {
    
    func onItemIdClick(_ id: Int) {
        switch id {
        case IPTVConstants.ID_RATE_US:
            ShareActionUtils.rateMe(appId: IPTVConstants.APP_ID)
            break
        case IPTVConstants.ID_VISIT_WEBSITE:
            goToUrl(getString(StringRes.title_visit_website),IPTVConstants.URL_WEBSITE)
            break
        case IPTVConstants.ID_TELL_A_FRIEND:
            let msg = String.init(format: getString(StringRes.format_share_app), getString(StringRes.app_name))
            self.shareContent(msg,IPTVConstants.APP_ID)
            break
        case IPTVConstants.ID_CONTACT_US:
            let subject = getString(StringRes.title_contact_us) + " iOS - " + getString(StringRes.app_name)
            self.shareViaEmail(recipients: [IPTVConstants.YOUR_CONTACT_EMAIL], subject: subject, body: "")
            break
        case IPTVConstants.ID_PRIVACY_POLICY:
            goToUrl(getString(StringRes.title_privacy_policy),IPTVConstants.URL_PRIVACRY_POLICY)
            break
        case IPTVConstants.ID_TERM_OF_USE:
            goToUrl(getString(StringRes.title_term_of_use),IPTVConstants.URL_TERM_OF_USE)
            break
        case IPTVConstants.ID_MORE_SERIES:
            self.goToSeries()
            break
        case IPTVConstants.ID_MORE_GENRE:
            self.goToGenres()
            break
        case IPTVConstants.ID_MORE_FEATURED:
            self.goToMovies(IPTVConstants.TYPE_VC_FEATURED_MOVIES)
            break
        case IPTVConstants.ID_MORE_NEWEST:
            self.goToMovies(IPTVConstants.TYPE_VC_NEWEST_MOVIES)
            break
        default:
            break
        }
    }

    func goToUrl(_ title: String!, _ url: String!) {
        ShareActionUtils.goToURL(linkUrl: url)
    }
}


extension MainController : AppItemDelegate {
   
    func clickItem(list: [JsonModel], model: JsonModel, position: Int) {
        self.position = position
        self.listClick = list
        self.currentClick = model
        if model is MovieModel || model is EpisodeModel {
            let isM3U = model is MovieModel && (model as! MovieModel).isM3u
            if isM3U {
                if !self.checkShowAds(model) {
                    self.onItemClicked(model)
                }
                return
            }
            self.onItemClicked(model)
            return
        }
        if !self.checkShowAds(model) {
            self.onItemClicked(model)
        }
    }
    
    func onItemClicked(_ model: JsonModel, _ isFromAds: Bool = false){
        if model is BundleModel {
            self.selectBundle(model as! BundleModel)
        }
        else if model is GenreModel {
            let genre = model as! GenreModel
            self.goToMovies(IPTVConstants.TYPE_VC_DETAIL_GENRE,genre.id, genre.name)
        }
        else if model is SeriesModel {
            let series = model as! SeriesModel
            self.goToSeasons(series)
        }
        else if model is SeasonModel {
            let season = model as! SeasonModel
            self.goToEpisodes(season)
        }
        else if model is EpisodeModel {
            let episode = model as! EpisodeModel
            let movie = episode.convertToMovieModel()
            if let link = movie.getLinkModel() {
                self.currentClick = movie
                self.checkResolveLink(movie, link)
            }
        }
        else if model is MovieModel {
            let movie = model as! MovieModel
            if isFromAds {
                self.goToMovie(movie)
                return
            }
            self.showDialogChooseLan(movie)
        }
    }
    
    func isCastConnect() -> Bool {
        return self.castSession?.isConnected() ?? false
    }
    
    func goToMovie(_ movie : MovieModel) {
        if self.isCastConnect() {
            if let mediaInfo = movie.getCastMediaInfo() {
                self.castSession?.selectItem(mediaInfo)
            }
            return
        }
        let playerVC = IPTVVideoPlayerController.create() as! IPTVVideoPlayerController
        playerVC.movieModel = movie
        if movie.isM3u {
            playerVC.listMovies = self.listClick as? [MovieModel]
            playerVC.currentIndex = self.position
        }
        else{
            var list: [MovieModel] = []
            list.append(movie)
            playerVC.listMovies = list
            playerVC.currentIndex = 0
        }
        self.presentDetail(playerVC)
    }
    
    func showDialogChooseLan(_ movie : MovieModel) {
        let linkSize = movie.links?.count ?? 0
        if linkSize == 0 { return }
        let arraysLan = StringRes.arrays_lan_code
        var items:[MenuItem] = []
        let menuTitle = MenuTitle(title: getString(StringRes.title_select_language))
        items.append(menuTitle)
        var index = 0
        for item in movie.links! {
            if item.isLinkPlayOk() || item.isLinkDownloadOk() {
                let menuItem = MenuItem(title: getString(arraysLan[item.lan]!), value: index)
                items.append(menuItem)
            }
            index += 1
        }
        let menu = Menu(items: items)
        let sheet = menu.toActionSheet { (sheet, menuItem) in
            if let index = menuItem.value as? Int {
                let link = movie.links![index]
                self.checkResolveLink(movie, link)
            }
         
        }
        let isPad = Display.pad
        sheet.present(in: self, from: isPad ? self.pivotIpadMenu : self.view)
    }
    
    func checkResolveLink(_ movie: MovieModel, _ link: MovieLinkModel) {
        if link.isNeedDecrypt() {
            self.resolveUrl(movie, link)
            return
        }
        movie.lanSelected = link.lan
        if !self.checkShowAds(movie) {
            self.goToMovie(movie)
        }
    }
    
    func resolveUrl(_ movie: MovieModel, _ link: MovieLinkModel) {
        if !ApplicationUtils.isOnline() {
            self.showToast(withResId: StringRes.info_lose_internet)
            return
        }
        self.showProgress()
        IPTVNetUtils.resolveUrl(link) { (result) in
            self.dismissProgress()
            if let first = result?.getFirstModel() as? MovieLinkModel {
                link.linkPlay = first.linkPlay
                link.linkDownload = first.linkDownload
                movie.lanSelected = link.lan
                if !self.checkShowAds(movie) {
                    self.goToMovie(movie)
                }
                return
            }
            self.showToast(withResId: StringRes.info_server_error)
        }
    }
    
    func selectBundle(_ bundle : BundleModel) {
        if bundle.isM3u == 0 {
            let urlEnpoint = SettingManager.getUrlEnpoint()
            if !urlEnpoint.elementsEqual(bundle.uri){
                SettingManager.saveBundle(bundle)
                self.reloadTabHome()
            }
            if let index =  self.tabControllers.firstIndex(of: self.tabHomeVC!) {
                self.selectTab(index)
            }
        }
        else{
            self.goToMovies(IPTVConstants.TYPE_VC_VIDEO_M3U, 0, bundle.name, bundle)
        }
    }
    
    func goToGenres() {
        let genreVC = GenreController.create() as! GenreController
        genreVC.typeVC = IPTVConstants.TYPE_VC_GENRE
        genreVC.itemDelegate = self
        genreVC.isAllowRefresh = true
        self.addViewControllerToRootView(controller: genreVC, rootLayout: self.containerView)
    }
    
    func goToSeries() {
        let seriesVC = SeriesController.create() as! SeriesController
        seriesVC.typeVC = IPTVConstants.TYPE_VC_SERIES
        seriesVC.itemDelegate = self
        seriesVC.isAllowRefresh = true
        seriesVC.isAllowLoadMore = true
        seriesVC.isReadCacheWhenNoData = true
        seriesVC.maxPage = 0
        self.addViewControllerToRootView(controller: seriesVC, rootLayout: self.containerView)
    }
    
    func goToSeasons(_ series: SeriesModel?) {
        let seasonVC = SeasonController.create() as! SeasonController
        seasonVC.typeVC = IPTVConstants.TYPE_VC_SEASON
        seasonVC.series = series
        seasonVC.itemDelegate = self
        seasonVC.isAllowRefresh = true
        seasonVC.isAllowLoadMore = true
        seasonVC.maxPage = 0
        self.addViewControllerToRootView(controller: seasonVC, rootLayout: self.containerView)
    }
    
    func goToEpisodes(_ season: SeasonModel?) {
        let seasonVC = EpisodeController.create() as! EpisodeController
        seasonVC.typeVC = IPTVConstants.TYPE_VC_EPISODE
        seasonVC.season = season
        seasonVC.itemDelegate = self
        seasonVC.isAllowRefresh = true
        seasonVC.isAllowLoadMore = true
        seasonVC.maxPage = 0
        self.addViewControllerToRootView(controller: seasonVC, rootLayout: self.containerView)
    }
    
    func goToMovies(_ typeVC: Int, _ genreId : Int64 = 0, _ title: String? = nil, _ bundleM3u: BundleModel? = nil) {
        let movieVC = MovieController.create() as! MovieController
        movieVC.typeVC = typeVC
        movieVC.genreId = genreId
        movieVC.bundleM3u = bundleM3u
        movieVC.titleScreen = title
        movieVC.favDelegate = self
        movieVC.itemDelegate = self
        movieVC.isAllowRefresh = true
        movieVC.isAllowLoadMore = true
        movieVC.isReadCacheWhenNoData = (typeVC == IPTVConstants.TYPE_VC_NEWEST_MOVIES
            || typeVC == IPTVConstants.TYPE_VC_FEATURED_MOVIES)
        movieVC.maxPage = 0
        self.addViewControllerToRootView(controller: movieVC, rootLayout: self.containerView)
    }
    
    func checkShowAds(_ model: JsonModel) -> Bool {
        let infoAds = self.getInfoAds(model)
        let freq = infoAds?["freq"] as? Int ?? 0
        if infoAds == nil ||  freq == 0 || !ApplicationUtils.isOnline() {
            return false
        }
        let key = infoAds!["key"] as! String
        var click = SettingManager.getInt(key)
        click += 1
        SettingManager.setInt(key, click)
        let isAdsOk = self.checkShowAdsWithFreq(click, freq)
        if isAdsOk {
            return self.showInterstitialAds()
        }
        return false
    }
    
    func getInfoAds(_ model: JsonModel) -> [String:Any]?{
        if model is BundleModel {
            if (model as! BundleModel).isM3u > 0 {
                return ["key": SettingManager.KEY_BUNDLE_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_BUNDLE_ADS]
            }
        }
        else if model is GenreModel {
            return ["key": SettingManager.KEY_GENRE_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_GENRES_ADS]
        }
        else if model is SeriesModel {
            return ["key": SettingManager.KEY_SERIES_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_SERIES_ADS]
        }
        else if model is SeasonModel {
            return ["key": SettingManager.KEY_SEASON_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_SEASONS_ADS]
        }
        else if model is EpisodeModel {
            return ["key": SettingManager.KEY_EPISODE_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_EPISODES_ADS]
        }
        else if model is MovieModel {
            return ["key": SettingManager.KEY_MOVIE_CLICK, "freq": IPTVConstants.FREQ_INTERSTITIAL_MOVIES_ADS]
        }
        return nil
    }
    
    override func onInterstitialAdClose() {
        super.onInterstitialAdClose()
        if self.currentClick != nil {
            self.onItemClicked(self.currentClick!,true)
        }
    }
    
}
extension MainController : FavoriteDelegate {
    
    func updateFavorite (_ movie: MovieModel, _ isFav: Bool, _ typeVC: Int){
        TotalDataManager.shared.updateFavorite(movie, isFav, { (id, isFav) in
            self.showToast(withResId: isFav ? StringRes.info_added_favorite : StringRes.info_removed_favorite)
            movie.isFavorite = isFav
            let userInfo  = [
                IPTVConstants.KEY_ID: movie.id,
                IPTVConstants.KEY_VC_TYPE:typeVC ,
                IPTVConstants.KEY_IS_M3U:movie.isM3u,
                IPTVConstants.KEY_IS_FAV:isFav] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(IPTVConstants.BROADCAST_DATA_CHANGE), object: nil, userInfo: userInfo)
            self.tabHomeVC?.updateFavorite(movie, isFav)
            
        })
    }
}

extension MainController : CastSessionDelegage {
    
    func onSessionStart(session: GCKSession) {
        
    }
    
    func onSessionResume(session: GCKSession) {
        
    }
    
    func onSessionEnd(session: GCKSession, error: Error?) {
        
    }
    
    func onSessionError(error: Error?) {
        
    }
    
}
extension MainController : GCKUIMiniMediaControlsViewControllerDelegate {
    
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        self.updateControlBarsVisibility()
    }
    
    
    func updateControlBarsVisibility() {
        if self.castMiniController.active {
            self.castHeightConstraint.constant = self.castMiniController.minHeight
        }
        else {
            self.castHeightConstraint.constant = 0
        }
        self.containerView.layoutIfNeeded()
    }

}
