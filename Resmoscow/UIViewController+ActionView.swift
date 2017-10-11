//
//  UIViewController+ActionView.swift
//  Resmoscow
//
//  Created by Egor Galaev on 08/05/17.


extension UIViewController {
    func show(actionView: UIView, withWidthRatio widthRatio: CGFloat, andTag tag: Int) {
        let backView = UIView(frame: self.view.frame)
        backView.tag = tag
        backView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        view.addSubview(backView)
        
        actionView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(actionView)
        center(view: actionView, relativeTo: backView, withWidthRatio: widthRatio)
        
        backView.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            backView.alpha = 1.0
        }
    }
    
    func dismissActionView(withTag tag: Int) {
        if let view = self.view.viewWithTag(tag) {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0.0
            }) { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    func showLocalizedAlert(withTitle: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: NSLocalizedString(title ?? "", comment: ""), message: NSLocalizedString(message ?? "", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func performIfConnectedToNetwork(completion: () -> Void) {
        if connectedToNetwork() {
            completion()
        } else {
            showLocalizedAlert(withTitle: nil, message: NSLocalizedString("Отсутствует подключение к интернету. Проверьте соединение и повторите попытку", comment: ""), preferredStyle: .alert)
        }
    }
    
    // MARK: - private
    
    private func center(view: UIView, relativeTo relView: UIView, withWidthRatio widthRatio: CGFloat) {
        self.view.addConstraints(
            [
                NSLayoutConstraint(item: relView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: relView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: relView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: widthRatio, constant: 0),
                NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: (view.frame.width + 10) / view.frame.height, constant: 0)
            ]
        )
    }
}
