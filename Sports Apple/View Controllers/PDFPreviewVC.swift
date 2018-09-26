//
//  PDFPreviewVC.swift
//  Sports Apple
//
//  Created by Hamza Amin on 9/13/18.
//  Copyright © 2018 Hamza Amin. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import JGProgressHUD
import AWSCognitoIdentityProvider

class PDFPreviewVC: UIViewController, WKUIDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    var webView: WKWebView!
    var hud: JGProgressHUD?
    var pool: AWSCognitoIdentityUserPool?
    var userItem: UserItem?
    let user: User = User()
    var url: URL!
    var messageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getUser()
    }
    
    func setupViews() {
        self.hud = self.createLoadingHUD()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 121)
        let bottomConstraint = webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingConstraint = webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.view.addSubview(webView)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        webView.uiDelegate = self
        //view = webView
        let req = NSMutableURLRequest(url: url)
        req.timeoutInterval = 60.0
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        //webView.scalesPageToFit = true
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='width=device-width';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
        webView.load(req as URLRequest)
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
    }
    
    func setupWithURL(_ url: URL) {
        self.url = url
    }
    
    func getUser() {
        self.showHUD(hud: hud!)
        user.queryUser(userId: (pool?.currentUser()?.username)!) { (response, responseUser) in
            DispatchQueue.main.async {
                
                if response == "success" {
                    self.userItem = responseUser
                    //////
                    self.pool?.currentUser()?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
                        DispatchQueue.main.async {
                            self.hideHUD(hud: self.hud!)
                            if let error = task.error as NSError? {
                                Swift.print("Error getting user attributes from Cognito: \(error)")
                            } else {
                                let response = task.result
                                if let userAttributes = response?.userAttributes {
                                    Swift.print("user attributes found: \(userAttributes)")
                                    for attribute in userAttributes {
                                        if attribute.name == "email" {
                                            if let email = attribute.value {
                                                Swift.print("User Email: \(email)")
                                                self.userItem?.email = email
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                    //////
                    
                }
            }
        }
    }
    
    @objc func showOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        alert.addAction(UIAlertAction(title: "Email", style: .default , handler:{ (UIAlertAction) in
            self.sendEmail()
        }))
        
        alert.addAction(UIAlertAction(title: "Print", style: .default , handler:{ (UIAlertAction) in
            self.print()
        }))
    
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction) in
        }))
    
        self.present(alert, animated: true, completion: {
        })
    }
    
    @objc func sendEmail() {
        if(MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            if userItem!.trainerEmail == "none" {
                Swift.print("User Email: ", userItem!.email)
                mailComposer.setToRecipients([userItem!.email])
                mailComposer.setSubject(self.messageTitle)
                //mailComposer.setMessageBody("My body message", isHTML: true)
                
                if let fileData = NSData(contentsOf: self.url) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    let pdfName = self.messageTitle + " " + formatter.string(from: Date()) + ".pdf"
                    mailComposer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: pdfName)
                }
                self.present(mailComposer, animated: true, completion: nil)
                return
            }
            else {
                Swift.print("User Email: ", userItem!.email)
                Swift.print("Trainer Email: ", userItem!.trainerEmail)
                mailComposer.setToRecipients([userItem!.email, userItem!.trainerEmail])
                mailComposer.setSubject(self.messageTitle)
                //mailComposer.setMessageBody("My body message", isHTML: true)
                
                if let fileData = NSData(contentsOf: self.url) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    let pdfName = self.messageTitle + " " + formatter.string(from: Date()) + ".pdf"
                    mailComposer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: pdfName)
                }
                self.present(mailComposer, animated: true, completion: nil)
                return
            }
        }
        let alertController = UIAlertController(title: "Mail",
                                                message: "Please install the mail app & set up your account in order to send email",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion:  nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func print() {
        let pInfo: UIPrintInfo = UIPrintInfo.printInfo()
        pInfo.outputType = UIPrintInfoOutputType.general
        pInfo.jobName = self.url.absoluteString
        pInfo.orientation = UIPrintInfoOrientation.landscape
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = pInfo
        printController.printFormatter = webView.viewPrintFormatter()
        printController.present(animated: true, completionHandler: nil)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

}
