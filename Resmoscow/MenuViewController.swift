//
//  MenuViewController.swift
//  Resmoscow
//
//  Created by Egor Galaev on 20/04/17.


import UIKit

fileprivate let kNonCollapsableCellID = "NonCollapsableCell"
fileprivate let kOpenedMenuSectionIdentKey = "OpenedMenuSectionIdentKey"
fileprivate let kMenuOffsetKey = "MenuOffsetKey"

class MenuViewController: RRNCollapsableTableViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    private var customModel: [CollapsableMenuSection]!
    private var timer: Timer!
    private var keyboardMaybeVisible: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem?.title = Bundle.inverseLangCode()
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName : UIFont.RMFont(size: 17.5, weight: .Light)], for: .normal)
        tabBarController?.delegate = self
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkMenuData), userInfo: nil, repeats: true)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func localization() {
        let selectedIndex = self.tabBarController!.tabBar.selectedItem!.tag - 1
        navigationItem.title = NSLocalizedString("\(MenuItem(rawValue: selectedIndex)!)", comment: "")
        customModel = CollapsableTableModelBuilder.buildModel()
        tableView.reloadData()
        restoreRRNState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreRRNState()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let offsetY = UserDefaults.standard.value(forKey: kMenuOffsetKey) as? CGFloat {
//            tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
//            UserDefaults.standard.set(nil, forKey: kMenuOffsetKey)
//        }
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        UserDefaults.standard.set(tableView.contentOffset.y, forKey: kMenuOffsetKey)
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("MenuViewConroller::deinit")
    }
    
    @IBAction func switchLanguage(_ sender: UIBarButtonItem) {
        sender.title = Bundle.switchLanguageToAnother(byLangCode: sender.title!)
    }
    
    // MARK: - RRNCollapsableTableViewSectionModelProtocol
    
    override func collapsableTableView() -> UITableView! {
        return tableView
    }
    
    override func sectionHeaderNibName() -> String! {
        return CollapsableSectionHeaderView.className
    }
    
    override func model() -> [Any]! {
        return getCustomModel()
    }
    
    override func singleOpenSelectionOnly() -> Bool {
        return true
    }
    
    override func performUserTappedViewForEmptySectionsEnabled() -> Bool {
        return false
    }
    
    override func userWillTappedView(_ tappedSection: RRNCollapsableTableViewSectionModelProtocol!) {
        if let menuSection = tappedSection as? CollapsableMenuSection {
            if menuSection.products != nil {
                pushPriceListViewController(with: menuSection)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CollapsableSectionHeaderView.height
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kNonCollapsableCellID)!
        
        let menuItem = getMenuItem(for: indexPath)
        (cell.viewWithTag(1) as! UILabel).text = menuItem.title
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushPriceListViewController(with: getMenuItem(for: indexPath))
    }
    
    // MARK: - private
    
    private func pushPriceListViewController(with menuSection: CollapsableMenuSection) {
        let priceListViewController = Router.shared.priceListViewController() as! PriceListViewController
        priceListViewController.menuSection = menuSection
        priceListViewController.title = menuSection.title!
        navigationController?.pushViewController(priceListViewController, animated: true)
    }
    
    @objc private func checkMenuData() {
        if (customModel == nil || customModel!.count == 0) {
            if keyboardMaybeVisible == false {
                ProgressHUD.show()
            }
            tableView.reloadData()
        } else {
            ProgressHUD.dismiss()
            timer.invalidate()
            timer = nil
        }
    }
    
    private func getCustomModel() -> [CollapsableMenuSection]! {
        if customModel == nil || customModel!.count == 0 {
            customModel = CollapsableTableModelBuilder.buildModel()
        }
        return customModel
    }
    
    private func getMenuItem(for indexPath: IndexPath) -> CollapsableMenuSection {
        let menuItem = customModel[indexPath.section]
        if menuItem.categories != nil {
            return menuItem.categories[indexPath.row] as! CollapsableMenuSection
        }
        return menuItem
    }
    
    @objc private func keyboardDidHide() {
        keyboardMaybeVisible = false
    }
}

extension MenuViewController: UITabBarControllerDelegate {
    // Don't show controllers for buttons "Waiter" and "Hookah"
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedIndex = self.tabBarController!.tabBar.selectedItem!.tag - 1
        return selectedIndex == 0 || selectedIndex == 1
    }
}




