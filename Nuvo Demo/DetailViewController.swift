//
//  DetailViewController.swift
//  Nuvo Demo
//
//  Created by admin on 15.02.2022.
//

import UIKit
import MaterialComponents

class DetailViewController: UIViewController {
    
    @IBOutlet weak var usdRateLabel: UILabel!
    @IBOutlet weak var btcRateLabel: UILabel!
    @IBOutlet weak var totalCoinsLabel: UILabel!
    @IBOutlet weak var maxCoinsLabel: UILabel!
    @IBOutlet weak var capCard: MDCCard!
    @IBOutlet weak var capLabel: UILabel!
    @IBOutlet weak var change1hLabel: UILabel!
    @IBOutlet weak var change24hLabel: UILabel!
    @IBOutlet weak var change7dLabel: UILabel!
    
    var coin: Coin?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let _ = coin else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        if let val = coin?.usdRate {
            usdRateLabel.text = String(format: "%.6f", val)
        } else {
            usdRateLabel.text = "-"
        }
        
        if let val = coin?.btcRate {
            btcRateLabel.text = String(format: "%.6f", val)
        } else {
            btcRateLabel.text = "-"
        }
        
        if let val = coin?.totalCoins {
            totalCoinsLabel.text = "\(val)"
        } else {
            totalCoinsLabel.text = "-"
        }
        
        if let val = coin?.maxCoins {
            maxCoinsLabel.text = "\(val)"
        } else {
            maxCoinsLabel.text = "-"
        }
        
        if let val = coin?.cap {
            capLabel.text = String(format: "$ %.2f", val)
        } else {
            capLabel.text = "-"
        }
        
        initChangeValue(change1hLabel, coin?.change1h)
        initChangeValue(change24hLabel, coin?.change24h)
        initChangeValue(change7dLabel, coin?.change7d)
    }
    
    private func initChangeValue(_ lbl: UILabel, _ val: Float?) {
        
        guard let val = val else {
            lbl.text = "-"
            lbl.textColor = UIColor.label
            return
        }
        
        if val > 0 {
            lbl.text = String(format: "+%.6f", val)
            lbl.textColor = UIColor.green
        } else if val < 0 {
            lbl.text = String(format: "%.6f", val)
            lbl.textColor = UIColor.red
        } else {
            lbl.text = String(format: "%.6f", val)
            lbl.textColor = UIColor.label
        }
    }
    

    // MARK: - Factory

    static func make(coin: Coin) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.coin = coin
        return vc
    }
}
