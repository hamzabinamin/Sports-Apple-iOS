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
import AWSCognitoIdentityProvider

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
    var pool: AWSCognitoIdentityUserPool?
    let user: User = User()
    var userItem: UserItem = UserItem()
    let bundleID = "com.hamzabinamin.SportsApple"
    var OneNineNine = RegisteredPurchase.OneNineNine
    var NineteenNineNine = RegisteredPurchase.NineteenNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        array.append(Reports(report: "Summary Report", description: "Year-to-date statistics"))
        array.append(Reports(report: "YTD Goal Status Report", description: "Check where you stand with any goals that you created"))
        array.append(Reports(report: "Year Totals Report", description: "The total amount of weight, time, distance and count of any activity entered into the daily activity log"))
        array.append(Reports(report: "Daily Activity Report", description: "Your daily activity report with date selection"))
        productIDsArray.append(bundleID + "." + OneNineNine.rawValue)
        productIDsArray.append(bundleID + "." + NineteenNineNine.rawValue)
        tableView.tableFooterView = UIView()
        getUser()
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
            
            if userItem.subscriptionDetails["Type"] != "none" {
                print("User has subscribed before")
                let expirationDate =  userItem.subscriptionDetails["Expiration Date"]
                
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                //formatter.locale = Locale(identifier:"en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let utcExpirationDate = formatter.date(from: expirationDate!)
                formatter.timeZone = TimeZone.current
                let currentTimeZoneExpirationDateString = formatter.string(from: utcExpirationDate!)
                let currentTimeZoneExpirationDate  = formatter.date(from: currentTimeZoneExpirationDateString)
                let currentDateString = formatter.string(from: Date())
                let currentDate = formatter.date(from: currentDateString)
                
                print("Expiration Date: " + formatter.string(from: currentTimeZoneExpirationDate!))
                print("Current Date: " + formatter.string(from: currentDate!))
                
                var productID = ""
                
                if userItem.subscriptionDetails["Type"] == "Yearly" {
                    productID = "com.hamzabinamin.SportsApple.subscription.yearly"
                }
                else {
                    productID = "com.hamzabinamin.SportsApple.subscription"
                }
                
                if currentDate! < currentTimeZoneExpirationDate! {
                    print("Subscription Active")
                    
                    self.showHUD(hud: hud!)
                     verifySubscriptionForProof(productID: productID, completion: { (response1, message1, subscriptionDetails) in
                        DispatchQueue.main.async {
                            self.hideHUD(hud: self.hud!)
                            if response1 == "failure" {
                                if message1.contains("Receipt verification failed") {
                                    self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
                                }
                             }
                             else {
                                if self.userItem.subscriptionDetails["Original Transaction ID"] == subscriptionDetails["Original Transaction ID"] {
                                    
                                    if self.userItem.subscriptionDetails["Expiration Date"] != subscriptionDetails["Expiration Date"] {
                                        
                                        self.userItem.subscriptionDetails = subscriptionDetails
                                        self.showHUD(hud: self.hud!)
                                        self.updateUser(completion: { (response) in
                                            DispatchQueue.main.async {
                                                self.hideHUD(hud: self.hud!)
                                                if response == "success" {
                                                    self.goToSummaryReportVC()
                                                }
                                                else {
                                                    self.showErrorHUD(text: response)
                                                }
                                            }
                                        })
                                    }
                                    else {
                                        self.goToSummaryReportVC()
                                    }
                                }
                                else {
                                    self.alertWithTitle(title: "Error", message: "This apple id is already subscribed with another profile")
                                }
                             }
                        }
                     })
                }
                else {
                    print("Subscription not active")

                    self.showHUD(hud: hud!)
                    verifySubscriptionForProof(productID: productID, completion: { (response1, message1, subscriptionDetails) in
                        DispatchQueue.main.async {
                            self.hideHUD(hud: self.hud!)
                            if response1 == "failure" {
                                if message1.contains("Receipt verification failed") {
                                    self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
                                }
                                else {
                                    self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                                }
                            }
                            else {
                                if self.userItem.subscriptionDetails["Original Transaction ID"] == subscriptionDetails["Original Transaction ID"] {
                                    self.userItem.subscriptionDetails = subscriptionDetails
                                    self.showHUD(hud: self.hud!)
                                    self.updateUser(completion: { (response) in
                                        DispatchQueue.main.async {
                                            self.hideHUD(hud: self.hud!)
                                            if response == "success" {
                                                self.goToSummaryReportVC()
                                            }
                                            else {
                                                self.showErrorHUD(text: response)
                                            }
                                        }
                                    })
                                }
                                else {
                                    self.alertWithTitle(title: "Error", message: "This apple id is already being used with another profile")
                                }
                            }
                        }
                    })
                }
            }
            else {
                print("User never subscribed")
                self.showHUD(hud: hud!)
                verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                        if response1 == "failure" && response2 == "failure" {
                            if message1.contains("Receipt verification failed") {
                                self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
                            }
                            else if message1.contains("expired") || message2.contains("expired") {
                                 print("Used apple id was previously active with another subscription")
                                self.alertWithTitle(title: "Error", message: "This apple id is already being used with another profile")
                            }
                            else {
                                self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                            }
                        }
                        else {
                            print("Used apple id is active with another subscription")
                            self.alertWithTitle(title: "Error", message: "This apple id is already being used with another profile")
                        }
                    }
                })
            }
        }
        else if indexPath.row == 1 {
            self.goToGoalStatusReportVC()
            
      /*      self.showHUD(hud: hud!)
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
                        }
                        else {
                            self.alertWithOptions(title: "Subscription Required", message: "You need to subscribe to access this feature")
                        }
                    }
                    else {
                        self.goToGoalStatusReportVC()
                    }
                }
            }) */
        }
        else if indexPath.row == 2 {
            self.showHUD(hud: hud!)
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
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
            verifySubscription(productIDs: productIDsArray, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" && response2 == "failure" {
                        if message1.contains("Receipt verification failed") {
                            self.alertWithTitle(title: "Error", message: "Couldn't retrieve info from the store")
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
    
    func getUser() {
        self.showHUD(hud: hud!)
        user.queryUser(userId: (pool?.currentUser()?.username)!) { (response, responseItem) in
            
            if response == "success" {
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    self.userItem = responseItem
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                }
            }
        }
    }
    
    func updateUser(completion: @escaping (_ message: String) -> Void) {
        self.showHUD(hud: self.hud!)
        self.user.createUser(userId: self.userItem.userID, firstName: self.userItem.firstName, lastName: self.userItem.lastName, trainerEmail: self.userItem.trainerEmail, biceps: self.userItem.biceps, calves: self.userItem.calves, chest: self.userItem.chest, dOB: self.userItem.dOB, forearms: self.userItem.forearms, height: self.userItem.height, hips: self.userItem.hips, location: self.userItem.location, neck: self.userItem.neck, thighs: self.userItem.thighs, waist: self.userItem.waist, weight: self.userItem.weight, wrist: self.userItem.wrist, subscriptionDetails: self.userItem.subscriptionDetails, completion: { (response) in
            
            DispatchQueue.main.async {
                self.hideHUD(hud: self.hud!)
                
                if response == "success" {
                    completion("success")
                }
                else {
                    completion(response)
                }
                
            }
            
        })
    }
    
    func verifySubscription(productIDs: [String], completion: @escaping (_ success1: String, _ success2: String, _ message1: String, _ message2: String, _ subscriptionDetails: [String: String]) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):

                var success1 = ""
                var success2 = ""
                var message1 = ""
                var message2 = ""
                var subscriptionDetails = [String: String]()
                
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
                        print("Original transaction ID id \(items[0].originalTransactionId)\n")
                        success1 = "success"
                        message1 = "Product ID is valid until " + "\(expiryDate)"
                    //completion("success", "Product ID is valid until " + "\(expiryDate)")
                    case .expired(let expiryDate, let items):
                        print("\(productIDs[0]) is expired since \(expiryDate)\n\(items)\n")
                        print("Original transaction ID id \(items[0].originalTransactionId)\n")
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
                    
                    // Getting the original transaction ID
                    print("Getting transaction ID here")
                    
                }
                else {
                    let purchaseResultMonthly = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productIDs[0],
                        inReceipt: receipt)
                    
                    print("Purchase Result Monthly/Yearly: ", purchaseResultMonthly)
                    
                    switch purchaseResultMonthly {
                        case .purchased(let expiryDate, let items):
                            print("\(productIDs[0]) is valid until \(expiryDate)\n\(items)\n")
                            success1 = "success"
                            message1 = "Product ID is valid until " + "\(expiryDate)"
                            
                            if items[0].productId == "com.hamzabinamin.SportsApple.subscription.yearly" {
                                subscriptionDetails["Type"] = "Yearly"
                            }
                            else {
                                subscriptionDetails["Type"] = "Monthly"
                            }
                            
                            let formatter = DateFormatter()
                            formatter.timeZone = TimeZone(abbreviation: "UTC")
                            //formatter.locale = Locale(identifier:"en_US_POSIX")
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                            
                            subscriptionDetails["Expiration Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].subscriptionExpirationDate)!))
                            subscriptionDetails["Original Purchase Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].originalPurchaseDate)!))
                            subscriptionDetails["Purchase Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].purchaseDate)!))
                            subscriptionDetails["Original Transaction ID"] = items[0].originalTransactionId

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
                

                completion(success1, success2, message1, message2, subscriptionDetails)
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion("failure", "failure", "Receipt verification failed: \(error)", "", [String: String]())
            }
        }
    }
    
    func verifySubscriptionForProof(productID: String, completion: @escaping (_ success1: String, _ message1: String, _ subscriptionDetails: [String: String]) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
                var success1 = ""
                var message1 = ""
                var subscriptionDetails = [String: String]()
                
                let purchaseResultMonthly = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productID,
                    inReceipt: receipt)
                    
                print("Purchase Result Monthly/Yearly: ", purchaseResultMonthly)
                    
                switch purchaseResultMonthly {
                    case .purchased(let expiryDate, let items):
                        print("\(productID) is valid until \(expiryDate)\n\(items)\n")
                        success1 = "success"
                        message1 = "Product ID is valid until " + "\(expiryDate)"
                        
                        if items[0].productId == "com.hamzabinamin.SportsApple.subscription.yearly" {
                            subscriptionDetails["Type"] = "Yearly"
                        }
                        else {
                            subscriptionDetails["Type"] = "Monthly"
                        }
                        
                        let formatter = DateFormatter()
                        formatter.timeZone = TimeZone(abbreviation: "UTC")
                        //formatter.locale = Locale(identifier:"en_US_POSIX")
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        
                        subscriptionDetails["Expiration Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].subscriptionExpirationDate)!))
                        subscriptionDetails["Original Purchase Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].originalPurchaseDate)!))
                        subscriptionDetails["Purchase Date"] = formatter.string(for: formatter.date(from: formatter.string(for: items[0].purchaseDate)!))
                        subscriptionDetails["Original Transaction ID"] = items[0].originalTransactionId
                        
                    //completion("success", "Product ID is valid until " + "\(expiryDate)")
                    case .expired(let expiryDate, let items):
                        print("\(productID) is expired since \(expiryDate)\n\(items)\n")
                        success1 = "failure"
                        message1 = "Product ID is expired since " + "\(expiryDate)"
                    //completion("failure", "Product ID is expired since " + "\(expiryDate)")
                    case .notPurchased:
                        print("The user has never purchased \(productID)")
                        success1 = "failure"
                        message1 = "The user has never purchased \(productID)"
                        //completion("failure", "The user has never purchased \(productIDs[0])")
                    }
                
                completion(success1, message1, subscriptionDetails)
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion("failure", "Receipt verification failed: \(error)", [String: String]())
            }
        }
    }
    
    func purchaseSubscription(productID: String, completion: @escaping (_ success1: String, _ success2: String, _ message1: String, _ message2: String, _ subscriptionDetails: [String: String]) -> Void) {
        SwiftyStoreKit.purchaseProduct(self.bundleID + "." + productID, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                print("Purchase is: " + "\(purchase)")
                if purchase.needsFinishTransaction {
                    print("Inside needsFinishTransaction")
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                    
                }
                
                let storeArray = [self.bundleID + "." + productID]
                self.verifySubscription(productIDs: storeArray, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                    completion(response1, response2, message1, message2, subscriptionDetails)
                })
            }
            else if case .error(let error) = result {
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    completion("failure", "failure", "Unknown error. Please contact support", "", [String: String]())
                case .clientInvalid:
                    print("Not allowed to make the payment")
                    completion("failure", "failure", "Not allowed to make the payment", "", [String: String]())
                case .paymentCancelled:
                    print("Payment got cancelled")
                    completion("failure", "failure", "Payment got cancelled", "", [String: String]())
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                    completion("failure", "failure", "The purchase identifier was invalid", "", [String: String]())
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    completion("failure", "failure", "The device is not allowed to make the payment", "", [String: String]())
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    completion("failure", "failure", "The product is not available in the current storefront", "", [String: String]())
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                    completion("failure", "failure", "Access to cloud service information is not allowed", "", [String: String]())
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    completion("failure", "failure", "Could not connect to the network", "", [String: String]())
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    completion("failure", "failure", "User has revoked permission to use this cloud service", "", [String: String]())
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
            self.purchaseSubscription(productID: self.OneNineNine.rawValue, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" {
                        self.alertWithTitle(title: "Purchase Error", message: message1)
                    }
                    else {
                        self.userItem.subscriptionDetails = subscriptionDetails
                        self.updateUser(completion: { response in
                            if response == "success" {
                                self.showSuccessHUD(text: "Profile updated")
                            }
                            else {
                                self.showErrorHUD(text: response)
                            }
                        })
                    }
                }
            })
        }
        alert.addAction(monthlyAction)
        
        let yearlyAction = UIAlertAction(title: "Yearly ($19.99/year)", style: .default) { (action) in
            self.showHUD(hud: self.hud!)
            self.purchaseSubscription(productID: self.NineteenNineNine.rawValue, completion: { (response1, response2, message1, message2, subscriptionDetails) in
                DispatchQueue.main.async {
                    self.hideHUD(hud: self.hud!)
                    if response1 == "failure" {
                        self.alertWithTitle(title: "Purchase Error", message: message1)
                    }
                    else {
                        self.userItem.subscriptionDetails = subscriptionDetails
                        self.updateUser(completion: { response in
                            if response == "success" {
                                  self.showSuccessHUD(text: "Profile updated")
                            }
                            else {
                                self.showErrorHUD(text: response)
                            }
                        })
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
