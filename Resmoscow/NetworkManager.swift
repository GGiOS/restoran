//
//  NetworkManager.swift
//  Resmoscow
//
//  Created by Egor Galaev on 26/04/17.


import Alamofire
import AlamofireObjectMapper

fileprivate let BASE_URL = "http://31.173.32.106"
fileprivate let API = "/dev/api/v1/index.php"

fileprivate let MENU = "/menu"
fileprivate let CHECK_TABLE_WAITER = "/checkTableWaiter"
fileprivate let WAITER_CALL = "/waiterCall"
fileprivate let CREATE_ORDER = "/createOrder"
fileprivate let CANCEL_ORDER = "/cancelOrder"
fileprivate let EDIT_ORDER = "/editOrder"

class NetworkManager: NSObject {
    
    class func getMenu(completion: @escaping (Menu?, Error?) -> Void) {
        Alamofire.request(serverURL + MENU, method: .get)
            .validate()
            .responseObject(keyPath: "data") { (response: DataResponse<Menu>) in
                switch response.result {
                case .success(let menu): completion(menu, nil)
                case .failure(let error): completion(nil, error)
                }
        }
    }
    
    class func checkTableWaiter(tableId: String, waiterId: String, guestsCount: Int, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters: Parameters = [
            "tableId": tableId,
            "waiterId": waiterId,
            "guestsCount" : guestsCount
        ]
        Alamofire.request(serverURL + CHECK_TABLE_WAITER, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any] {
                        completion(result, nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
        }
    }
    
    class func stuffCall(tableId: String, waiterId: String, message: String, type: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters: Parameters = [
            "tableId": tableId,
            "waiterId": waiterId,
            "message": message,
            "type": type
        ]
        Alamofire.request(serverURL + WAITER_CALL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any] {
                        completion(result, nil)
                    }
                case .failure(let error): completion(nil, error)
                }
        }
    }
    
    class func createOrder(tableId: String, waiterId: String, guestsCount: Int, comment: String, items: [[String: Any]], completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters: Parameters = [
            "tableId": tableId,
            "waiterId" : waiterId,
            "guestsCount" : guestsCount,
            "comment" : comment,
            "items": items
        ]
        Alamofire.request(serverURL + CREATE_ORDER, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any] {
                        completion(result, nil)
                    }
                case .failure(let error): completion(nil, error)
                }
        }
    }
    
    class func cancelOrder(visitId: String, orderGuid: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters: Parameters = [
            "visitId": visitId,
            "orderGuid" : orderGuid
        ]
        Alamofire.request(serverURL + CANCEL_ORDER, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any] {
                        completion(result, nil)
                    }
                case .failure(let error): completion(nil, error)
                }
        }
    }

    class func editOrder(orderGuid: String, items: [[String: Any]], completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters: Parameters = [
            "orderGuid": orderGuid,
            "items": items
            
        ]
        
        print(parameters)
        
        Alamofire.request(serverURL + EDIT_ORDER, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    if let result = result as? [String: Any] {
                        completion(result, nil)
                    }
                case .failure(let error): completion(nil, error)
                }
        }
    }
    
    // MARK: - private
    
    class private var serverURL: String {
        return BASE_URL + API
    }
}




