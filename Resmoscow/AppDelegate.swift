//
//  AppDelegate.swift
//  Resmoscow
//
//  Created by Anton Antonov on 14.04.17.

//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        Bundle.setLanguage()
        setAppearance()
        
        initWindow()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) { }
    func applicationDidEnterBackground(_ application: UIApplication) { }
    func applicationWillEnterForeground(_ application: UIApplication) { }
    func applicationDidBecomeActive(_ application: UIApplication) { }
    func applicationWillTerminate(_ application: UIApplication) { }
    
    // MARK: - private
    
    private func setAppearance() {
        UINavigationBar.appearance().tintColor = UIColor(white: 0.075, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.RMNavBarTitleColor,
            NSFontAttributeName : UIFont.RMFont(size: 23.5, weight: .Medium)]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "BackButton")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "BackButton")
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage(named: "BottomNavBarLine")
        
        UITabBar.appearance().tintColor = UIColor.RMColor
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    private func initWindow() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = Router.shared.startController()
        self.window?.makeKeyAndVisible()
    }
}





