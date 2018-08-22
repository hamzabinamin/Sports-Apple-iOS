//
//  AppDelegate.swift
//  Sports Apple
//
//  Created by Hamza Amin on 5/4/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSCognitoIdentityProvider
import IQKeyboardManagerSwift

let userPoolID = "us-east-1_TavWWBZtI"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class func defaultUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: userPoolID)
    }

    var window: UIWindow?
    var loginViewController: LoginVC?
    var tabBarViewController: ActivitySessionsVC?
    var navigationController: UINavigationController?
    var storyboard: UIStoryboard?
    var pool: AWSCognitoIdentityUserPool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.placeholderColor = .black
        
        // Warn user if configuration not updated
        if (CognitoIdentityUserPoolId == "us-east-1_7ZlE87Sy2") {
            let alertController = UIAlertController(title: "Invalid Configuration",
                                                    message: "Please configure user pool constants in Constants.swift file.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.window?.rootViewController!.present(alertController, animated: true, completion:  nil)
            //print("Please configure user pool constants in Constants.swift file.")
        }
        
        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        //AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)
        
        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: CognitoIdentityUserPoolAppClientSecret,
                                                                        poolId: CognitoIdentityUserPoolId)
        
        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        // fetch the user pool client we initialized in above step
        pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (pool?.currentUser()?.isSignedIn)! {
            let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
             self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "NCFirst") as? UINavigationController
            self.navigationController?.pushViewController(initialViewController, animated: true)
            self.navigationController?.isNavigationBarHidden = true
            self.window?.rootViewController = self.navigationController
            self.window?.makeKeyAndVisible()
            pool?.delegate = self
        }
        else {
            pool?.delegate = self
        }
        
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, didFinishLaunchingWithOptions:
            launchOptions)
        //return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    } 
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
           if navigationController.visibleViewController is SummaryReportVC ||
              navigationController.visibleViewController is GoalStatusReportVC || navigationController.visibleViewController is YearTotalsReportVC || navigationController.visibleViewController is DailyActivityReportVC {
                return UIInterfaceOrientationMask.all
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        }
        return UIInterfaceOrientationMask.portrait
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func goToActivitySessionsVC() {
        let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
        self.navigationController?.pushViewController(destVC, animated: true)
        self.navigationController?.isNavigationBarHidden = true
    }
}
    
extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
   
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print("Calling signin VC from app delegate")
        
            if (self.navigationController == nil) {
                self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "NCFirst") as? UINavigationController
            }
            
            if (self.loginViewController == nil) {
                self.loginViewController = self.navigationController?.viewControllers[0] as? LoginVC
            }
            
            DispatchQueue.main.async {
                self.navigationController!.popToRootViewController(animated: true)
                if (!self.navigationController!.isViewLoaded
                    || self.navigationController!.view.window == nil) {
                    self.window?.rootViewController?.present(self.navigationController!,
                                                             animated: true,
                                                             completion: nil)
                }
                
            }
            return self.loginViewController!
        
    } 
}

