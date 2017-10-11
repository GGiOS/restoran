//
//  PriceListTableViewCell.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


import UIKit
import AlamofireImage

enum CellAction {
    case delete
    case order
}
fileprivate let swipeTriggerValue: CGFloat = 50.0

class PriceListTableViewCell: UITableViewCell {
    
    var delegate: PriceListTableViewCellProtocol?
    var product: Product!
    
    var showMosdButton:Bool = true {
        didSet{
            configureView()
        }
    }
    
    fileprivate var panRecognizer: UIPanGestureRecognizer!
    fileprivate var panStartPoint: CGPoint!
    fileprivate var startingRightConstraintConstant: CGFloat!
    
    
    @IBOutlet private weak var productImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var aboveContentView: UIView!
    @IBOutlet fileprivate weak var aboveContentLeftConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var aboveContentRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var modsButton: UIButton!
    
   
    @IBOutlet fileprivate weak var deleteButton: UIButton!
    @IBOutlet fileprivate weak var orderView: UIView!
    @IBOutlet fileprivate weak var orderDecButton: UIButton!
    @IBOutlet fileprivate weak var orderIncButton: UIButton!
    @IBOutlet fileprivate weak var orderCountLabel: UILabel!
    @IBOutlet private weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var orderViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var altLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var modisNamesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.modsButton.isHidden = true
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panRecognizer.delegate = self
        aboveContentView.addGestureRecognizer(panRecognizer)
    }
    
    func configure(product: Product, directOrdCount: Int?, cellActions: [CellAction]) {
        self.product = product
        nameLabel.text = product.getName()
        altLabel.text = product.getComment()
    
        deleteButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        
        var modisString = ""
        if !product.modisToOrder.isEmpty {
            product.modisToOrder.forEach { modisItem in
                if let name = modisItem.getName() {
                    modisString.append("\(name),x\"(c) ")
                }
                modisNamesLabel.text = modisString
            }
        }
        productImageView.image = nil
        
        if let noPhoto = product.noPhoto {
            if noPhoto == true {
                productImageViewWidthConstraint.constant = 0
            } else {
                let placeholderImage = UIImage(named: "SmallProductPlaceholder")
                productImageView.image = placeholderImage
                productImageViewWidthConstraint.constant = frame.height
                if let pictureUrl = product.pictureMiddleUrl, let url = URL(string: pictureUrl) {
                    self.productImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
                }
            }
        } else {
            let placeholderImage = UIImage(named: "SmallProductPlaceholder")
            productImageView.image = placeholderImage
        }
        
        priceLabel.text = product.price != nil ? Int(product.price!).formattedWithSeparator + " ₽" : ""
        setCount(show: directOrdCount)
        
        // Disabling unnecessary action buttons
        if !cellActions.contains(CellAction.delete) {
            deleteButtonWidthConstraint.constant = 0
        }
        if !cellActions.contains(CellAction.order) {
            orderViewWidthConstraint.constant = 0
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        Order.shared.deleteProduct(product)
        delegate?.cellRemoveAction?(cell: self)
    }
    
    @IBAction func modsButtonTapped(_ sender: UIButton) {
        
        delegate?.cellChangedOrderCount(cell: self) { [unowned self] in
            Order.shared.changeCount(for: self.product, by: 0)
            self.setCount(show: nil)
        }
    }
    
    @IBAction func orderButtonTapped(_ sender: UIButton) {
        let showNoteView = Order.shared.needToShowNoteView(for: product, by: sender === orderDecButton ? -1:1)
        
        if showNoteView {
            delegate?.cellChangedOrderCount(cell: self) { [unowned self] in
                Order.shared.changeCount(for: self.product, by: sender === self.orderDecButton ? -1 : 1)
                self.setCount(show: nil)
            }
        } else {
            Order.shared.changeCount(for: self.product, by: sender === self.orderDecButton ? -1 : 1)
            self.setCount(show: nil)
            delegate?.cellChangedOrderCount(cell: self, completion: nil)
        }
    }
    
    // MARK: - private
    
    private func setCount(show ordCount: Int?) {
        orderCountLabel.text = "x\(product.count)"
        countLabel.text = ordCount != nil ? "x\(ordCount!)" : product.count > 0 ? "x\(product.count)" : ""
    }
}

// MARK: - HandlePanOnThisCell

