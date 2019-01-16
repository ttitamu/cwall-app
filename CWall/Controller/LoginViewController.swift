//
//  LogInViewController.swift
//  CWall
//
//  This is the view controller where users login


import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class LoginViewController: UIViewController {
    let URL_USER_LOGIN = "http://localhost:3000/api/users/login?include=user"

    //the defaultvalues to store user data
    let defaultValues = UserDefaults.standard

    //Textfields pre-linked with IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextLabel: UILabel!

    //MARK: - Login Button Action
    /***************************************************************/

    @IBAction func loginButton(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Logging In")
        //reset login error
        loginTextLabel.text = "";

        //getting the username and password
        let parameters: Parameters = [
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
                        let userId =  jsonData["userId"].int!
                        let userEmail = self.emailTextField.text
                        let userToken = jsonData["id"].stringValue
                        let userTokenTTL = jsonData["ttl"].double!
                        let userTokenCreatedRaw = jsonData["created"].stringValue

                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                        let date = dateFormatter.date(from: userTokenCreatedRaw)!
                        let userValidDate = date.addingTimeInterval(userTokenTTL)

                        let profile: [String: Any] = [
                            "userId": userId,
                            "userEmail": userEmail!,
                            "firstName": jsonData["user"]["profile"]["firstName"].stringValue,
                            "lastName": jsonData["user"]["profile"]["lastName"].stringValue,
                            "wheelchair": jsonData["user"]["profile"]["wheelchair"].boolValue,
                            "visualImpairment": jsonData["user"]["profile"]["visualImpairment"].boolValue,
                            "hapticFeedback": jsonData["user"]["profile"]["hapticFeedback"].boolValue,
                            "hapticFeedbackHelp": jsonData["user"]["profile"]["hapticFeedbackHelp"].boolValue,
                            "betweenStopLimit": jsonData["user"]["profile"]["betweenStopLimit"].intValue
                        ];

                        //saving user values to defaults
                        self.defaultValues.set(userId, forKey: "userId")
                        self.defaultValues.set(userEmail, forKey: "userEmail")
                        self.defaultValues.set(userToken, forKey: "userToken")
                        self.defaultValues.set(userValidDate, forKey: "userValidDate")
                        self.defaultValues.set(profile, forKey: "profile")
                        self.defaultValues.synchronize()

                        SVProgressHUD.dismiss()

                        //switching the screen
                        self.performSegue(withIdentifier: "mainTabBarSegue", sender: nil)
                    } else {
                        SVProgressHUD.setForegroundColor(UIColor(red:0.65, green:0.20, blue:0.20, alpha:1.0))
                        SVProgressHUD.showInfo(withStatus: "Invalid username or password")
                        //error message in case of invalid credential
                        self.loginTextLabel.text = "Invalid username or password"
                    }
                }
        }
    }

    //MARK: - Forgot Password Button Action
    /***************************************************************/

    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        performSegue(withIdentifier: "forgotPasswordSegue", sender: sender)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userValidDate = UserDefaults.standard.object(forKey: "userValidDate") as? Date ?? Date()
        let date = Date()

        // if logged in
        if date < userValidDate {
            //switching the screen
            self.performSegue(withIdentifier: "mainTabBarSegue", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
