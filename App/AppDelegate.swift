//
//  AppDelegate.swift
//  Xradio
//
//  Created by YPY Global on 12/20/18.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseInstanceID
import GoogleMobileAds
import FirebaseMessaging
import UserNotifications
import AFNetworking
import MediaPlayer
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown
    let networkReachabilityChanged = NSNotification.Name(IYPYConstants.BROADCAST_NETWORK_CHANGE)
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        YPYLog.setDebug(IPTVConstants.DEBUG)
        
        if #available(iOS 13, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // init google cast
        GoogleCastManager.shared.initCast(IPTVConstants.CHROME_CAST_ID)
        GoogleCastManager.shared.setCastTintColor(.white)
        
        //init firebase
        self.initFirebase(application)
        
        //turn off badge if it has push
        UIApplication.shared.applicationIconBadgeNumber = 0
  
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        setUpMonitoringNetwork()
        return true
    }
    
    func initFirebase(_ application: UIApplication) {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
    }
    
    func setUpMonitoringNetwork () {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            var isNetworkConnected = false
            switch (status) {
                case .reachableViaWWAN, .reachableViaWiFi:
                    isNetworkConnected = true
                default:
                    isNetworkConnected = false
            }
            YPYLog.logD("=======> setUpMonitoringNetwork =\(isNetworkConnected)")
            if (self.previousNetworkReachabilityStatus != .unknown && status != self.previousNetworkReachabilityStatus) {
                NotificationCenter.default.post(name: self.networkReachabilityChanged, object: nil, userInfo: [
                    IYPYConstants.KEY_IS_CONNECT : isNetworkConnected
                    ])
            }
            self.previousNetworkReachabilityStatus = status
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let childrens = window?.rootViewController?.children {
            if childrens.count > 0{
                let className = String(describing: type(of: childrens[childrens.count-1]))
                if className.contains("IPTVVideoPlayerController") {
                   return UIInterfaceOrientationMask.allButUpsideDown
                }
            }
        }
        return self.orientationLock
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                YPYLog.logE("==>Error fetching FCM registration token: \(error)")
            }
            else if let token = token {
                YPYLog.logE("==>FCM registration token: \(token)")
                //UserDataManager.setString(UserDataManager.KEY_STR_PUSH_TOKENS, token)
            }
        }
    }
    // [END refresh_token]

}


