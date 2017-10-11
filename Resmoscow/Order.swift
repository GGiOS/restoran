//
//  Order.swift
//  Resmoscow
//
//  Created by Egor Galaev on 01/05/17.


class Order: NSObject {
    
    static let shared = Order()
    
    private(set) var guid: String = ""
    private(set) var tableId: String = ""
    private(set) var waiterId: String = ""
    private(set) var visitId: String = ""
    private(set) var guestsCount: Int = 1
    private(set) var ordProducts: [Product] = []
    private(set) var ordCounts: [Int] = []
    private(set) var notOrdProducts: [Product] = []
    
    
    var takeWithYou: Bool = false
    var comment: String = ""
    
    func setOrderParams(tableId: String, waiterId: String, guestsCount: Int) {
        self.tableId = tableId
        self.waiterId = waiterId
        self.guestsCount = guestsCount
    }
    
    func setOrderGuid(guid: String) {
        self.guid = guid
    }
    
    func setVisitId(visitId: String) {
        self.visitId = visitId
    }
    
    func getComment() -> String {
        return comment + "\n" + (takeWithYou ? "С собой" : "Не с собой")
    }
    
    func deleteProduct(_ product: Product) {
        product.count = 0
        if let index = notOrdProducts.index(of: product) {
            notOrdProducts.remove(at: index)
            NotificationCenter.default.post(name: kProductsCountInOrderChangedNotificationName, object: nil)
        }
    }
    
    func needToShowNoteView(for product: Product, by number: Int) -> Bool {
        return notOrdProducts.index(of: product) == nil && number > 0
    }
    
    /// true, если был добавлен товар (append new product)
    func changeCount(for product: Product, by number: Int) {
        if let index = notOrdProducts.index(of: product) {
            notOrdProducts[index].count += number
            
            if notOrdProducts[index].count == 0 {
                notOrdProducts.remove(at: index)
                NotificationCenter.default.post(name: kProductsCountInOrderChangedNotificationName, object: nil)
            }
        } else {
            if number > 0 {
                product.count = 1
                notOrdProducts.append(product)
                NotificationCenter.default.post(name: kProductsCountInOrderChangedNotificationName, object: nil)
            }
        }
    }
    
    func formItemsForServer() -> [[String: Any]] {
        var items: [[String: Any]] = []
        
        for product in notOrdProducts {
            var item = [String: Any]()
            item["id"] = product.ident ?? ""
            item["quantity"] = product.count
            item["price"] = product.price ?? 0
//            if let modis = product.modis {
//                var modificator: [String: Any] = [:]
//                if let ident = modis.list?.first?.ident {
//                    modificator["id"] = ident
//                }
//                if let price = modis.list?.first?.price {
//                    modificator["price"] = price
//                }
//                item["modificator"] = modificator
//            }
            items.append(item)
        }
        
        return items
    }
    
    func getOrderPrice() -> Int {
        return notOrdProducts.reduce(0) { res, product in
            res + Int(product.price!) * product.count
        }
    }
    
    func orderWasMade() {
        ordCounts.append(contentsOf: notOrdProducts.map { $0.count })
        ordProducts.append(contentsOf: notOrdProducts)
        clearNotOrdProducts()
        comment = ""
    }
    
    func clearNotOrdProducts() {
        notOrdProducts.forEach { $0.count = 0 }
        notOrdProducts.removeAll()
        NotificationCenter.default.post(name: kProductsCountInOrderChangedNotificationName, object: nil)
    }
    
    func clearOrder() {
        ordProducts.removeAll()
        clearNotOrdProducts()
    }
    
    // MARK: - private
    
    private override init() { }
}




