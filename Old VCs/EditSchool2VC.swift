//
//  EditSchool2VC.swift
//  Schools-Live
//
//  Created by Hamza  Amin on 11/1/17.
//  Copyright © 2017 Hamza  Amin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class EditSchool2VC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var editSchoolButton: UIButton!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var schoolLogo: SwiftyAvatar!
    @IBOutlet weak var schoolNameTF: UITextField!
    @IBOutlet weak var schoolLocationTF: UITextField!
    @IBOutlet weak var schoolWebsiteTF: UITextField!
    @IBOutlet weak var schoolTwitterTF: UITextField!
    @IBOutlet weak var schoolFacebookTF: UITextField!
    @IBOutlet weak var schoolTypeTV: UITextView!
    
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var schoolType = ["Primary School", "High School", "Pri-High School", "College"]
    var isImageChosen = false
    var storeSchoolID = "-1"
    var schoolNameOriginal = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        schoolLogo.isUserInteractionEnabled = true
        schoolLogo.addGestureRecognizer(tapGestureRecognizer)
        
        editSchoolButton.layer.cornerRadius = 20
        editSchoolButton.clipsToBounds = true
        pickerView.delegate = self
        pickerView.dataSource = self
        schoolNameTF.delegate = self
        schoolLocationTF.delegate = self
        schoolWebsiteTF.delegate = self
        schoolTwitterTF.delegate = self
        schoolFacebookTF.delegate = self

        if retrieveSelectedSchool() != nil {
            let selectedSchool = retrieveSelectedSchool()
            storeSchoolID = (selectedSchool?.schoolID)!
            let logoURL = selectedSchool?.schoolImage
            let encoded = logoURL?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            effectView.isHidden = false
            activityIndicator("Please Wait")
            
            if URL(string: encoded!) != nil {
                let url = URL(string: encoded!)
                let processor = DownsamplingImageProcessor(size: schoolLogo.bounds.size)
                             |> RoundCornerImageProcessor(cornerRadius: 20)
                schoolLogo.kf.indicatorType = .activity
                schoolLogo.kf.setImage(
                    with: url,
                    placeholder: nil,
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                    case .success(let value):
                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        self.effectView.isHidden = true
                        self.schoolNameTF.text = selectedSchool?.schoolName
                        self.schoolNameOriginal = (selectedSchool?.schoolName)!
                        self.schoolTypeTV.text = selectedSchool?.schoolType
                        self.schoolLocationTF.text = selectedSchool?.schoolLocation
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }
            
             /*   schoolLogo.kf.setImage(with: url, options: [.forceRefresh], completionHandler: {
                (image, error, cacheType, imageUrl) in
                self.effectView.isHidden = true
                self.schoolNameTF.text = selectedSchool?.schoolName
                self.schoolNameOriginal = (selectedSchool?.schoolName)!
                self.schoolTypeTV.text = selectedSchool?.schoolType
                self.schoolLocationTF.text = selectedSchool?.schoolLocation
                self.schoolWebsiteTF.text = selectedSchool?.schoolWebsite
                self.schoolTwitterTF.text = selectedSchool?.schoolTwitter
                self.schoolFacebookTF.text = selectedSchool?.schoolFacebook
             }) */
            }
            else {
                effectView.isHidden = true
                createAlertGoBack(titleText: "Note", messageText: "There was an error fetching School details")
            }
        }
        
        DispatchQueue.main.async {
            let screenSize = UIScreen.main.bounds
            self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenSize.height + 150)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickerTapped))
        tap.delegate = self
        self.pickerView.addGestureRecognizer(tap)
        
        self.hideKeyboard()
    }

    @objc func pickerTapped(tapRecognizer: UITapGestureRecognizer) {
        print("Tapped")
        if tapRecognizer.state == .ended {
            print("Tapped inside If")
            let rowHeight = self.pickerView.rowSize(forComponent: 0).height
            let selectedRowFrame = self.pickerView.bounds.insetBy(dx: 0, dy: (self.pickerView.frame.height - rowHeight) / 2)
            let userTappedOnSelectedRow = selectedRowFrame.contains(tapRecognizer.location(in: self.pickerView))
            if userTappedOnSelectedRow {
                let selectedRow = self.pickerView.selectedRow(inComponent: 0)
                pickerView(self.pickerView, didSelectRow: selectedRow, inComponent: 0)
                pickerView.isHidden = true
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            scrollView.setContentOffset(CGPoint(x:0, y:schoolNameTF.frame.origin.y), animated: true)
        case 1:
            scrollView.setContentOffset(CGPoint(x:0, y:schoolLocationTF.frame.origin.y), animated: true)
        case 2:
            scrollView.setContentOffset(CGPoint(x:0, y:schoolWebsiteTF.frame.origin.y), animated: true)
        case 3:
            scrollView.setContentOffset(CGPoint(x:0, y:schoolTwitterTF.frame.origin.y), animated: true)
        case 4:
            scrollView.setContentOffset(CGPoint(x:0, y:schoolFacebookTF.frame.origin.y), animated: true)
            
        default:
            print("In Default")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            schoolLocationTF.becomeFirstResponder()
        }
        else if textField.tag == 1 {
            schoolWebsiteTF.becomeFirstResponder()
        }
        else if textField.tag == 2 {
            schoolTwitterTF.becomeFirstResponder()
        }
        else if textField.tag == 3 {
            schoolFacebookTF.becomeFirstResponder()
        }
        else if textField.tag == 4 {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schoolType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return schoolType[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        schoolTypeTV.text = schoolType[row]
        pickerView.isHidden = true
        editSchoolButton.isHidden = false
        // self.view.endEditing(false)
    }
    
   /* func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        schoolLogo.image = image
        isImageChosen = true
        picker.dismiss(animated: true, completion: nil)
    } */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        schoolLogo.image = image
        isImageChosen = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        addLogo()
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
    
    func createAlert(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlertGoBack(titleText: String, messageText: String) {
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validation() -> Bool {
        let schoolName = schoolNameTF.text!
        let schoolType = schoolTypeTV.text!
        let schoolLocation = schoolLocationTF.text!
        let schoolWebsite = schoolWebsiteTF.text!
        let schoolTwitter = schoolTwitterTF.text!
        let schoolFacebook = schoolFacebookTF.text!
        
        if schoolName.count > 0 && schoolType.count > 0 && schoolLocation.count > 0 && schoolWebsite.count > 0 && schoolTwitter.count > 0 && schoolFacebook.count > 0 {
            
            if schoolLogo.image == UIImage(named: "Place Holder.png") {
                createAlert(titleText: "Note", messageText: "Please select an image for your School")
                return false
            }
            
            if !schoolFacebook.contains("www.facebook.com") {
                createAlert(titleText: "Note", messageText: "Please write the Facebook URL in correct format")
                return false
            }
            if !schoolTwitter.contains("www.twitter.com") {
                createAlert(titleText: "Note", messageText: "Please write the Twitter URL in correct format")
                return false
            }
            return true
        }
        else {
            createAlert(titleText: "Note", messageText: "Please fill all the fields")
            return false
        }
        
    }
    
    func addLogo() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Add Photo!", message: "Take/Choose a Photo", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else {
                self.createAlert(titleText: "Note", messageText: "Camera not Available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
     }
    
    @IBAction func openMenu(_ sender: UIButton) {
        print("Button Clicked")
       // NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
      //  let vc = storyboard.instantiateViewController(withIdentifier: "EditSchool")
     //   self.present(vc, animated: true, completion: nil)
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.window?.rootViewController = vc
   /*     print("Entering Loop")
        for vc in (self.navigationController?.viewControllers ?? []) {
            print("Inside Loop")
            if vc is EditSchoolVC {
                print("Inside If")
                _ = self.navigationController?.popToViewController(vc, animated: true)
            }
            else {
                print("Inside Else")
            }
        } */
        
    /*    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditSchool") as! EditSchoolVC
        self.navigationController?.popToViewController(secondViewController, animated: true) */
        
       /* let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditSchool") as! EditSchoolVC
        self.navigationController?.pushViewController(secondViewController, animated: true) */
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func editSchool(_ sender: Any) {
        if(validation()) {
            let schoolName = schoolNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let schoolType = schoolTypeTV.text
            let schoolLocation = schoolLocationTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let schoolWebsite = schoolWebsiteTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let schoolTwitter = schoolTwitterTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let schoolFacebook = schoolFacebookTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isConnectedToNetwork() {
                editSchool(schoolName: schoolName!, schoolType: schoolType!, schoolLocation: schoolLocation!, schoolWebsite: schoolWebsite!, schoolTwitter: schoolTwitter!, schoolFacebook: schoolFacebook!)
            }
            else {
                 createAlert(titleText: "Note", messageText: "Please connect to the Internet")
            }
        }
    }
    
    @IBAction func dropDown(_ sender: Any) {
        pickerView.isHidden = false
        editSchoolButton.isHidden = true
    }
    
    func editSchool(schoolName: String, schoolType: String, schoolLocation: String, schoolWebsite: String, schoolTwitter: String, schoolFacebook: String) {
        effectView.isHidden = false
        activityIndicator("Please Wait")
        AF.request("https://schools-live.com/app/apis/updateSchool.php", parameters: ["id": storeSchoolID, "name": schoolName, "type": schoolType, "website": schoolWebsite, "twitter": schoolTwitter, "facebook": schoolFacebook, "location": schoolLocation])
            .validate()
            .responseString { response in
                
                switch(response.result) {
                    case .success(let data):
                        if data.contains("Record updated successfully") {
                            self.uploadSchoolLogo(image_tag: schoolName, school_name: schoolName)
                        }
                        else {
                            self.effectView.isHidden = true
                            self.isImageChosen = false
                            self.createAlert(titleText: "Note", messageText: "There was an Error")
                        }
                        break
                    
                    case .failure(let error):
                        self.effectView.isHidden = true
                        self.createAlert(titleText: "Note", messageText: error.localizedDescription)
                        break;
                }
        }
        
    }
    
    func uploadSchoolLogo(image_tag: String, school_name: String) {
        let image : UIImage = schoolLogo.image!
        let image_data = image.jpegData(compressionQuality: 0.2)!
        let imageString = image_data.base64EncodedString(options: .lineLength64Characters)
        let url = "https://schools-live.com/school-images/insertImage.php"
        let parameters = ["image_tag": image_tag, "image_data": imageString, "school_name": school_name]
        
        AF.upload(multipartFormData: { multiPart in
               for (key, value) in parameters {
                   multiPart.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
               }
              multiPart.append(image_data, withName: "fileSet", fileName: image_tag, mimeType: "image/png")
           }, to: url, method: .post)
            .uploadProgress(queue: .main, closure: { progress in
               print("Upload Progress: \(progress.fractionCompleted)")
           }).responseJSON(completionHandler: { data in
               print("upload finished: \(data)")
           }).response { (response) in
               switch response.result {
               case .success(let result):
                    print("upload success result: \(result)")
                    print("Printing Response")
                    self.effectView.isHidden = true
                    self.isImageChosen = false
                
                    let oldSchool = self.retrieveSchool()
                    if oldSchool?.schoolName == self.schoolNameOriginal {
                        let newSchool = School(schoolID: (self.retrieveSelectedSchool()?.schoolID)!, schoolName: school_name, schoolType: self.schoolTypeTV.text.trimmingCharacters(in: .whitespacesAndNewlines), schoolLocation: self.schoolLocationTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), schoolCountry: "", schoolImage: "https://schools-live.com/school-images/" + image_tag + ".png")
                
                        self.saveSchool(school: newSchool)
                    }
                
                    self.createAlert(titleText: "School Updated", messageText: "School Updated Successfully")
               case .failure(let err):
                   print("upload err: \(err)")
               }
           }
        
        ////
        
       /* var result = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(image_data, withName: "fileset",fileName: image_tag + ".png", mimeType: "image/png")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        },
        to:"https://schools-live.com/school-images/insertImage.php")
        { (result) in
            switch result {
            case .success(let upload, let two, let three):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print("Printing Response")
                    self.effectView.isHidden = true
                    self.isImageChosen = false
                
                    let oldSchool = self.retrieveSchool()
                    if oldSchool?.schoolName == self.schoolNameOriginal {
                        let newSchool = School(schoolID: (self.retrieveSelectedSchool()?.schoolID)!, schoolName: school_name, schoolType: self.schoolTypeTV.text.trimmingCharacters(in: .whitespacesAndNewlines), schoolWebsite: self.schoolWebsiteTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), schoolTwitter: self.schoolTwitterTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), schoolFacebook: self.schoolFacebookTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), schoolLocation: self.schoolLocationTF.text!.trimmingCharacters(in: .whitespacesAndNewlines), schoolImage: "https://schools-live.com/school-images/" + image_tag + ".png")
                
                        self.saveSchool(school: newSchool)
                    }
                    
                    self.createAlert(titleText: "School Updated", messageText: "School Updated Successfully")
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        } */
    }

}
