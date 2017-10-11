//
//  Product.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


import ObjectMapper

class Product: NSObject, Mappable {
    
    var ident: Int64?
    var guidString: String?
    var name: String?
    var nameEn: String?
    var altName: String?
    var comment: String?
    var commentEn: String?
    var price: Double?
    var modisScheme: Int64?
    var modisCommonGroups: [Int64] = []
    var pictureMiddleUrl: String?
    var pictureUrl: String?
    var noPhoto: Bool?
    var country: String?
    var count: Int = 0
    var modisToOrder:[ModisItem] = []
    
    
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        ident               <- (map["ident"], CustomTransform.transformInt64String)
        guidString          <- map["GUIDString"]
        name                <- map["name"]
        nameEn              <- map["nameEn"]
        altName             <- map["altName"]
        comment             <- map["comment"]
        commentEn           <- map["commentEn"]
        price               <- map["price"]
        modisScheme         <- (map["modiScheme"], CustomTransform.transformInt64String)
        modisCommonGroups   <- (map["modisCommonGroups"], CustomTransform.transformInt64ArrStringArr)
        pictureMiddleUrl    <- map["pictureMiddle"]
        pictureUrl          <- map["picture"]
        noPhoto             <- map["noPhoto"]
        country             <- map["countryRu"]
    }
    
    func getName() -> String? {
        return Bundle.language() == Russian ? name : nameEn
    }
    
    func getComment() -> String? {
        return Bundle.language() == Russian ? comment : commentEn
    }
}



