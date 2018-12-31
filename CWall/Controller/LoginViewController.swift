//
//  LogInViewController.swift
//  CWall
//
//  This is the view controller where users login


import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    //The login script url make sure to write the ip instead of localhost
    //you can get the ip using ifconfig command in terminal
    let URL_USER_LOGIN = "http://localhost:3000/api/users/login"

    //the defaultvalues to store user data
    let defaultValues = UserDefaults.standard

    //Textfields pre-linked with IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextLabel: UILabel!
    
    //MARK: - Login Button Action
    /***************************************************************/
    
    @IBAction func loginButton(_ sender: UIButton) {
        //reset login error
        loginTextLabel.text = "";
        
        //getting the username and password
        let parameters: Parameters=[
            "email":emailTextField.text!,
            "password":passwordTextField.text!
        ]

        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
                response in

                //getting the json value from the server
                if response.result.isSuccess {
                    let jsonData : JSON = JSON(response.result.value!)

                    //if there is no error
                    if (!jsonData["error"].exists()) {

                        //getting user values
                        let userId =  jsonData["userId"].stringValue
                        let userEmail = self.emailTextField.text
                        let userToken = jsonData["id"].stringValue
                        let userTokenCreated = jsonData["created"].stringValue
                        let userTokenTTL = jsonData["ttl"].stringValue

                        //saving user values to defaults
                        self.defaultValues.set(userId, forKey: "userId")
                        self.defaultValues.set(userEmail, forKey: "userEmail")
                        self.defaultValues.set(userToken, forKey: "userToken")
                        self.defaultValues.set(userTokenCreated, forKey: "userTokenCreated")
                        self.defaultValues.set(userTokenTTL, forKey: "userTokenTTL")

                        //switching the screen
                        if let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") {
                            self.navigationController?.pushViewController(mainTabBarController, animated: true)

                            self.dismiss(animated: false, completion: nil)
                        }
                    } else {
                        //error message in case of invalid credential
                        self.loginTextLabel.text = "Invalid username or password"
                    }
                }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
