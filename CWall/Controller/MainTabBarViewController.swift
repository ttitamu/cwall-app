//
//  MainTabBarViewController.swift
//  CWall
//
//  Created by Moughon, James on 1/9/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
}
