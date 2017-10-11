//
//  CollapsableTableModelBuilder.swift
//  Resmoscow
//
//  Created by Egor Galaev on 20/04/17.


class CollapsableTableModelBuilder : NSObject {
    class func buildModel() -> [CollapsableMenuSection] {
        guard let categories = Menu.categories, let productMap = Menu.productMap else {
            return []
        }
        return categories.enumerated().flatMap {
            collapsableMenuSection(for: $1, parent: nil, map: productMap, topSeparatorVisible: $0 != 0, bottomSeparatorVisible: $0 == categories.count - 1)
        }
    }
    
    // MARK: - private
    
    class private func collapsableMenuSection(for category: Category, parent parentSection: CollapsableMenuSection?, map productMap: [Int64: Product], topSeparatorVisible: Bool, bottomSeparatorVisible: Bool) -> CollapsableMenuSection? {
        let menuSection = CollapsableMenuSection(
            title: category.getName(),
            ident: category.ident as NSNumber!,
            pictureUrl: category.pictureUrl,
            logoUrl: category.logo,
            optionVisible: false,
            parent: parentSection,
            categories: nil,
            products: category.items?.flatMap {
                productMap[$0]
            },
            topSeparatorVisible: topSeparatorVisible as NSNumber!,
            bottomSeparatorVisible: bottomSeparatorVisible as NSNumber!
        )
        let categories = category.child?.enumerated().flatMap {
            collapsableMenuSection(for: $1, parent: menuSection, map: productMap, topSeparatorVisible: $0 != 0, bottomSeparatorVisible: $0 == category.child!.count - 1)
        }
        menuSection?.categories = categories
        
        if let products = category.items?.flatMap({ productMap[$0] }) {
            var sectionTitles = products.flatMap { $0.country }
            // remove duplicate
            sectionTitles = Array(Set(sectionTitles))
            
            var prodsBySections = Array(repeating: [], count: sectionTitles.count)
            if sectionTitles.count == 0 {
                prodsBySections.append(products)
            } else {
                sectionTitles.enumerated().forEach { i, sectionTitle in
                    prodsBySections[i] = products.filter { $0.country == sectionTitle }
                }
            }
            menuSection?.products = prodsBySections
        } else {
            menuSection?.products = nil
        }
        
        return menuSection
    }
}


