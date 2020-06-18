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
import JGProgressHUD

class IAPVC: UIViewController {
    
     @IBOutlet weak var subscribeMonthlyButton: UIButton!
     @IBOutlet weak var subscribeYearlyButton: UIButton!
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
     @IBOutlet weak var monthlyView: UIView!
     @IBOutlet weak var yearlyView: UIView!
     var hud: JGProgressHUD?
     var user: User = User()
     var userItem: UserItem = UserItem()
     let bundleID = "com.hamzabinamin.SportsApple"
     let OneNineNine = RegisteredPurchase.OneNineNine
     let NineteenNineNine = RegisteredPurchase.NineteenNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        setupViews()
        getProductInfo(products: [OneNineNine.rawValue, NineteenNineNine.rawValue])
    }
    
    func setupViews() {
        setupButtons()
    }
    
    func setupButtons() {
        subscribeMonthlyButton.addTarget(self, action: #selector(subscribeMonthly), for: .touchUpInside)
        subscribeYearlyButton.addTarget(self, action: #selector(subscribeYearly), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(openTermsofUse(sender:)))
        termsLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy(sender:)))
        privacyLabel.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(subscribeMonthly))
        monthlyView.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(subscribeYearly))
        yearlyView.addGestureRecognizer(tap4)
    }
    
    func getProductInfo(products: [String]) {
        self.showHUD(hud: hud!)
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + products[0], bundleID + "." + products[1]]) { result in
            self.hideHUD(hud: self.hud!)
            for (index, product) in result.retrievedProducts.enumerated() {
                print("Index: " + "\(index)")
                print("Product: " + product.localizedTitle)
                if product.localizedTitle == "Yearly Subscription" {
                    self.titleYearlyLabel.text = product.localizedTitle
                    self.priceYearlyLabel.text = "Price: " + "\(product.localizedPrice!)"
                    self.descriptionYearlyLabel.text = "Description: " + product.localizedDescription
                }
                else {
                    self.titleMonthlyLabel.text = product.localizedTitle
                    self.priceMonthlyLabel.text = "Price: " + "\(product.localizedPrice!)"
                    self.descriptionMonthlyLabel.text = "Description: " + product.localizedDescription
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
    
    func alertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion:  nil)
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
    
    @objc func subscribeMonthly() {
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
                            //self.showSuccessHUD(text: "Profile updated")
                            self.dismiss(animated: true, completion: nil)
                        }
                        else {
                            self.showErrorHUD(text: response)
                        }
                    })
                }
            }
        })
    }
    
    @objc func subscribeYearly() {
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
                            //self.showSuccessHUD(text: "Profile updated")
                            self.dismiss(animated: true, completion: nil)
                        }
                        else {
                            self.showErrorHUD(text: response)
                        }
                    })
                }
            }
        })
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
