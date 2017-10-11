//
//  UIViewController+Localization.swift
//  Resmoscow
//
//  Created by Egor Galaev on 08/05/17.


extension UIViewController {
    
    override open class func initialize() {
        if self !== UIViewController.self {
            return
        }
        swizzle(original: #selector(UIViewController.viewWillAppear(_:)),
                swizzled: #selector(UIViewController.rm_viewWillAppear(_:)))
        swizzle(original: #selector(UIViewController.viewDidDisappear(_:)),
                swizzled: #selector(UIViewController.rm_viewDidDissapear(_:)))
    }
    
    func rm_viewWillAppear(_ animated: Bool) {
        self.rm_viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(localization), name: NSNotification.Name.changeLanguage, object: nil)
        localization()
    }
    
    func rm_viewDidDissapear(_ animated: Bool) {
        self.rm_viewDidDissapear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.changeLanguage, object: nil)
    }
    
    func localization() {
        
    }
    
    // MARK: - private
    
    private class func swizzle(original originalSelector: Selector, swizzled swizzledSelector: Selector) {
        DispatchQueue.once(token: NSUUID().uuidString) {
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
}


