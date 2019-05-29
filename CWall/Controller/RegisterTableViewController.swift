//
//  RegisterViewController.swift
//  CWall
//
//  Created by Moughon, James on 1/9/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftValidator

class RegisterTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, ValidationDelegate, UITextFieldDelegate {
    let URL_USER_CREATE = "http://13.65.39.139/api/users"
    let validator = Validator()
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wheelchairSwitch: UISwitch!
    @IBOutlet weak var visualImpairmentSwitch: UISwitch!
    @IBOutlet weak var betweenStopLimitPicker: UIPickerView!
    @IBOutlet weak var hapticFeedbackSwitch: UISwitch!
    @IBOutlet weak var hapticFeedbackHelpSwitch: UISwitch!
    @IBOutlet weak var firstNameError: UILabel!
    @IBOutlet weak var lastNameError: UILabel!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    
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
        
        self.firstNameTextField.inputAccessoryView = doneToolbar
        self.lastNameTextField.inputAccessoryView = doneToolbar
        self.emailTextField.inputAccessoryView = doneToolbar
        self.passwordTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    let profile = ProfileModel(dict: [
        "userId": 0,
        "userEmail": "",
        "firstName": "",
        "lastName": "",
        "wheelchair": false,
        "visualImpairment": false,
        "hapticFeedback": true,
        "hapticFeedbackHelp": true,
        "betweenStopLimit": 2
    ]);
    
    func validationSuccessful() {
        SVProgressHUD.show(withStatus: "Creating User")
        let userParameters = [
            "username": emailTextField.text!,
            "email": emailTextField.text!,
            "password": passwordTextField.text!,
            "_profile": [
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "wheelchair": wheelchairSwitch.isOn,
                "visualImpairment": visualImpairmentSwitch.isOn,
                "hapticFeedback": hapticFeedbackSwitch.isOn,
                "hapticFeedbackHelp": hapticFeedbackHelpSwitch.isOn,
                "betweenStopLimit": profile.betweenStopLimit
            ]
            ] as [String : Any]
        
        //making a post request
        Alamofire.request(URL_USER_CREATE, method: .post, parameters: userParameters, encoding: JSONEncoding.default).responseJSON {
            response in
            
            //getting the json value from the server
            if response.result.isSuccess {
                let jsonData : JSON = JSON(response.result.value!)
                
                //if there is no error
                if (!jsonData["error"].exists()) {
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true, completion:{
                        SVProgressHUD.setForegroundColor(UIColor(red:0.29, green:0.71, blue:0.26, alpha:1.0))
                        SVProgressHUD.showSuccess(withStatus: "User created. Please login.")
                    })
                } else {
                    SVProgressHUD.setForegroundColor(UIColor(red:0.65, green:0.20, blue:0.20, alpha:1.0))
                    SVProgressHUD.showInfo(withStatus: "Errors are below the form")
                    
                    if jsonData["error"]["code"].exists() && jsonData["error"]["code"].stringValue == "INVALID_PASSWORD" {
                    } else if jsonData["error"]["details"]["messages"]["email"].exists() {
                    }
                }
            }
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneButtonOnKeyboard()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        self.betweenStopLimitPicker.delegate = self
        self.betweenStopLimitPicker.dataSource = self
        
        self.betweenStopLimitPicker.selectRow(profile.betweenStopLimit, inComponent: 0, animated: false)
        validator.registerField(firstNameTextField, errorLabel: firstNameError, rules: [RequiredRule()])
        validator.registerField(lastNameTextField, errorLabel: lastNameError, rules: [RequiredRule()])
        validator.registerField(emailTextField, errorLabel: emailError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordTextField, errorLabel: passwordError, rules: [RequiredRule()])
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

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return profile.betweenStopLimitPickerData[0].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profile.betweenStopLimitPickerData[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        profile.betweenStopLimit = row
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Register User after button click.
    @IBAction func registerUser(_ sender: Any) {
        validator.validate(self)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
}
