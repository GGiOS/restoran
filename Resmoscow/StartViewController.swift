//
//  StartViewController.swift
//  Resmoscow
//
//  Created by Anton Antonov on 14.04.17.


import UIKit
import Alamofire

fileprivate let placeholders = ["Waiter code", "Table code", "Number of guests"]

class StartViewController: UIViewController {
    
    @IBOutlet fileprivate var optionsTextFields: [UITextField]!
    @IBOutlet fileprivate weak var gotoMenuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        NetworkManager.getMenu { menu, error in
            print("Menu.modisSchemeMap", Menu.modisSchemeMap ?? "")
            print("Menu.modisGroupMap",Menu.modisGroupMap ?? "")
            print("Menu.modisItemMap ", Menu.modisItemMap ?? "")
            if (error != nil) {
                print("NETWORK_MANAGER::GET_MENU::ERROR\n\(error)")
            }
        }
    }
    
    override func localization() {
        optionsTextFields.enumerated().forEach {
            $1.placeholder = NSLocalizedString(placeholders[$0], comment: "") }
        gotoMenuButton.setTitle(NSLocalizedString("Go to the menu", comment: ""), for: .normal)
    }
    
    @IBAction func segueToMenu(_ sender: Any?) {
        if (gotoMenuButtonIsActive()) {
            let tableId = optionsTextFields[1].text!
            let waiterId = optionsTextFields[0].text!
            let guestsCount = Int(optionsTextFields[2].text!)!
            
            Order.shared.setOrderParams(tableId: tableId, waiterId: waiterId, guestsCount: guestsCount)
            performIfConnectedToNetwork {
                ProgressHUD.show()
                NetworkManager.checkTableWaiter(tableId: tableId, waiterId: waiterId, guestsCount: guestsCount) { [unowned self] response, error in
                    self.errorHadling(response: response, error: error) {
                        NetworkManager.createOrder(tableId: tableId, waiterId: waiterId, guestsCount: guestsCount, comment: "", items: []) { [unowned self] response, error in
                            self.errorHadling(response: response, error: error) {
                                guard
                                    let data = response!["data"] as? [String: Any],
                                    let visitId = data["visit"] as? String,
                                    let orderGuid = data["orderGuid"] as? String else {
                                        return
                                }
                                NetworkManager.cancelOrder(visitId: visitId, orderGuid: orderGuid) { [unowned self] response, error in
                                    self.errorHadling(response: response, error: error) {
                                        ProgressHUD.dismiss()
                                        self.present(Router.shared.mainTabBarController(), animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        configureGotoMenuButton()
    }
    
    // MARK: - private
    
    private func configure() {
        configureTextFields()
        configureGotoMenuButton()
    }
    
    private func configureTextFields() {
        for i in 0..<optionsTextFields.count {
            optionsTextFields[i].layer.sublayerTransform = CATransform3DMakeTranslation(12, 0, 0)
        }
    }
    
    private func configureGotoMenuButton() {
        let active = gotoMenuButtonIsActive()
        gotoMenuButton.backgroundColor = active ? UIColor.RMActiveColor : UIColor(white: 0.6, alpha: 1.0)
    }
    
    private func gotoMenuButtonIsActive() -> Bool {
        return optionsTextFields.reduce(true) { res, textField in res && textField.text != "" }
    }
    
    private func errorHadling(response: [String: Any]?, error: Error?, completion: () -> Void) {
        if error != nil {
            self.showLocalizedAlert(withTitle: nil, message: "Error. Try again", preferredStyle: .alert)
            ProgressHUD.dismiss()
            return
        }
        if let response = response, let isOk = response["isOk"] as? Bool {
            if isOk {
                completion()
            } else {
                ProgressHUD.dismiss()
                self.showLocalizedAlert(withTitle: nil, message: response["errorMessage"] as? String, preferredStyle: .alert)
            }
        }
    }
}

extension StartViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text != "" || string != "0") && string.range(of: "^\\d*$", options: .regularExpression) != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === optionsTextFields[0] {
            optionsTextFields[1].becomeFirstResponder()
        } else if textField === optionsTextFields[1] {
            optionsTextFields[2].becomeFirstResponder()
        } else {
            segueToMenu(nil)
        }
        return true
    }
}

