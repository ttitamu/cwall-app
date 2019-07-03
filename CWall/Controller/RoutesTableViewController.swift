//
//  RoutesTableViewController.swift
//  CWall
//
//  Created by Moughon, James on 5/23/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RoutesTableViewController: UITableViewController {
    var loadingData = true
    var planner: Planner?
    var routes: [AnyObject] = []
    let JOURNEY_URL = "http://13.65.39.139/url/coverage/default/journeys"
    
    private var routesController:RoutesTableViewController!
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "\(planner?.from?.name ?? "") to \(planner?.to?.name ?? "")"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"

        //getting the username and password
        let parameters: Parameters = [
            "from": "\(planner!.from!.location!.coordinate.longitude);\(planner!.from!.location!.coordinate.latitude)",
            "to": "\(planner!.to!.location!.coordinate.longitude);\(planner!.to!.location!.coordinate.latitude)",
            "datetime": dateFormatter.string(from: planner!.date!),
            "datetime_represents": planner!.dateRepresents
        ]
        
        //making a post request
        if (loadingData) {
            Alamofire.request(JOURNEY_URL, method: .get, parameters: parameters).responseJSON {
                response in

                //getting the json value from the server
                if response.result.isSuccess {
                    let jsonData : JSON = JSON(response.result.value!)
                    if jsonData["journeys"].exists() {
                        for (_, journey) in jsonData["journeys"] {
                            self.routes.append(journey as AnyObject)
                        }
                        
                        self.loadingData = false
                        self.tableView?.reloadData()
                    } else {
                        self.loadingData = false
                        self.tableView?.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "routeDetails") {
            let selectedItemPath = tableView.indexPathForSelectedRow
            let route = routes[selectedItemPath?.row ?? 0]
            let destinationViewController = segue.destination as! RouteDetailsViewController
            destinationViewController.route = JSON(route)
            destinationViewController.planner = planner
        }
    }
}

extension RoutesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard loadingData == false else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Fetching route options..."
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            return cell
        }
        
        guard routes.count > 0 else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No Routes found."
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath)
        let route = JSON(routes[indexPath.row])
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyyMMdd'T'HHmmss"
        let depart = dateFormatter.string(from: dateFormatter2.date(from: route["departure_date_time"].string!)!)
        let arrive = dateFormatter.string(from: dateFormatter2.date(from: route["arrival_date_time"].string!)!)
        let summary = NSMutableAttributedString(string: "\(depart) > ")
        
        for (_, section) in route["sections"] {
            let leg = JSON(section)
            
            if (leg["type"].string! == "street_network") {
                if (leg["mode"].string! == "walking") {
                    let walkAttachment = NSTextAttachment()
                    walkAttachment.image = UIImage(named: "walk")
                    walkAttachment.accessibilityLabel = "walking route"
                    let walkString = NSAttributedString(attachment: walkAttachment)
                    summary.append(walkString)
                    summary.append(NSAttributedString(string: " > "))
                }
            }
            
            if (leg["type"].string! == "public_transport") {
                let busAttachment = NSTextAttachment()
                busAttachment.image = UIImage(named: "bus")
                busAttachment.accessibilityLabel = "bus route"
                let busString = NSAttributedString(attachment: busAttachment)
                summary.append(busString)
                let busInfo = JSON(leg["display_informations"])
                summary.append(NSAttributedString(string: " " + busInfo["label"].string!))
                summary.append(NSAttributedString(string: " > "))
            }
        }
        
        summary.append(NSAttributedString(string: "\(arrive)"))
        cell.detailTextLabel?.attributedText = summary
        
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .full
        durationFormatter.allowedUnits = [.minute, .second]

        cell.textLabel?.text = "\(NSLocalizedString(route["type"].string!, comment: route["type"].string!)): \(durationFormatter.string(from: TimeInterval(route["duration"].int!)) ?? "")"
        return cell
    }
}
