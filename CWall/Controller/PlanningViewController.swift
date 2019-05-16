//
//  PlanningViewController.swift
//  CWall
//
//  Created by Moughon, James on 12/18/18.
//  Copyright © 2018 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import CoreLocation

class PlanningViewController: UIViewController, UITextFieldDelegate {
    public var from: CLPlacemark!
    public var to: CLPlacemark!
    private var whichSearch = ""
    let defaultValues = UserDefaults.standard
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fromRaw = defaultValues.value(forKey: "fromLocation")
        let toRaw = defaultValues.value(forKey: "toLocation")

        if fromRaw != nil {
            from = NSKeyedUnarchiver.unarchiveObject(with: fromRaw as! Data) as? CLPlacemark
            self.fromTextField.text = "\(from.name!), \(from.postalAddress?.street ?? ""), \(from.postalAddress?.city ?? ""), \(from.postalAddress?.state ?? "")"
        }
        
        if toRaw != nil {
            to = NSKeyedUnarchiver.unarchiveObject(with: toRaw as! Data) as? CLPlacemark
            self.toTextField.text = "\(to.name!), \(to.postalAddress?.street ?? ""), \(to.postalAddress?.city ?? ""), \(to.postalAddress?.state ?? "")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromTextField.delegate = self
        self.toTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSearch" {
            let navViewControllers = segue.destination as! UINavigationController
            let destinationViewController = navViewControllers.viewControllers[0] as! SearchResultTableViewController
            
            destinationViewController.which = whichSearch
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "from" {
            whichSearch = "from"
        } else if textField.accessibilityIdentifier == "to" {
            whichSearch = "to"
        }
        
        self.performSegue(withIdentifier: "locationSearch", sender: self)
    }
}
