//
//  ModisItem.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import ObjectMapper

class ModisItem: IdentObject {
    
    var name: String?
    var nameEn: String?
    var price: Int64?
    var maxCount: Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        name        <- map["name"]
        nameEn      <- map["nameEn"]
        price       <- map["price"]
        maxCount    <- map["maxCount"]
    }
    
    func getName() -> String? {
        return Bundle.language() == Russian ? name : nameEn
    }
}
