//
//  MainTabBarController.swift
//  Resmoscow
//
//  Created by Egor Galaev on 19/04/17.


import UIKit

let kProductsCountInOrderChangedNotificationName = Notification.Name(rawValue: "ProductsCountInOrderChangedNotificationName")

enum MenuItem: Int {
    case Menu = 0
    case Order
    case Waiter
    case Hookah
    case Exit
    case Ordered
}

class MainTabBarController: UITabBarController {
    
    fileprivate var bgActView: UIView?
    fileprivate var actView: ActionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(productsCountInOrderChanged), name: kProductsCountInOrderChangedNotificationName, object: nil)
        productsCountInOrderChanged()
    }
    
    override func localization() {
        for i in 0..<tabBar.items!.count {
            tabBar.items![i].title = NSLocalizedString("\(MenuItem(rawValue: i)!)", comment: "")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("MainTabBarConroller::deinit")
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let menuItem = MenuItem(rawValue: item.tag - 1)!
        navigationItem.title = NSLocalizedString("\(menuItem)", comment: "")
        
        if menuItem == .Waiter || menuItem == .Hookah {
            let actionViews = Bundle.main.loadNibNamed(ActionView.className, owner: self, options: nil)!
            let actionView = (menuItem == .Waiter ? actionViews[0] : actionViews[1]) as! ActionView
            actionView.delegate = self
            actionView.menuItem = menuItem
            show(actionView: actionView, withWidthRatio: 1.05, andTag: 100)
        } else if (menuItem == .Exit) {
            let exitView = Bundle.main.loadNibNamed(ActionView.className, owner: self, options: nil)![2] as! ActionView
            exitView.delegate = self
            exitView.menuItem = menuItem
            show(actionView: exitView, withWidthRatio: 1.5, andTag: 100)
        }
    }
    
    // MARK: - private
    
    @objc private func productsCountInOrderChanged() {
        let productsCount = Order.shared.notOrdProducts.count
        tabBar.items?[1].badgeValue = productsCount > 0 ? productsCount.description : nil
    }
    
    fileprivate func errorHandling(response: [String: Any]?, error: Error?, completion: () -> Void) {
        ProgressHUD.dismiss()
        if error != nil || response == nil {
            self.showLocalizedAlert(withTitle: nil, message: "Error. Try again", preferredStyle: .alert)
            return
        } else if let errorMessage = response!["errorMessage"] as? String {
            
            self.showLocalizedAlert(withTitle: nil, message: errorMessage, preferredStyle: .alert)
        } else {
            completion()
        }
    }
}

extension MainTabBarController: ActionViewProtocol {
    func cancelAction() {
        dismissActionView(withTag: 100)
    }
    
    func callStuff(stuff: String) {
        performIfConnectedToNetwork {
            ProgressHUD.show()
            NetworkManager.stuffCall(tableId: Order.shared.tableId, waiterId: Order.shared.waiterId, message: "", type: stuff) { [unowned self] response, error in
                self.errorHandling(response: response, error: error) {
                    self.showLocalizedAlert(withTitle: nil, message: "Soon you will be approached by a free \(stuff)", preferredStyle: .alert)
                    self.cancelAction()
                }
            }
        }
    }
    
    func exitWith(waiterId: String) {
        cancelAction()
        if waiterId == Order.shared.waiterId {
            Order.shared.clearOrder()
            UIApplication.shared.delegate?.window??.rootViewController = Router.shared.startController()
        } else {
            showLocalizedAlert(withTitle: nil, message: "Invalid waiter ID", preferredStyle: .alert)
        }
    }
}

extension MainTabBarController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let waiterId = textField.text {
            exitWith(waiterId: waiterId)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text != "" || string != "0") && string.range(of: "^\\d*$", options: .regularExpression) != nil
    }
}



