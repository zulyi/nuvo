//
//  DataManager.swift
//  Nuvo Demo
//
//  Created by admin on 15.02.2022.
//

import Foundation
import RxSwift
import Alamofire

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    private let VALID_CACHE_PERIOD_MS = 300000
    
    func loadData<D, H: DataManagerHandler>(handler: H, state: BehaviorSubject<LoadDataState<D>>, forceRefresh: Bool) where H.Data == D {
        let cachedData = handler.getCachedData()
        if let _ = cachedData {
            state.on(.next(.loaded(data: cachedData)))
        }
        
        // load from network, if either is true:
        //   - it's a forced reload
        //   - last reload data time is more than 5 min ago
        //   - there's no cached data
        let shouldLoadFromNetwork = forceRefresh || (Int(Date().timeIntervalSince1970) - getLastRefreshTime(handler.refreshTimeKey()) > VALID_CACHE_PERIOD_MS) || (cachedData == nil)
        if shouldLoadFromNetwork {
            handler.loadFromNetwork(success: { data in
                handler.storeData(data: data)
                self.storeLastRefreshTime(handler.refreshTimeKey())
                state.on(.next(.loaded(data: data)))
            }, error: {
                state.on(.next(.loadError))
            })
        }
    }
    
    private func getLastRefreshTime(_ refreshKey: String) -> Int {
        if let lastRefreshTime = UserDefaults.standard.object(forKey: refreshKey) as? Int {
            return lastRefreshTime
        }
        return 0
    }
    
    private func storeLastRefreshTime(_ refreshKey: String) {
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: refreshKey)
    }
}

protocol DataManagerHandler {
    associatedtype Data
    func loadFromNetwork(success: @escaping (_ data: Data) -> Void, error: @escaping () -> Void)
    func getCachedData() -> Data?
    func storeData(data: Data)
    func refreshTimeKey() -> String
}

enum LoadDataState<T> {
    case loaded(data: T?), loadError
}
