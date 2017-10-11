//
//  IdentObject.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import ObjectMapper

class IdentObject: Mappable {
    
    var ident: Int64?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ident   <- (map["id"], CustomTransform.transformInt64String)
    }
}
