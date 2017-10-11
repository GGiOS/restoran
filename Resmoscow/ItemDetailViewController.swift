//
//  ItemDetailViewController.swift
//  Resmoscow
//
//  Created by Egor Galaev on 06/05/17.

import UIKit

class ItemDetailViewController: UIViewController {
    
    var product: Product?
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var priceSegmentControl: UISegmentedControl!
    @IBOutlet private weak var priceLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        priceSegmentControl.setTitleTextAttributes([NSFontAttributeName : UIFont.RMFont(size: 20.0)], for: .normal)
        
        if let product = product {
            priceSegmentControl.superview?.isHidden = true
            priceLabel.text = product.price != nil ? Int(product.price!).formattedWithSeparator + " ₽" : ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    deinit {
        print("ItemDetailViewConroller::deinit")
    }
    
    @IBAction func orderButtonTapped(_ sender: UIButton) {
        if let product = product {
            let showNoteView = Order.shared.needToShowNoteView(for: product, by: sender.tag)
            
            if showNoteView {
                let noteView = Bundle.main.loadNibNamed(NoteView.className, owner: nil, options: nil)!.first! as! NoteView
                noteView.delegate = self
                noteView.product = product
                noteView.completion =
                    { [unowned self] in
                    
                    Order.shared.changeCount(for: product, by: sender.tag)
                    self.countLabel.text = "x\(String(describing: product.count))"
                }
                self.tabBarController?.show(actionView: noteView, withWidthRatio: 1.564, andTag: 100)
            } else {
                Order.shared.changeCount(for: product, by: sender.tag)
                countLabel.text = "x\(product.count)"
            }
        }
    }
    
    
    
    // MARK: - private
    
    private func configure() {
        if let product = product {
            navigationItem.title = product.getName()
            nameLabel.text = product.getName()
            descLabel.text = product.getComment()
            countLabel.text = "x\(product.count)"
            
            imageView.image = nil
            if let pictureUrl = product.pictureUrl, let url = URL(string: pictureUrl) {
                let placeholderImage = UIImage(named: "BigProductPlaceholder")
                imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
            }
        }
    }
}

extension ItemDetailViewController: NoteViewProtocol {
    func cancellNoteAction() {
        self.tabBarController?.dismissActionView(withTag: 100)
    }
    
    func addNotesAction() {
        
    }
    
    func cantChooseAnotherItem() {
        self.tabBarController?.showLocalizedAlert(withTitle: nil, message: NSLocalizedString("Selection limit exceeded", comment: ""), preferredStyle: .alert)
    }
}



