//
//  UIFont+RMFont.swift
//  Resmoscow
//
//  Created by Egor Galaev on 15/05/17.


enum RMFontWeight : String {
    case Regular = "Regular"
    case Medium = "Medium"
    case Bold = "Bold"
    case Light = "Light"
    case Thin = "Thin"
}

extension UIFont {
    class func RMFont(size: CGFloat, weight: RMFontWeight = .Regular) -> UIFont {
        return UIFont(name: "Roboto-\(weight)", size: size)!
    }
}
