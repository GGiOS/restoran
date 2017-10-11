//
//  ModisScheme.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import ObjectMapper

class ModisScheme: Mappable {
    
    var ident: Int64?
    var groups: [Int64] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ident   <- map["id"]
        groups  <- (map["groups"], CustomTransform.transformInt64ArrStringArr)
    }
}
