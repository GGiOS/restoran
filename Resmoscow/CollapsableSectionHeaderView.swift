//
//  CollapsableSectionHeaderView.swift
//  Resmoscow
//
//  Created by Egor Galaev on 21/04/17.


import Alamofire
import AlamofireImage

class CollapsableSectionHeaderView: RRNTableViewHeaderFooterView {
    
    static let height: CGFloat = 100.0
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    
    override func update(_ title: String!, pictureUrl: String!, logoUrl: String?, topSeparatorVisible: NSNumber!, bottomSeparatorVisible: NSNumber!) {
        imageView.image = nil
        logoImageView.image = nil
        titleLabel.text = ""
        
        if let logoUrl = logoUrl, let url = URL(string: logoUrl) {
            logoImageView.af_setImage(withURL: url) { [unowned self] image in
                if self.logoImageView.image != nil {
                    self.widthConstraint.constant = self.logoImageView.image!.size.width / self.logoImageView.image!.size.height * self.logoImageView.frame.height
                }
            }
        } else {
            titleLabel.text = title
        }
        if let pictureUrl = pictureUrl, let url = URL(string: pictureUrl) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, filter: CircleFilter())
        }
        viewWithTag(1)?.isHidden = !topSeparatorVisible.boolValue
        viewWithTag(2)?.isHidden = !bottomSeparatorVisible.boolValue
    }
}


