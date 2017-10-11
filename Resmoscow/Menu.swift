//
//  Menu.swift
//  Resmoscow
//
//  Created by Egor Galaev on 11/05/17.


import ObjectMapper

class Menu: Mappable {
    
    static var modisSchemeMap: [Int64: ModisScheme]?
    static var modisGroupMap: [Int64: ModisGroup]?
    static var modisItemMap: [Int64: ModisItem]?
    
    static var categories: [Category]?
    static var productMap: [Int64: Product]?
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        Menu.modisSchemeMap <- (map["modisSchemes"], CustomTransform.transformModisSchemeMapJSONArr)
        Menu.modisGroupMap <- (map["modisGroups"], CustomTransform.transformModisGroupMapJSONArr)
        Menu.modisItemMap <- (map["modisItems"], CustomTransform.transformModisItemMapJSONArr)
        
        Menu.categories <- map["categories"]
        Menu.productMap <- (map["items"], CustomTransform.transformProductMapJSONArr)
    }
    
    
}




