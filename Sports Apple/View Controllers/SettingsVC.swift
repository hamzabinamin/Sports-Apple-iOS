//
//  SettingsVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 6/5/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import JGProgressHUD
import SwiftyStoreKit
import StoreKit

var sharedSecret = "0dba9a3d690e474cbfec027e8ae8c646"

enum RegisteredPurchase: String {
    case OneNineNine = "membership"
    case autoRenewable = "autoRenewable"
}

class NetworkActivityIndicatorManager: NSObject {
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func networkOperationFinished() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    let array = ["Profile", "WeekLink" , "Log Out"]
    let user: User = User()
    var userItem: UserItem = UserItem()
    var money: Int!
    let bundleID = "com.hamzabinamin.SportsApple"
    var OneNineNine = RegisteredPurchase.OneNineNine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        tableView.tableFooterView = UIView()
       
         NotificationCenter.default.addObserver(self, selector: #selector(goToLoginVC), name: .showLoginVC, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .profileUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = " "
        self.navigationController?.isNavigationBarHidden = false
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsTVCell
        cell.nameLabel.text = array[indexPath.row]
        
        if indexPath.row == 2 {
            cell.nameLabel.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.showHUD(hud: hud!)
            user.queryUser(userId: (pool?.currentUser()?.username)!) { (response, responseItem) in
                
                if response == "success" {
                    DispatchQueue.main.async {
                        self.userItem = responseItem
                        
                        self.pool?.currentUser()?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                            DispatchQueue.main.async(execute: {
                                self.hideHUD(hud: self.hud!)
                                let response = task.result
                                let userAttribute = response?.userAttributes![2]
                                //print("Attribute Name: ", userAttribute?.name!)
                                print("Attribute Value: ", userAttribute!.value!)
                                self.userItem.email = userAttribute!.value!
                                self.goToSignUp1VC()
                            })
                            return nil
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.hideHUD(hud: self.hud!)
                    }
                }
            }
        }
        else if indexPath.row == 1 {
            
          /* if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://www.weeklink.life/")!, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(URL(string: "http://www.weeklink.life/")!)
            } */
            purchase(purchase: .OneNineNine)
        }
        else if indexPath.row == 2 {
            let storyboard = UIStoryboard(name: "LogOut", bundle: nil)
            let destVC = storyboard.instantiateViewController(withIdentifier: "LogOutVC")
            self.present(destVC, animated: true, completion: .none)
        }
        
    }
    
    func getInfo(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue]) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
        }
    }
    
    func purchase(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchase.rawValue) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let product) = result {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
            else if case .error(let error) = result {
                print(error.localizedDescription)
            }
            else {
                print("Didn't succeed")
            }
        }
    }
    
    func restorePurchases() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
        }
    }
    
    func verifyReceipt() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            
            if case .error(let error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    func verifyPurchase(product: RegisteredPurchase) {
         NetworkActivityIndicatorManager.NetworkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: {
            result in
             NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                let productID = self.bundleID + "." + product.rawValue
                
                if product == .OneNineNine {
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productID, inReceipt: receipt, validUntil: Date())
                    self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
                }
                else {
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
                }
            case .error(let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    func refreshReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { (result) in
             self.showAlert(alert: self.alertForRefreshReceipt(result: result))
        }
    }
    
    @objc func profileUpdated() {
         self.showSuccessHUD(text: "Profile updated successfully")
    }
    
    @objc func goToLoginVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func goToSignUp1VC() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "SignUp1VC") as! SignUp1VC
        destVC.user = userItem
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}

extension SettingsVC {
    
    func alertWithTitle(title: String, message: String) ->UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    
        return alert
    }
    
    func showAlert(alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice
            
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString))")
        }
        else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: "Couldn't retreive product info", message: "Invalid product indentifier: \(invalidProductID)")
        }
        else {
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please Contact Support"
            return alertWithTitle(title: "Could not retreive product info", message: errorString)
        }
    }
    
    func alertForPurchaseResult(result : PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let product):
            print("Purchase Succesful: \(product.productId)")
            
            return alertWithTitle(title: "Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .cloudServiceNetworkConnectionFailed:
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle(title: "Purchase Failed", message: "Check your internet connection or try again later.")
                }
                else {
                    return alertWithTitle(title: "Purchase Failed", message: "Unknown Error. Please Contact Support")
                }
            case .paymentInvalid:
                return alertWithTitle(title: "Purchase Failed", message: "Purchase Identifier is not valid")
            case .storeProductNotAvailable:
                return alertWithTitle(title: "Purchase Failed", message: "Product not found")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase Failed", message: "You are not allowed to make payments")
                
            case .unknown:
                return alertWithTitle(title: "Purchase Failed", message: "Unknown error. Please contact support")
            case .clientInvalid:
                return alertWithTitle(title: "Purchase Failed", message: "Not allowed to make the payment")
            case .paymentCancelled:
                return alertWithTitle(title: "Purchase Failed", message: "Payment Cancelled")
            case .cloudServicePermissionDenied:
                return alertWithTitle(title: "Purchase Failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceRevoked:
                return alertWithTitle(title: "Purchase Failed", message: "Access to cloud service information is revoked")
            }
        }
    }
    
    func alertForRestorePurchases(result : RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(result.restoreFailedPurchases)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please Contact Support")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored.")
            
        }
        else {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made.")
        }
        
    }
    
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case.success(let receipt):
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verification", message: "No receipt data found, application will try to get a new one. Try Again.")
            default:
                return alertWithTitle(title: "Receipt verification", message: "Receipt Verification failed")
            }
        }
    }
    
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product is valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Not purchased", message: "This product has never been purchased")
        case .expired(let expiryDate):
            
            return alertWithTitle(title: "Product Expired", message: "Product is expired since \(expiryDate)")
        }
    }
    
    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is Purchased", message: "Product will not expire")
        case .notPurchased:
            return alertWithTitle(title: "Product not purchased", message: "Product has never been purchased")
            
            
        }
        
    }
    
    func alertForRefreshReceipt(result: FetchReceiptResult) -> UIAlertController {
        switch result {
        case .success(let receiptData):
            return alertWithTitle(title: "Receipt Refreshed", message: "Receipt refreshed successfully")
        case .error(let error):
            return alertWithTitle(title: "Receipt refresh failed", message: "Receipt refresh failed")
        }
    }
    
    
}
