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
    var productIDsArray: [String] = []
    let bundleID = "com.hamzabinamin.SportsApple"
    var OneNineNine = RegisteredPurchase.OneNineNine
    var NineteenNineNine = RegisteredPurchase.NineteenNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        array.append(Reports(report: "Summary Report", description: "Year-to-date statistics"))
        array.append(Reports(report: "YTD Goal Status Report", description: "Check where you stand with any goals that you created"))
        array.append(Reports(report: "Year Totals Report", description: "The total amount of weight, time, distance and count of any activity entered into the daily activity log"))
        array.append(Reports(report: "Daily Activity Report", description: "Your daily activity report with date selection"))
        productIDsArray.append(bundleID + "." + OneNineNine.rawValue)
        productIDsArray.append(bundleID + "." + NineteenNineNine.rawValue)
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ViewDidAppear got called")
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
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            
                        }
                        else {
                            self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                        }
                    }
                    else {
                        self.goToSummaryReportVC()
                    }
                }
            })
            
        }
        else if indexPath.row == 1 {
            self.showHUD(hud: hud!)
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            
                        }
                        else {
                            self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                        }
                    }
                    else {
                        self.goToGoalStatusReportVC()
                    }
                }
            })
            
        }
        else if indexPath.row == 2 {
            self.showHUD(hud: hud!)
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            
                        }
                        else {
                            self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                        }
                    }
                    else {
                          self.goToYearTotalsReportVC()
                    }
                }
            })
        }
        else if indexPath.row == 3 {
            self.showHUD(hud: hud!)
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            
                        }
                        else {
                            self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                        }
                    }
                    else {
                        self.goToDailyActivityReportVC()
                    }
                }
            })
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
    
    
    func verifySubscription(productIDs: [String], completion: @escaping (_ success1: String, _ success2: String, _ message1: String, _ message2: String) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):

                var success1 = ""
                var success2 = ""
                var message1 = ""
                var message2 = ""
                
                if productIDs.count > 1 {
                    let purchaseResultMonthly = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productIDs[0],
                        inReceipt: receipt)
                   
                    let purchaseResultYearly = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productIDs[1],
                        inReceipt: receipt)
             
                    print("Purchase Result Monthly: ", purchaseResultMonthly)
                    print("Purchase Result Yearly: ", purchaseResultYearly)

                    switch purchaseResultMonthly {
                    case .purchased(let expiryDate, let items):
                        print("\(productIDs[0]) is valid until \(expiryDate)\n\(items)\n")
                        success1 = "success"
                        message1 = "Product ID is valid until " + "\(expiryDate)"
                    //completion("success", "Product ID is valid until " + "\(expiryDate)")
                    case .expired(let expiryDate, let items):
                        print("\(productIDs[0]) is expired since \(expiryDate)\n\(items)\n")
                        success1 = "failure"
                        message1 = "Product ID is expired since " + "\(expiryDate)"
                    //completion("failure", "Product ID is expired since " + "\(expiryDate)")
                    case .notPurchased:
                        print("The user has never purchased \(productIDs[0])")
                        success1 = "failure"
                        message1 = "The user has never purchased \(productIDs[0])"
                        //completion("failure", "The user has never purchased \(productIDs[0])")
                    }
                    
                    switch purchaseResultYearly {
                        case .purchased(let expiryDate, let items):
                            print("\(productIDs[1]) is valid until \(expiryDate)\n\(items)\n")
                            success2 = "success"
                            message2 = "\(productIDs[1]) is valid until " + "\(expiryDate)"
                        //completion("success", "\(productIDs[1]) is valid until " + "\(expiryDate)")
                        case .expired(let expiryDate, let items):
                            print("\(productIDs[1]) is expired since \(expiryDate)\n\(items)\n")
                            success2 = "failure"
                            message2 = "\(productIDs[1]) is expired since " + "\(expiryDate)"
                        //completion("failure", "\(productIDs[1]) is expired since " + "\(expiryDate)")
                        case .notPurchased:
                            print("The user has never purchased \(productIDs[1])")
                            success2 = "failure"
                            message2 = "The user has never purchased \(productIDs[1])"
                            //completion("failure", "The user has never purchased \(productIDs[1])")
                    }
                }
                else {
                    let purchaseResultMonthly = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productIDs[0],
                        inReceipt: receipt)
                    
                    print("Purchase Result Monthly: ", purchaseResultMonthly)
                    
                    switch purchaseResultMonthly {
                        case .purchased(let expiryDate, let items):
                            print("\(productIDs[0]) is valid until \(expiryDate)\n\(items)\n")
                            success1 = "success"
                            message1 = "Product ID is valid until " + "\(expiryDate)"
                        //completion("success", "Product ID is valid until " + "\(expiryDate)")
                        case .expired(let expiryDate, let items):
                            print("\(productIDs[0]) is expired since \(expiryDate)\n\(items)\n")
                            success1 = "failure"
                            message1 = "Product ID is expired since " + "\(expiryDate)"
                        //completion("failure", "Product ID is expired since " + "\(expiryDate)")
                        case .notPurchased:
                            print("The user has never purchased \(productIDs[0])")
                            success1 = "failure"
                            message1 = "The user has never purchased \(productIDs[0])"
                            //completion("failure", "The user has never purchased \(productIDs[0])")
                    }
                }
                

                completion(success1, success2, message1, message2)
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion("failure", "failure", "Receipt verification failed: \(error)", "")
            }
        }
    }
    
    func purchaseSubscription(productID: String, completion: @escaping (_ success1: String, _ success2: String, _ message1: String, _ message2: String) -> Void) {
        SwiftyStoreKit.purchaseProduct(self.bundleID + "." + productID, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let storeArray = [self.bundleID + "." + productID]
                self.verifySubscription(productIDs: storeArray, completion: { (response1, response2, message1, message2) in
                    completion(response1, response2, message1, message2)
                })
            }
            else if case .error(let error) = result {
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    completion("failure", "failure", "Unknown error. Please contact support", "")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                    completion("failure", "failure", "Not allowed to make the payment", "")
                case .paymentCancelled:
                    print("Payment got cancelled")
                    completion("failure", "failure", "Payment got cancelled", "")
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                    completion("failure", "failure", "The purchase identifier was invalid", "")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    completion("failure", "failure", "The device is not allowed to make the payment", "")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    completion("failure", "failure", "The product is not available in the current storefront", "")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                    completion("failure", "failure", "Access to cloud service information is not allowed", "")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    completion("failure", "failure", "Could not connect to the network", "")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    completion("failure", "failure", "User has revoked permission to use this cloud service", "")
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
            self.purchaseSubscription(productID: self.OneNineNine.rawValue, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" {
                        self.alertWithTitle(title: "Purchase Error", message: message1)
                    }
                }
            })
        }
        alert.addAction(monthlyAction)
        
        let yearlyAction = UIAlertAction(title: "Yearly ($19.99/year)", style: .default) { (action) in
            self.showHUD(hud: self.hud!)
            self.purchaseSubscription(productID: self.NineteenNineNine.rawValue, completion: { (response1, response2, message1, message2) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" {
                        self.alertWithTitle(title: "Purchase Error", message: message1)
                    }
                }
            })
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
