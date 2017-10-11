//
//  NSObject+ClassName.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


extension NSObject {
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
