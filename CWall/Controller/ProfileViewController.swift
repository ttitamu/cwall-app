//
//  ProfileViewController.swift
//  CWall
//
//  Created by Moughon, James on 1/4/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import QuickTableViewController

internal final class ProfileViewController: QuickTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.text = "QuickTableViewController"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        title = " "
        navigationItem.titleView = titleLabel
        
        tableContents = [
            Section(title: "Default", rows: [
                NavigationRow(text: "Use default cell types", detailText: .none, action: { [weak self] _ in
                    self?.navigationController?.pushViewController(DefaultSettingsViewController(), animated: true)
                })
            ])
        ]
    }
    
}
