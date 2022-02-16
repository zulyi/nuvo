//
//  Coin.swift
//  Nuvo Demo
//
//  Created by admin on 15.02.2022.
//

import Foundation
import SwiftyJSON
import CoreData

class Coin {
    
    let id: Int
    let symbol: String
    let name: String
    let usdRate: Float?
    let btcRate: Float?
    let totalCoins: Int?
    let maxCoins: Int?
    let cap: Float?
    let change1h: Float?
    let change24h: Float?
    let change7d: Float?
    
    private init(id: Int, symbol: String, name: String, usdRate: Float?, btcRate: Float?, totalCoins: Int?, maxCoins: Int?, cap: Float?, change1h: Float?, change24h: Float?, change7d: Float?) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.usdRate = usdRate
        self.btcRate = btcRate
        self.totalCoins = totalCoins
        self.maxCoins = maxCoins
        self.cap = cap
        self.change1h = change1h
        self.change24h = change24h
        self.change7d = change7d
    }
    
    static func fromJSON(json: JSON) -> Coin? {
        if let id = json["id"].int, let symbol = json["symbol"].string, let name = json["name"].string {
            let usdRate = json["quote"]["USD"]["price"].float
            let btcRate = json["quote"]["BTC"]["price"].float
            let totalCoins = json["total_supply"].int
            let maxCoins = json["max_supply"].int
            let cap = json["quote"]["USD"]["market_cap"].float
            let change1h = json["quote"]["USD"]["percent_change_1h"].float
            let change24h = json["quote"]["USD"]["percent_change_24h"].float
            let change7d = json["quote"]["USD"]["percent_change_7d"].float
            return Coin(id: id, symbol: symbol, name: name, usdRate: usdRate, btcRate: btcRate, totalCoins: totalCoins, maxCoins: maxCoins, cap: cap, change1h: change1h, change24h: change24h, change7d: change7d)
        }
        return nil
    }
    
    static func fromNSManagedObject(_ item: NSManagedObject) -> Coin? {
        if let id = item.value(forKey: "id") as? Int, let symbol = item.value(forKey: "symbol") as? String, let name = item.value(forKey: "name") as? String {
            let usdRate = item.value(forKey: "usdRate") as? Float
            let btcRate = item.value(forKey: "btcRate") as? Float
            let totalCoins = item.value(forKey: "totalCoins") as? Int
            let maxCoins = item.value(forKey: "maxCoins") as? Int
            let cap = item.value(forKey: "cap") as? Float
            let change1h = item.value(forKey: "change1h") as? Float
            let change24h = item.value(forKey: "change24h") as? Float
            let change7d = item.value(forKey: "change7d") as? Float
            return Coin(id: id, symbol: symbol, name: name, usdRate: usdRate, btcRate: btcRate, totalCoins: totalCoins, maxCoins: maxCoins, cap: cap, change1h: change1h, change24h: change24h, change7d: change7d)
        }
        return nil
    }
    
    func fillNSManagedObject(_ item: NSManagedObject) {
        item.setValue(id, forKey: "id")
        item.setValue(symbol, forKey: "symbol")
        item.setValue(name, forKey: "name")
        item.setValue(usdRate, forKey: "usdRate")
        item.setValue(btcRate, forKey: "btcRate")
        item.setValue(totalCoins, forKey: "totalCoins")
        item.setValue(maxCoins, forKey: "maxCoins")
        item.setValue(cap, forKey: "cap")
        item.setValue(change1h, forKey: "change1h")
        item.setValue(change24h, forKey: "change24h")
        item.setValue(change7d, forKey: "change7d")
    }
}
