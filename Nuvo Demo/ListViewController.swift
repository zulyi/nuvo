//
//  ViewController.swift
//  Nuvo Demo
//
//  Created by admin on 15.02.2022.
//

import UIKit
import RxSwift

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let refreshControl = UIRefreshControl()
    private var items: [Coin] = []
    private var allCoins: [Coin] = []
    
    private let loadState = BehaviorSubject<LoadDataState<[Coin]>>(value: .loaded(data: nil))
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadState.subscribe(onNext: { data in
            switch(data) {
            case .loaded(let data):
                if let coins = data {
                    self.initViewWithCoins(coins)
                }
                self.endRefreshing()
            case .loadError:
                self.endRefreshing()
                // TODO add some error handling
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.text = ""
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func loadData(_ forceRefresh: Bool) {
        DataManager.shared.loadData(handler: self, state: loadState, forceRefresh: forceRefresh)
    }
    
    private func initViewWithCoins(_ coins: [Coin]) {
        let sortedCoins = coins.sorted(by: { ($0.usdRate ?? 0) > ($1.usdRate ?? 0) } )
        self.items = sortedCoins
        self.allCoins = sortedCoins
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func onRefresh() {
        searchTextField.text = nil // invalidate search on refresh
        searchTextField.resignFirstResponder()
        loadData(true)
    }
    
    private func endRefreshing() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Search text field
    
    @IBAction func onSearchEditingChanged(_ sender: Any) {
        if let query = searchTextField.text, query.count > 0 {
            // filter coins
            items = allCoins.filter({ $0.symbol.lowercased().contains(query.lowercased()) || $0.name.lowercased().contains(query.lowercased()) })
        } else {
            // show all coins
            items = allCoins
            searchTextField.resignFirstResponder()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell", for: indexPath) as! ListViewCell
        
        if (items.count >= indexPath.row) {
            let item = items[indexPath.row]
            cell.card.isInteractable = false
            cell.symbol.text = item.symbol
            cell.name.text = item.name
            if let val = item.usdRate {
                cell.rate.text = String(format: "$ %.2f", val)
            } else {
                cell.rate.text = "-"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        if (items.count >= indexPath.row) {
            let item = items[indexPath.row]
            let vc = DetailViewController.make(coin: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}

extension ListViewController: DataManagerHandler {
    
    typealias Data = [Coin]
    
    func loadFromNetwork(success: @escaping ([Coin]) -> Void, error: @escaping () -> Void) {
        CoinRepository.shared.loadCoinsListFromNetwork(success: success, error: error)
    }
    
    func getCachedData() -> [Coin]? {
        return CoinRepository.shared.getStoredCoins()
    }
    
    func storeData(data: [Coin]) {
        CoinRepository.shared.emptyCoins() // clean up cache before storing
        CoinRepository.shared.storeCoins(data)
    }
    
    func refreshTimeKey() -> String {
        return "coinsList"
    }
}

