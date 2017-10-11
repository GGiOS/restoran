//
//  Formatter+Separator.swift
//  Resmoscow
//
//  Created by Egor Galaev on 13/05/17.


extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}
