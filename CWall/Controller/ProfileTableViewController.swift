//
//  ProfileTableViewController.swift
//  CWall
//
//  Created by Moughon, James on 1/9/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ProfileTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var changePasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var wheelchairSwitch: UISwitch!
    @IBOutlet weak var visualImpairmentSwitch: UISwitch!
    @IBOutlet weak var betweenStopLimitPicker: UIPickerView!
    @IBOutlet weak var hapticFeedbackSwitch: UISwitch!
    @IBOutlet weak var hapticFeedbackHelpSwitch: UISwitch!
    @IBOutlet weak var errorTableCell: UITableViewCell!
    @IBOutlet weak var errorTextField: UILabel!

    let profile = ProfileModel(dict: UserDefaults.standard.dictionary(forKey: "profile")!);

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.firstNameTextField.text = profile.firstName
        self.lastNameTextField.text = profile.lastName
        self.emailTextField.text = profile.userEmail
        self.wheelchairSwitch.setOn(profile.wheelchair, animated: false)
        self.visualImpairmentSwitch.setOn(profile.visualImpairment, animated: false)
        self.betweenStopLimitPicker.selectRow(profile.betweenStopLimit, inComponent: 0, animated: false)
        self.hapticFeedbackSwitch.setOn(profile.hapticFeedback, animated: false)
        self.hapticFeedbackHelpSwitch.setOn(profile.hapticFeedbackHelp, animated: false)        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.betweenStopLimitPicker.delegate = self
        self.betweenStopLimitPicker.dataSource = self
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
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveProfile(_ sender: Any) {
        let URL_USER_UPDATE = "http://13.65.39.139/api/users/" + String(profile.userId)
        
        SVProgressHUD.show(withStatus: "Saving Profile")
        var userParameters = [String: Any]()

        if profile.firstName != self.firstNameTextField.text {
            if userParameters["_profile"] != nil {
                userParameters["_profile"] = [String: Any]()
            }
//            userParameters["_profile"]?["firstName"] = self.firstNameTextField.text!
        }

       //making a post request
       Alamofire.request(URL_USER_UPDATE, method: .put, parameters: userParameters, encoding: JSONEncoding.default).responseJSON {
           response in

           //getting the json value from the server
           if response.result.isSuccess {
               let jsonData : JSON = JSON(response.result.value!)

               //if there is no error
               if (!jsonData["error"].exists()) {
                   self.errorTableCell.isHidden = true
                   SVProgressHUD.dismiss()
                   self.dismiss(animated: true, completion:{
                       SVProgressHUD.setForegroundColor(UIColor(red:0.29, green:0.71, blue:0.26, alpha:1.0))
                       SVProgressHUD.showSuccess(withStatus: "User created. Please login.")
                   })
               } else {
                   SVProgressHUD.setForegroundColor(UIColor(red:0.65, green:0.20, blue:0.20, alpha:1.0))
                   SVProgressHUD.showInfo(withStatus: "Errors are below the form")
                   self.errorTableCell.isHidden = false

                   if jsonData["error"]["code"].exists() && jsonData["error"]["code"].stringValue == "INVALID_PASSWORD" {
                       self.errorTextField.text = jsonData["error"]["message"].stringValue
                   } else if jsonData["error"]["details"]["messages"]["email"].exists() {
                       self.errorTextField.text = "Email \(jsonData["error"]["details"]["messages"]["email"][0].stringValue)"
                   }
               }
           }
       }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }

}
