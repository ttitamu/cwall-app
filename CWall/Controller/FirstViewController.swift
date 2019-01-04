//
//  FirstViewController.swift
//  CWall
//
//  Created by Moughon, James on 12/18/18.
//  Copyright © 2018 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target: self, action: #selector(FirstViewController.addTapped))
        self.tabBarController?.navigationItem.title = "test"
    }
    
    @objc func addTapped (sender:UIButton) {
        if let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") {
            self.navigationController?.pushViewController(profileViewController, animated: true)
            
            self.dismiss(animated: false, completion: nil)
        }
    }

}
