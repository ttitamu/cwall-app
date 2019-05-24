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

class ForgotPasswordController: UIViewController,  ValidationDelegate {
    let validator = Validator()
    let URL_PASSWORD_RESET = "http://13.65.39.139/request-password-reset"
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailError: UILabel!
    
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
    
    //MARK: - Send Reset Action
    /***************************************************************/
    
    @IBAction func sendResetEmail(_ sender: UIButton) {
         validator.validate(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
}
