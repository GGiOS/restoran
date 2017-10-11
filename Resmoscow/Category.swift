//
//  Category.swift
//  Resmoscow
//
//  Created by Egor Galaev on 22/04/17.


import ObjectMapper

class Category: Mappable {
    var ident: Int64?
    var guidString: String?
    var name: String?
    var nameEn: String?
    var pictureUrl: String?
    var altName: String?
    var logo: String?
    var parent: Category?
    var child: [Category]?
    var items: [Int64]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        ident       <- (map["ident"], CustomTransform.transformInt64String)
        guidString  <- map["GUIDString"]
        name        <- map["name"]
        nameEn      <- map["nameEn"]
        pictureUrl  <- map["picture"]
        altName     <- map["altName"]
        logo        <- map["logo"]
        child       <- map["child"]
        items       <- (map["items"], CustomTransform.transformInt64ArrStringArr)
        
        child?.forEach { $0.parent = self }
    }
    
    func getName() -> String? {
        return Bundle.language() == Russian ? name : nameEn
    }
}
