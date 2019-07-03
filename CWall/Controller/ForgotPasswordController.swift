//
//  ForgotPasswordController.swift
//  CWall
//
//  Created by Moughon, James on 1/3/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftValidator

class ForgotPasswordController: UIViewController,  ValidationDelegate, UITextFieldDelegate {
    let validator = Validator()
    let URL_PASSWORD_RESET = "http://13.65.39.139/api/request-password-reset"
    var emailText = ""
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(ForgotPasswordController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.emailTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func validationSuccessful() {
        SVProgressHUD.show(withStatus: "Sending Email")
        
        //getting the email
        let parameters: Parameters = [
            "email":emailTextField.text!
        ]
        
        //making a post request
        Alamofire.request(URL_PASSWORD_RESET, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            
            //getting the json value from the server
            if response.result.isSuccess {
                let jsonData : JSON = JSON(response.result.value!)
                
                if jsonData["content"].exists() {
                    SVProgressHUD.setForegroundColor(UIColor(red:0.29, green:0.71, blue:0.26, alpha:1.0))
                    SVProgressHUD.showSuccess(withStatus: jsonData["content"].stringValue)
                } else {
                    SVProgressHUD.setForegroundColor(UIColor(red:0.65, green:0.20, blue:0.20, alpha:1.0))
                    SVProgressHUD.showInfo(withStatus: "Email not found")
                }
            } else {
                print(response)
                SVProgressHUD.showInfo(withStatus: "Error resetting password")
            }
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reset Password"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.addDoneButtonOnKeyboard()
        emailTextField.delegate = self
        emailTextField.text = emailText
        
        validator.registerField(emailTextField, errorLabel: emailError, rules: [RequiredRule(), EmailRule()])
        validator.styleTransformers(success: {
            (validationRule) -> Void in
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderWidth = 0
            }
            if let errorLabel = validationRule.errorLabel {
                errorLabel.text = ""
                errorLabel.isHidden = true
            }
        }, error:  {
            (validationError) -> Void in
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
            if let errorLabel = validationError.errorLabel {
                errorLabel.text = validationError.errorMessage // works if you added labels
                errorLabel.isHidden = false
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        // 3
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 4
        let changeInHeight = (keyboardFrame.height + 10) * (show ? 1 : -1)
        //5
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            if (show) {
                self.topConstraint.constant = self.topConstraint.constant - changeInHeight
            } else {
                self.topConstraint.constant = 20
            }
        })
    }
    
    //MARK: - Send Reset Action
    /***************************************************************/
    
    @IBAction func sendResetEmail(_ sender: UIButton) {
         validator.validate(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
}
