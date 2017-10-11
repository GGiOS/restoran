//
//  Integer+FormattedWithSeparator.swift
//  Resmoscow
//
//  Created by Egor Galaev on 13/05/17.


extension Integer {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
