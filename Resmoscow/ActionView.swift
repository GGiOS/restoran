//
//  ActionView.swift
//  Resmoscow
//
//  Created by Egor Galaev on 03/05/17.


protocol ActionViewProtocol {
    func cancelAction()
    func callStuff(stuff: String)
    func exitWith(waiterId: String)
}

class ActionView: UIView {
    
    var delegate: ActionViewProtocol?
    var menuItem: MenuItem? {
        didSet {
            let actTitle = menuItem == .Waiter ? "Call the waiter" : "Call a hookah"
            let title = menuItem == .Ordered ? "Thanks for your order!" : actTitle
            (viewWithTag(1) as? UIButton)?.setTitle(NSLocalizedString(menuItem == .Ordered ? "Back to the menu" : "Cancel", comment: ""), for: .normal)
            (viewWithTag(2) as? UIButton)?.setTitle(NSLocalizedString(actTitle, comment: ""), for: .normal)
            (viewWithTag(3) as? UIButton)?.setTitle(NSLocalizedString("Exit", comment: ""), for: .normal)
            (viewWithTag(10) as? UILabel)?.text = NSLocalizedString(title, comment: "").uppercased()
            (viewWithTag(11) as? UILabel)?.text = NSLocalizedString("\(menuItem!).info", comment: "")
            (viewWithTag(12) as? UILabel)?.text = NSLocalizedString("To exit the menu, enter the waiter code:", comment: "")
            if menuItem == .Exit {
                if let textField = viewWithTag(100) as? UITextField {
                    textField.becomeFirstResponder()
                    textField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.cancelAction()
    }
    
    @IBAction func callStuffButtonTapped(_ sender: Any) {
        delegate?.callStuff(stuff: menuItem != nil ? menuItem! == .Waiter ? "waiter" : "hookah" : "hookah")
    }
    
    @IBAction func exitButtonTapped(_ sender: Any?) {
        if let textField = viewWithTag(100) as? UITextField, let waiterId = textField.text {
            delegate?.exitWith(waiterId: waiterId)
        }
    }
    
    // MARK: - private
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
}




