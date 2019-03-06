//
//  IAPVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 3/6/19.
//  Copyright © 2019 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

class IAPVC: UIViewController {
    
     @IBOutlet weak var cancelButton: UIButton!
     @IBOutlet weak var titleMonthlyLabel: UILabel!
     @IBOutlet weak var priceMonthlyLabel: UILabel!
     @IBOutlet weak var descriptionMonthlyLabel: UILabel!
     @IBOutlet weak var titleYearlyLabel: UILabel!
     @IBOutlet weak var priceYearlyLabel: UILabel!
     @IBOutlet weak var descriptionYearlyLabel: UILabel!
     @IBOutlet weak var termsLabel: UILabel!
     @IBOutlet weak var privacyLabel: UILabel!
     @IBOutlet weak var bgView: UIView!
     let bundleID = "com.hamzabinamin.SportsApple"
     let OneNineNine = RegisteredPurchase.OneNineNine
     let NineteenNineNine = RegisteredPurchase.NineteenNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getProductInfo(products: [OneNineNine.rawValue, NineteenNineNine.rawValue])
    }
    
    func setupViews() {
        setupButtons()
  
    }
    
    func setupButtons() {
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(openTermsofUse(sender:)))
        termsLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy(sender:)))
        privacyLabel.addGestureRecognizer(tap2)
    }
    
    func getProductInfo(products: [String]) {
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + products[0], bundleID + "." + products[1]]) { result in
            
            for (index, product) in result.retrievedProducts.enumerated() {
                print("Index: " + "\(index)")
                print("Product: " + product.localizedTitle)
                if index == 0 {
                    self.titleMonthlyLabel.text = product.localizedTitle
                    self.priceMonthlyLabel.text = "Price: " + "\(product.localizedPrice!)"
                    self.descriptionMonthlyLabel.text = "Description: " + product.localizedDescription
                }
                else {
                    self.titleYearlyLabel.text = product.localizedTitle
                    self.priceYearlyLabel.text = "Price: " + "\(product.localizedPrice!)"
                    self.descriptionYearlyLabel.text = "Description: " + product.localizedDescription
                }
            }

           /* if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                self.titleMonthlyLabel.text = product.localizedTitle
                self.priceMonthlyLabel.text = "Price: " + "\(product.localizedPrice!)"
                self.descriptionMonthlyLabel.text = "Description: " + product.localizedDescription
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            } */
        }
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func openTermsofUse(sender: AnyObject) {
        if let url = URL(string: "https://sportsapple.com/terms-and-conditions") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func openPrivacyPolicy(sender: AnyObject) {
        if let url = URL(string: "https://sportsapple.com/privacy-policy") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
