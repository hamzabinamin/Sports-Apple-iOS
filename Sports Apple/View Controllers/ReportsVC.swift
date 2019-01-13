//
//  ReportsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/10/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import JGProgressHUD

/* var sharedSecret = "26f4002ad2a1460cbb0a69ed1e7b6c6c"

enum RegisteredPurchase: String {
    case OneNineNine = "subscription"
    case autoRenewable = "subscription123"
} */


class ReportsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var array:[Reports] = []
    let bundleID = "com.hamzabinamin.SportsApple"
    var OneNineNine = RegisteredPurchase.OneNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        array.append(Reports(report: "Summary Report", description: "Year-to-date statistics"))
        array.append(Reports(report: "YTD Goal Status Report", description: "Check where you stand with any goals that you created"))
        array.append(Reports(report: "Year Totals Report", description: "The total amount of weight, time, distance and count of any activity entered into the daily activity log"))
        array.append(Reports(report: "Daily Activity Report", description: "Your daily activity report with date selection"))

        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ReportsTVCell
        cell.reportNameLabel.text = array[indexPath.row].report
        cell.descriptionLabel.text = array[indexPath.row].description
        cell.nextImageView.transform = CGAffineTransform(rotationAngle: .pi);
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.showHUD(hud: hud!)
            verifySubscription(productID: OneNineNine.rawValue, completion: { (response, message) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response == "failure" {
                        self.alertWithOptions(title: "Subscription Error", message: "You need to subscribe to access this feature")
                    }
                    else {
                        self.goToSummaryReportVC()
                    }
                }
            })
            
        }
        else if indexPath.row == 1 {
            goToGoalStatusReportVC()
        }
        else if indexPath.row == 2 {
            goToYearTotalsReportVC()
        }
        else if indexPath.row == 3 {
            goToDailyActivityReportVC()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getProductInfo(productID: String) {
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + productID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }
    }
    
    
    func verifySubscription(productID: String, completion: @escaping (_ success: String, _ message: String) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = self.bundleID + "." + productID
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    completion("success", "Product ID is valid until " + "\(expiryDate)")
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    completion("failure", "Product ID is expired since " + "\(expiryDate)")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    completion("failure", "The user has never purchased this Product ID")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion("failure", "Receipt verification failed: \(error)")
            }
        }
    }
    
    func purchaseSubscription(productID: String, completion: @escaping (_ success: String, _ message: String) -> Void) {
        SwiftyStoreKit.purchaseProduct(self.bundleID + "." + productID, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self.verifySubscription(productID: productID, completion: { (response, message) in
                    completion(response, message)
                })
            }
            else if case .error(let error) = result {
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    completion("failure", "Unknown error. Please contact support")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                    completion("failure", "Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                    completion("failure", "The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    completion("failure", "The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    completion("failure", "The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                    completion("failure", "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    completion("failure", "Could not connect to the network")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    completion("failure", "User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
            else {
                // purchase error
            }
        }
    }
    
    func alertWithOptions(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { (action) in
        
        }
        alert.addAction(cancelAction)
        
        let monthlyAction = UIAlertAction(title: "Monthly ($1.99/month)", style: .default) { (action) in
            self.showHUD(hud: self.hud!)
            self.purchaseSubscription(productID: self.OneNineNine.rawValue, completion: { (response, message) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response == "failure" {
                        self.alertWithTitle(title: "Purchase Error", message: message)
                    }
                }
            })
        }
        alert.addAction(monthlyAction)
        
        let yearlyAction = UIAlertAction(title: "Yearly ($19.99/year)", style: .default) { (action) in
            
            //Schedule another notification at the preferred time
        }
        alert.addAction(yearlyAction)
        
        self.present(alert, animated: true, completion:  nil)
    }
    
    func alertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion:  nil)
    }
    
    @objc func goToSummaryReportVC() {
        let storyboard = UIStoryboard(name: "SummaryReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SummaryReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToGoalStatusReportVC() {
        let storyboard = UIStoryboard(name: "GoalStatusReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "GoalStatusReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToYearTotalsReportVC() {
        let storyboard = UIStoryboard(name: "YearTotalsReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "YearTotalsReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
    
    @objc func goToDailyActivityReportVC() {
        let storyboard = UIStoryboard(name: "DailyActivityReport", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "DailyActivityReportVC")
        self.present(destVC, animated: true, completion: .none)
    }
}
