//
//  NoteTableViewCell.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import UIKit

class NoteTableViewCell: UITableViewCell {
    
    var choosed: Bool = false
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var btnDec: UIButton!
    @IBOutlet weak var btnInc: UIButton!
    @IBOutlet weak var constTrailingCheck: NSLayoutConstraint!
    @IBOutlet weak var constTrailingStepper: NSLayoutConstraint!
    @IBOutlet weak var lbPrice: UILabel!
    
    private var modisItem:ModisItem?
    
    var handleAddModis:((_ modisItem:ModisItem) -> Void)!
    var handleRemoveModis:((_ modisItem:ModisItem) -> Void)!
    
    var price: Int64? {
        didSet {
            if let price = price, price > 0 {
                lbPrice.isHidden = false
                lbPrice.text = "\(price) ₽"
                constTrailingCheck.constant = 85
                constTrailingStepper.constant = 70
            } else {
                lbPrice.isHidden = true
                lbPrice.text = ""
                constTrailingCheck.constant = 25
                constTrailingStepper.constant = 25
            }
        }
    }
    
    var maxCount: Int = 1 {
        didSet {
            imgView.isHidden = maxCount > 1
            stepperView.isHidden = !imgView.isHidden
            modiCount = 0
            checkButtons()
        }
    }
    
    var modiCount: Int = 0 {
        didSet {
            countLabel.text = "x\(modiCount)"
        }
    }
    
    @IBAction func incPushed(_ sender: UIButton) {
        modiCount += 1
        checkButtons()
        
        if let modis = modisItem {
            handleAddModis(modis)
        }
    }
    
    @IBAction func decPushed(_ sender: UIButton) {
        modiCount -= 1
        checkButtons()
        
        if let modis = modisItem {
            handleRemoveModis(modis)
        }
    }
    
    fileprivate func checkButtons() {
        btnInc.isEnabled = modiCount < maxCount
        btnDec.isEnabled = modiCount > 0
    }
    
    func setupModis(modis:ModisItem){
        modisItem = modis
        itemLabel.text = modis.getName()
        maxCount = modis.maxCount ?? 1
        price = modis.price
    }
    
}