extension PriceListTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraints(animated: false, notifyDelegateDidClose: false)
    }
    
    func openCell(animated: Bool) {
        setConstraintsToShowAllButtons(animated: animated, notifyDelegateDidOpen: false)
    }
    
    func closeCell(animated: Bool) {
        resetConstraints(animated: animated, notifyDelegateDidClose: false)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - private
    
    @objc fileprivate func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panStartPoint = recognizer.translation(in: aboveContentView)
            startingRightConstraintConstant = aboveContentRightConstraint.constant
        case .changed:
            let currentPoint = recognizer.translation(in: aboveContentView)
            let deltaX = currentPoint.x - panStartPoint.x
            let panningLeft = currentPoint.x < panStartPoint.x
            
            if startingRightConstraintConstant == 0 {
                if !panningLeft {
                    let constant = max(-deltaX, 0)
                    if constant == 0 {
                        resetConstraints(animated: true, notifyDelegateDidClose: false)
                    } else {
                        aboveContentRightConstraint.constant = constant
                    }
                } else {
                    let constant = min(-deltaX, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: false)
                    } else {
                        aboveContentRightConstraint.constant = constant
                    }
                }
            } else {
                let adjustment = startingRightConstraintConstant - deltaX
                if !panningLeft {
                    let constant = max(adjustment, 0)
                    if constant == 0 {
                        resetConstraints(animated: true, notifyDelegateDidClose: false)
                    } else {
                        aboveContentRightConstraint.constant = constant
                    }
                } else {
                    let constant = min(adjustment, buttonTotalWidth())
                    if constant == buttonTotalWidth() {
                        setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: false)
                    } else {
                        aboveContentRightConstraint.constant = constant
                    }
                }
            }
            aboveContentLeftConstraint.constant = -aboveContentRightConstraint.constant
        case .ended:
            if startingRightConstraintConstant == 0 {
                let closingTriggerValue: CGFloat = swipeTriggerValue
                if aboveContentRightConstraint.constant >= closingTriggerValue {
                    setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
                } else {
                    resetConstraints(animated: true, notifyDelegateDidClose: true)
                }
            } else {
                let openingTriggerValue: CGFloat = buttonTotalWidth() - swipeTriggerValue
                if aboveContentRightConstraint.constant >= openingTriggerValue {
                    setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
                } else {
                    resetConstraints(animated: true, notifyDelegateDidClose: true)
                }
            }
        case .cancelled:
            if startingRightConstraintConstant == 0 {
                resetConstraints(animated: true, notifyDelegateDidClose: true)
            } else {
                setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
            }
        default: break
        }
    }
    
    private func resetConstraints(animated: Bool, notifyDelegateDidClose: Bool) {
        if notifyDelegateDidClose {
            delegate?.cellDidClose?(cell: self)
        }
        if startingRightConstraintConstant == 0 && aboveContentRightConstraint.constant == 0 {
            return
        }
        aboveContentLeftConstraint.constant = 0
        aboveContentRightConstraint.constant = 0
        updateConstraintsIfNeeded(animated: animated) { [unowned self] _ in
            self.startingRightConstraintConstant = self.aboveContentRightConstraint.constant
        }
    }
    
    private func setConstraintsToShowAllButtons(animated: Bool, notifyDelegateDidOpen: Bool) {
        if notifyDelegateDidOpen {
            delegate?.cellDidOpen?(cell: self)
        }
        if startingRightConstraintConstant == buttonTotalWidth() && aboveContentRightConstraint.constant == buttonTotalWidth() {
            return
        }
        aboveContentLeftConstraint.constant = -buttonTotalWidth()
        aboveContentRightConstraint.constant = buttonTotalWidth()
        updateConstraintsIfNeeded(animated: animated) { [unowned self] _ in
            self.startingRightConstraintConstant = self.aboveContentRightConstraint.constant
        }
    }
    
    private func updateConstraintsIfNeeded(animated: Bool, completion: @escaping (Bool) -> Void) {
        let duration: TimeInterval = animated ? 0.1 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            [unowned self] in
            self.layoutIfNeeded()
            }, completion: completion)
    }
    
    private func buttonTotalWidth() -> CGFloat {
        return frame.width - orderView.frame.minX
    }
    
    func configureView()
    {
        modsButton.isHidden = showMosdButton
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        modsButton.isHidden = showMosdButton
    }
}



