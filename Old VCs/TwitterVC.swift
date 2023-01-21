//
//  TwitterVC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 11/17/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import WebKit

class TwitterVC: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webViewHolder: UIView!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolWebsiteLabel: UILabel!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    let wkWebView: WKWebView = {
        let v = WKWebView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webViewHolder.addSubview(wkWebView)
        
        wkWebView.topAnchor.constraint(equalTo: webViewHolder.topAnchor, constant: 0.0).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: webViewHolder.bottomAnchor, constant: 0.0).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: webViewHolder.leadingAnchor, constant: 0.0).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: webViewHolder.trailingAnchor, constant: 0.0).isActive = true
        
        let school = retrieveSchool()
        
        if school  != nil {
            schoolTypeLabel.text = school?.schoolType
            schoolNameLabel.text = school?.schoolName
            schoolLocationLabel.text = school?.schoolLocation
            
            print("School not null")
          /*  print(school?.schoolTwitter ?? "None")
            if let url = URL(string: "https://" + (school?.schoolTwitter)!) {
                print("URL is presnet")
                wkWebView.navigationDelegate = self
                activityIndicator("Please Wait")
                wkWebView.load(URLRequest(url: url))
            }
            
            else {
                print("URL isn't present")
                createAlert(titleText: "Note", messageText: "Unable to load page")
            } */
        }
        else {
            print("School is null")
            createAlert(titleText: "Note", messageText: "No Twitter page present")
        }
    }
    
    func createAlert(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        effectView.isHidden = true
    }
    
    func activityIndicator(_ title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    @IBAction func openContainerVC(_ sender: UIButton) {
  /*      let vc: UIViewController! = self.storyboard!.instantiateViewController(withIdentifier: "ContainerVC")
        
        let window = UIApplication.shared.windows[0];
        window.rootViewController = vc;   */
        self.navigationController?.popToRootViewController(animated: true)
    }

}
