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
        self.tabBarController?.navigationItem.hidesBackButton = true
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
