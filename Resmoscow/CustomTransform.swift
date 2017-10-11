//
//  CustomTransform.swift
//  Resmoscow
//
//  Created by Egor Galaev on 28/04/17.


import ObjectMapper

class CustomTransform {
    static let transformInt64String = TransformOf<Int64, String>(
        fromJSON:   { Int64($0 ?? "") },
        toJSON:     { $0 != nil ? String($0!) : ""
    })
    
    static let transformInt64ArrStringArr = TransformOf<[Int64], [String]>(
        fromJSON:   { $0?.flatMap { Int64($0) } },
        toJSON:     { $0?.flatMap { String($0) } })
    
    static let transformProductMapJSONArr = TransformOf<[Int64: Product], [[String: Any]]>(
        fromJSON:   { (jsons: [[String: Any]]?) -> [Int64: Product]? in
            var map: [Int64: Product] = [:]
            
            if var products = jsons?.flatMap({ Product(JSON: $0) }) {
                products = products.filter { $0.ident != nil }
                for product in products {
                    map[product.ident!] = product
                }
            }
            
            return map
    },
        toJSON:     { (value: [Int64: Product]?) -> [[String: Any]]? in
            return []
    })
    
    static let transformModisSchemeMapJSONArr = TransformOf<[Int64: ModisScheme], [[String: Any]]>(
        fromJSON:   { (jsons: [[String: Any]]?) -> [Int64: ModisScheme]? in
            var map: [Int64: ModisScheme] = [:]
            
            if var modisSchemes = jsons?.flatMap({ ModisScheme(JSON: $0) }) {
                modisSchemes = modisSchemes.filter { $0.ident != nil }
                for modisScheme in modisSchemes {
                    map[modisScheme.ident!] = modisScheme
                }
            }
            
            return map
    },
        toJSON:     { (value: [Int64: ModisScheme]?) -> [[String: Any]]? in
            return []
    })
    
    static let transformModisGroupMapJSONArr = TransformOf<[Int64: ModisGroup], [[String: Any]]>(
        fromJSON:   { (jsons: [[String: Any]]?) -> [Int64: ModisGroup]? in
            var map: [Int64: ModisGroup] = [:]
            
            if var modisGroups = jsons?.flatMap({ ModisGroup(JSON: $0) }) {
                modisGroups = modisGroups.filter { $0.ident != nil }
                for modisGroup in modisGroups {
                    map[modisGroup.ident!] = modisGroup
                }
            }
            
            return map
    },
        toJSON:     { (value: [Int64: ModisGroup]?) -> [[String: Any]]? in
            return []
    })
    
    static let transformModisItemMapJSONArr = TransformOf<[Int64: ModisItem], [[String: Any]]>(
        fromJSON:   { (jsons: [[String: Any]]?) -> [Int64: ModisItem]? in
            var map: [Int64: ModisItem] = [:]
            
            if var modisItems = jsons?.flatMap({ ModisItem(JSON: $0) }) {
                modisItems = modisItems.filter { $0.ident != nil }
                for modisItem in modisItems {
                    map[modisItem.ident!] = modisItem
                }
            }
            
            return map
    },
        toJSON:     { (value: [Int64: ModisItem]?) -> [[String: Any]]? in
            return []
    })
    
    
    // template version
    
//    class func getTransformIdentObjectJSONArr<T: IdentObject>() -> TransformOf<[Int64: T], [[String: Any]]> {
//        return TransformOf<[Int64: T], [[String: Any]]>(
//            fromJSON:   { (jsons: [[String: Any]]?) -> [Int64: T]? in
//                return CustomTransform.getMapFrom(jsons: jsons)
//        },
//            toJSON:     { (value: [Int64: T]?) -> [[String: Any]]? in
//                return []
//        })
//    }
//    
//    // MARK: - private
//    
//    private class func getMapFrom<T: Mappable>(jsons: [[String: Any]]?) -> [Int64: T]? {
//        var map: [Int64: T] = [:]
//        
//        if var objects = jsons?.flatMap({ T(JSON: $0) }) {
//            objects = objects.filter { ($0 as? IdentObject)?.ident != nil }
//            for object in objects {
//                if let identObject = object as? IdentObject {
//                    map[identObject.ident!] = object
//                }
//            }
//        }
//        return map
//    }
}


