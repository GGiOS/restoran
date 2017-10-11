//
//  OrderViewController.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.

import UIKit
import SevenSwitch
import DZNEmptyDataSet

fileprivate let separatorHeight: CGFloat = 39.0

class OrderViewController: UIViewController {
    
  //  @IBOutlet weak var modssButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet private weak var orderView: UIView!
    @IBOutlet private weak var orderPriceLabel: UILabel!
    @IBOutlet private weak var packWithYouLabel: UILabel!
    @IBOutlet private weak var packWithYouSwitch: SevenSwitch!
    @IBOutlet private weak var commentButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var orderViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var currentOpenCell: PriceListTableViewCell?
    
    var completion: (() -> Void)!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: PriceListTableViewCell.className, bundle: nil), forCellReuseIdentifier: PriceListTableViewCell.className)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.emptyDataSetSource = self
    }
    
    override func localization() {
        let selectedIndex = self.tabBarController!.tabBar.selectedItem!.tag - 1
        navigationItem.title = NSLocalizedString("\(MenuItem(rawValue: selectedIndex)!)", comment: "")
        navigationItem.leftBarButtonItem?.title = NSLocalizedString("Clear", comment: "")
        packWithYouLabel.text = NSLocalizedString("Pack with you", comment: "")
        commentButton.setTitle(NSLocalizedString("Comment", comment: ""), for: .normal)
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
    }
    
    deinit {
        print("OrderViewConroller::deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Если были какие-то изменения, к заказу добавили новые блюда - фиксируем
        updateData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    @IBAction func clearOrder(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to delete all items from your order?", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { [unowned self] _ in
            Order.shared.clearNotOrdProducts()
            self.updateData()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func packWithYouSwitchValueChanged(_ sender: SevenSwitch) {
        sender.thumbImage = sender.isOn() ? #imageLiteral(resourceName: "Accept") : nil
        Order.shared.takeWithYou = sender.isOn()
    }
    
    @IBAction func leaveComment(_ sender: Any) {
        let commentView = Bundle.main.loadNibNamed(CommentView.className, owner: self, options: nil)!.first! as! CommentView
        commentView.delegate = self
        tabBarController?.show(actionView: commentView, withWidthRatio: 1.577, andTag: 101)
    }
    
    @IBAction func sendOrder(_ sender: Any) {
        if Order.shared.notOrdProducts.count == 0 {
            showLocalizedAlert(withTitle: nil, message: "To place an order, add at least one item of interest from the menu", preferredStyle: .alert)
            return
        }
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Make an order?", comment: ""), preferredStyle: .alert)
        let orderAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { [unowned self] _ in
            
            self.performIfConnectedToNetwork {
                ProgressHUD.show()
                
                if Order.shared.ordProducts.count == 0 {
                    NetworkManager.createOrder(tableId: Order.shared.tableId, waiterId: Order.shared.waiterId, guestsCount: Order.shared.guestsCount, comment: Order.shared.getComment(), items: Order.shared.formItemsForServer()) { [unowned self] response, error in
                        ProgressHUD.dismiss()
                        self.errorHandling(response: response, error: error) {
                            if let data = response!["data"] as? [String: String], let guid = data["orderGuid"] {
                                Order.shared.setOrderGuid(guid: guid)
                                self.successOrderAlert()
                            }
                        }
                    }
                } else {
                    NetworkManager.editOrder(orderGuid: Order.shared.guid, items: Order.shared.formItemsForServer()) { [unowned self] response, error in
                        self.errorHandling(response: response, error: error) {
                            NetworkManager.stuffCall(tableId: Order.shared.tableId, waiterId: Order.shared.waiterId, message: Order.shared.getComment(), type: "waiter") { [unowned self] response, error in
                                self.errorHandling(response: response, error: error) {
                                    ProgressHUD.dismiss()
                                    self.successOrderAlert()
                                }
                            }
                        }
                    }
                }
            }
        })
        alertController.addAction(orderAction)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - private
    
    fileprivate func updateData() {
        navigationItem.leftBarButtonItem = Order.shared.notOrdProducts.count == 0 ? nil : UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""), style: .plain, target: self, action: #selector(clearOrder(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        orderViewHeightConstraint.constant = Order.shared.notOrdProducts.count == 0 ? 0 : 136
        orderPriceLabel.text = NSLocalizedString("Order for", comment: "") + " " + Order.shared.getOrderPrice().formattedWithSeparator + " ₽"
        tableView.reloadData()
    }
    
    fileprivate func errorHandling(response: [String: Any]?, error: Error?, completion: () -> Void) {
        if error != nil || response == nil {
            self.showLocalizedAlert(withTitle: nil, message: "Error. Try again", preferredStyle: .alert)
            ProgressHUD.dismiss()
            return
        } else if let errorMessage = response!["errorMessage"] as? String {
            ProgressHUD.dismiss()
            self.showLocalizedAlert(withTitle: nil, message: errorMessage, preferredStyle: .alert)
        } else {
            completion()
        }
    }
    
    fileprivate func successOrderAlert() {
        let actionView = Bundle.main.loadNibNamed(ActionView.className, owner: self, options: nil)!.last! as! ActionView
        actionView.delegate = self
        actionView.menuItem = .Ordered
        self.tabBarController?.show(actionView: actionView, withWidthRatio: 1.05, andTag: 100)
        self.packWithYouSwitch.setOn(false, animated: true)
        self.packWithYouSwitchValueChanged(self.packWithYouSwitch)
        Order.shared.orderWasMade()
        self.updateData()
    }
}

extension OrderViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("There is nothing in your order. Go to the Menu and add the items you are interested in to the order.", comment: ""), attributes: [NSFontAttributeName : UIFont.RMFont(size: 20)])
    }
}

