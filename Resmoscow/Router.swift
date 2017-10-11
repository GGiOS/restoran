//
//  Router.swift
//  Resmoscow
//
//  Created by Egor Galaev on 18/04/17.


import UIKit

fileprivate let kStartStoryboard = "Start"
fileprivate let kMainStoryboard = "Main"
fileprivate let kDetailStoryboard = "Detail"

class Router: NSObject {
    static let shared = Router()
    
    func startController() -> UIViewController {
        return controller(forStoryboard: kStartStoryboard, className: StartViewController.className)
    }
    
    func mainTabBarController() -> UIViewController {
        return controller(forStoryboard: kMainStoryboard, className: MainTabBarController.className)
    }
    
    func priceListViewController() -> UIViewController {
        return controller(forStoryboard: kDetailStoryboard, className: PriceListViewController.className)
    }
    
    func itemDetailViewController() -> UIViewController {
        return controller(forStoryboard: kDetailStoryboard, className: ItemDetailViewController.className)
    }
    
    // MARK: - private
    
    private override init() { }
    
    private func controller(forStoryboard storyboard: String, className: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: className)
    }
}
