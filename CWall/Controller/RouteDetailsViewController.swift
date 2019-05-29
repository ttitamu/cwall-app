//
//  RouteDetailsViewController.swift
//  CWall
//
//  Created by Moughon, James on 5/29/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RouteDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var route: JSON?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableHeightConstraint.constant = tableView.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route!["sections"].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath)
        let section = JSON(route!["sections"][indexPath.row])
        let summary = NSMutableAttributedString(string: "")
        
        if (section["type"].string! == "street_network") {
            if (section["mode"].string! == "walking") {
                let walkAttachment = NSTextAttachment()
                walkAttachment.image = UIImage(named: "walk")
                walkAttachment.accessibilityLabel = "walking route"
                let walkString = NSAttributedString(attachment: walkAttachment)
                summary.append(walkString)
                summary.append(NSAttributedString(string: " from "))
            }
        }
        
        if (section["type"].string! == "public_transport") {
            let busAttachment = NSTextAttachment()
            busAttachment.image = UIImage(named: "bus")
            busAttachment.accessibilityLabel = "bus route"
            let busString = NSAttributedString(attachment: busAttachment)
            summary.append(busString)
            let busInfo = JSON(section["display_informations"])
            summary.append(NSAttributedString(string: " " + busInfo["label"].string!))
            summary.append(NSAttributedString(string: " > "))
        }
        
        let from = JSON(section["from"])
        let to = JSON(section["to"])
        
        summary.append(NSAttributedString(string: "\(from["name"].string!)"))
        summary.append(NSAttributedString(string: " to "))
        summary.append(NSAttributedString(string: "\(to["name"].string!)"))
        
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .full
        durationFormatter.allowedUnits = [.minute, .second]
        
        summary.append(NSAttributedString(string: " duration \(durationFormatter.string(from: TimeInterval(section["duration"].int!)) ?? "")"))
        
        cell.textLabel?.attributedText = summary
        return cell
    }
    
    
    
    @IBAction func closeDetails(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
}