extension OrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? Order.shared.ordProducts.count : Order.shared.notOrdProducts.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 && Order.shared.ordProducts.count != 0 && Order.shared.notOrdProducts.count != 0 ? separatorHeight : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separatorView = Bundle.main.loadNibNamed(SeparatorView.className, owner: self, options: nil)!.first! as! SeparatorView
        separatorView.label.text = NSLocalizedString("Addition to the order", comment: "")
        return separatorView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PriceListTableViewCell.className) as! PriceListTableViewCell
        cell.delegate = self
        cell.showMosdButton = false
        if indexPath.section == 0 {
            cell.configure(product: Order.shared.ordProducts[indexPath.row], directOrdCount: Order.shared.ordCounts[indexPath.row], cellActions: [])
        } else {
            cell.configure(product: Order.shared.notOrdProducts[indexPath.row], directOrdCount: nil, cellActions: [.delete])
        }
        return cell
    }
}

extension OrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if currentOpenCell == tableView.cellForRow(at: indexPath) {
            currentOpenCell?.closeCell(animated: true)
            currentOpenCell = nil
        }
    }
}

extension OrderViewController: PriceListTableViewCellProtocol {
    func cellDidOpen(cell: PriceListTableViewCell) {
        currentOpenCell?.closeCell(animated: true)
        currentOpenCell = cell
    }
    
    func cellDidClose(cell: PriceListTableViewCell) {
        if cell === currentOpenCell {
            currentOpenCell = nil
        }
    }
    
    func cellRemoveAction(cell: PriceListTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)!
        tableView.deleteRows(at: [indexPath], with: .automatic)
        updateData()
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

extension OrderViewController: CommentViewProtocol {
    func cancel() {
        tabBarController?.dismissActionView(withTag: 101)
    }
    
    func addComment(comment: String) {
        tabBarController?.dismissActionView(withTag: 101)
        if comment == "" {
            let alertController = UIAlertController(title: nil, message: NSLocalizedString("Comment can not be empty", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                let commentView = Bundle.main.loadNibNamed(CommentView.className, owner: self, options: nil)!.first! as! CommentView
                commentView.delegate = self
                self?.tabBarController?.show(actionView: commentView, withWidthRatio: 1.577, andTag: 101)
            }))
            present(alertController, animated: true, completion: nil)
        } else {
            Order.shared.comment = comment
        }
    }
}

extension OrderViewController: ActionViewProtocol {
    func cancelAction() {
        tabBarController?.dismissActionView(withTag: 100)
        self.tabBarController?.selectedIndex = 0
    }
    
    func callStuff(stuff: String) {
        performIfConnectedToNetwork {
            ProgressHUD.show()
            NetworkManager.stuffCall(tableId: Order.shared.tableId, waiterId: Order.shared.waiterId, message: "", type: stuff) { [unowned self] response, error in
                ProgressHUD.dismiss()
                self.errorHandling(response: response, error: error) {
                    self.showLocalizedAlert(withTitle: nil, message: "Soon you will be approached by a free \(stuff)", preferredStyle: .alert)
                    self.cancelAction()
                }
            }
        }
    }
    
    func exitWith(waiterId: String) {
        
    }
}

extension OrderViewController: NoteViewProtocol {
   
    func cancellNoteAction() {
        self.tabBarController?.dismissActionView(withTag: 100)
    }
    
    func addNotesAction() {
        
    }
    
    func cantChooseAnotherItem() {
        self.tabBarController?.showLocalizedAlert(withTitle: nil, message: NSLocalizedString("Selection limit exceeded", comment: ""), preferredStyle: .alert)
    }
}



