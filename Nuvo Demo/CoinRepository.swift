//
//  CoinRepository.swift
//  Nuvo Demo
//
//  Created by admin on 15.02.2022.
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import CoreData

class CoinRepository {
    
    static let shared = CoinRepository()
    
    private let appDelegate: AppDelegate!
    private let context: NSManagedObjectContext!
    
    internal init() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDelegate.persistentContainer.viewContext
    }
    
    func loadCoinsListFromNetwork(success: @escaping (_ data: [Coin]) -> Void, error: @escaping () -> Void) {
        let url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest" // sandbox url sandbox-api.coinmarketcap.com
        let headers: HTTPHeaders = ["X-CMC_PRO_API_KEY":"c5fbe839-c94c-4797-8921-81989b9b7145", "Accept": "application/json"] // sandbox key b54bcf4d-1bca-4e8e-9a24-22ff2c3d462c
        let params: Parameters? = nil  // [ "convert": "USD,BTC" ]
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON { response in
            if let responseValue = response.value, let coinsJson = responseValue["data"].array {
                var coins: [Coin] = []
                for item in coinsJson {
                    if let coin = Coin.fromJSON(json: item) {
                        coins.append(coin)
                    }
                }
                success(coins)
            } else {
                error()
            }
        }
    }
    
    func getStoredCoins() -> [Coin] {
        var coins: [Coin] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coin")
        request.sortDescriptors = [ NSSortDescriptor(key: "usdRate", ascending: false) ]
        do {
            let result = try context.fetch(request)
            for entity in result as! [NSManagedObject] {
                if let coin = Coin.fromNSManagedObject(entity) {
                    coins.append(coin)
                }
            }
        } catch {
            // well, there's nothing to do
        }
        
        return coins
    }
    
    func storeCoins(_ data: [Coin]) {
        for coin in data {
            if let entity = NSEntityDescription.entity(forEntityName: "Coin", in: context) {
                let item = NSManagedObject(entity: entity, insertInto: context)
                coin.fillNSManagedObject(item)
            }
        }
        appDelegate.saveContext()
    }
    
    func emptyCoins() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coin")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            // well, there's nothing to do
        }
    }
}
