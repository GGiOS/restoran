//
//  ModisGroup.swift
//  Resmoscow
//
//  Created by Egor Galaev on 24/06/17.


import ObjectMapper

class ModisGroup: IdentObject {
    
    var name: String?
    var nameEn: String?
    var items: [Int64] = []
    var minCount: Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        name        <- map["groupName"]
        nameEn      <- map["groupNameEn"]
        items       <- (map["items"], CustomTransform.transformInt64ArrStringArr)
        minCount    <- map["minCount"]
        
    }
    
    func getName() -> String? {
        return Bundle.language() == Russian ? name : nameEn
    }
}
