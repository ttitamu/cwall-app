//
//  MainTabBarViewController.swift
//  CWall
//
//  Created by Moughon, James on 1/9/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    let defaultValues = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func devLogin(_ sender: Any) {
        self.defaultValues.removeObject(forKey: "userId")
        self.defaultValues.removeObject(forKey: "userEmail")
        self.defaultValues.removeObject(forKey: "userToken")
        self.defaultValues.removeObject(forKey: "userValidDate")
        self.defaultValues.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation()))
        self.performSegue(withIdentifier: "devLoginSegue", sender: nil)
    }
}
