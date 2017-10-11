//
//  PriceListViewController.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


import UIKit

fileprivate let separatorHeight: CGFloat = 39.0

class PriceListViewController: UIViewController {
    
    var menuSection: CollapsableMenuSection!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var currentOpenCell: PriceListTableViewCell?
    fileprivate var menuView: BTNavigationDropdownMenu?
    fileprivate var sectionTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if menuSection.parent != nil {
            configureDropdownMenu()
        }
        
        if let prodsBySections = menuSection.products as? [[Product]] {
            sectionTitles = prodsBySections.flatMap { $0[0].country }
        }
        
        tableView.register(UINib(nibName: PriceListTableViewCell.className, bundle: nil), forCellReuseIdentifier: PriceListTableViewCell.className)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    deinit {
        print("PriceListViewConroller::deinit")
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            menuView?.hide()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Если удалили из заказа какое-либо блюдо - фиксируем изменения
        tableView.reloadData()
    }
    
    // MARK: - private
    
    private func configureDropdownMenu() {
        guard
            let parentSection = menuSection.parent as? CollapsableMenuSection,
            let parentSectionCategories = parentSection.categories as? [CollapsableMenuSection] else {
            return
        }
        
        menuView = BTNavigationDropdownMenu(containerView: self.navigationController!.view, attributedTitle: getAttributedTitle(parentTitle: parentSection.title, childTitle: menuSection.title), items: parentSectionCategories.flatMap { $0.title } as [AnyObject])
        navigationItem.titleView = menuView
        menuView?.didSelectItemAtIndexHandler = { [weak self] in
            let menuSection = parentSectionCategories[$0]
            self?.menuSection = menuSection
            if let prodsBySections = self?.menuSection.products as? [[Product]] {
                self?.sectionTitles = prodsBySections.flatMap { $0[0].country }
            }
            self?.menuView?.attributedString = self?.getAttributedTitle(parentTitle: parentSection.title, childTitle: menuSection.title)
            self?.tableView.reloadData()
        }
        menuView?.cellHeight = 45
        menuView?.cellBackgroundColor = UIColor.white
        menuView?.cellSeparatorColor = UIColor.clear
        menuView?.cellTextLabelAlignment = .center
        menuView?.cellTextLabelFont = UIFont.RMFont(size: 13)
        menuView?.checkMarkImage = nil
        menuView?.shouldChangeTitleText = false
        menuView?.arrowTintColor = UIColor.black
        menuView?.maskBackgroundOpacity = 0.0
        menuView?.arrowImage = #imageLiteral(resourceName: "ArrowDown")
        menuView?.arrowPadding = 8
        menuView?.arrowYOffset = -6
    }
    
    private func getAttributedTitle(parentTitle: String, childTitle: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.paragraphSpacing = -5
        
        // "\n " - bottom indent
        let string = parentTitle + "\n" + childTitle + "\n "
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName : UIFont.RMFont(size: 22.5, weight: .Medium), NSParagraphStyleAttributeName : style])
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.RMFont(size: 14.0, weight: .Light), range: NSRange(location: parentTitle.characters.count + 1, length: childTitle.characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.RMFont(size: 8), range: NSRange(location: parentTitle.characters.count + childTitle.characters.count + 2, length: 1))
        
        return attributedString
    }
}

extension PriceListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count == 0 ? 1 : sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let products = menuSection.products[section] as? [Product] {
            return products.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionTitles.count == 0 ? 0 : separatorHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionTitles.count == 0 {
            return UIView()
        } else {
            let view = Bundle.main.loadNibNamed(SeparatorView.className, owner: nil, options: nil)!.first! as! SeparatorView
            view.label.text = sectionTitles[section]
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PriceListTableViewCell.className) as! PriceListTableViewCell
        cell.delegate = self
        if let product = (menuSection.products[indexPath.section] as? [Product])?[indexPath.row] {
            cell.configure(product: product, directOrdCount: nil, cellActions: [.order])
        }
        return cell
    }
}

extension PriceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if currentOpenCell == tableView.cellForRow(at: indexPath) {
            currentOpenCell?.closeCell(animated: true)
            currentOpenCell = nil
        } else {
            let itemDetailViewController = Router.shared.itemDetailViewController() as! ItemDetailViewController
            if let product = (menuSection.products[indexPath.section] as? [Product])?[indexPath.row] {
                itemDetailViewController.product = product
            }
            menuView?.hide()
            navigationController?.pushViewController(itemDetailViewController, animated: true)
        }
    }
}

extension PriceListViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if (scrollView.panGestureRecognizer.velocity(in: scrollView).y < 0) {
            menuView?.hide()
//        }
    }
}

extension PriceListViewController: PriceListTableViewCellProtocol {
    func cellDidOpen(cell: PriceListTableViewCell) {
        currentOpenCell?.closeCell(animated: true)
        currentOpenCell = cell
    }
    
    func cellDidClose(cell: PriceListTableViewCell) {
        if cell === currentOpenCell {
            currentOpenCell = nil
        }
    }
    
    func cellChangedOrderCount(cell: PriceListTableViewCell, completion: (() -> Void)?) {
        if completion != nil {
            let noteView = Bundle.main.loadNibNamed(NoteView.className, owner: nil, options: nil)!.first! as! NoteView
            noteView.delegate = self
            noteView.completion = completion
            noteView.product = cell.product
            self.tabBarController?.show(actionView: noteView, withWidthRatio: 1.564, andTag: 100)
        }
    }
}

extension PriceListViewController: NoteViewProtocol {
    func cancellNoteAction() {
        self.tabBarController?.dismissActionView(withTag: 100)
    }
    
    func addNotesAction() {
        
    }
    
    func cantChooseAnotherItem() {
        self.tabBarController?.showLocalizedAlert(withTitle: nil, message: NSLocalizedString("Selection limit exceeded", comment: ""), preferredStyle: .alert)
    }
}




