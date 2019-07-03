//
//  PlanningViewController.swift
//  CWall
//
//  Created by Moughon, James on 12/18/18.
//  Copyright © 2018 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import MapboxGeocoder
import CoreLocation
import SwiftValidator
import SVProgressHUD

struct Planner {
    var from: Placemark?
    var to: Placemark?
    var dateRepresents: String
    var date: Date?
    var which: String
}

class PlanningViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    var planner: Planner?
    var datePicker = UIDatePicker()
    let validator = Validator()

    @IBOutlet private var locationManager: LocationManager!
    private var locationManagerObserver: NSKeyValueObservation?
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var dateRepresents: UISegmentedControl!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var fromError: UILabel!
    @IBOutlet weak var toError: UILabel!
    @IBOutlet weak var dateError: UILabel!
    @IBOutlet weak var helpText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        locationManagerObserver = locationManager.observe(\LocationManager.currentLocation) { [weak self] (_, _) in
            if (self?.locationManager.currentLocation) != nil {
                // This sample only searches for nearby locations, defined by the device's location. Once the current location is
                // determined, enable the search functionality.
                
                SVProgressHUD.dismiss()
                self?.fromTextField.isUserInteractionEnabled = true
                self?.toTextField.isUserInteractionEnabled = true
                self?.fromTextField.alpha = 1.0
                self?.toTextField.alpha = 1.0
            }
        }
        
        let name = UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self?.locationManager.requestLocation()
        })
    }

    @IBAction func fromTouch(_ sender: UITextField) {
        planner?.which = "from"
        self.performSegue(withIdentifier: "locationSearch", sender: self)
    }
    
    @IBAction func toTouch(_ sender: UITextField) {
        planner?.which = "to"
        self.performSegue(withIdentifier: "locationSearch", sender: self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    @IBAction func dateFieldEditing(_ sender: UITextField) {
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.minimumDate = Date()
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        sender.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PlanningViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(PlanningViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .short
        date.text = dateFormatter1.string(from: datePicker.date)
        date.resignFirstResponder()
        planner?.date = datePicker.date
    }
    
    @objc func cancelClick() {
        date.resignFirstResponder()
    }
    
    func validationSuccessful() {
        self.performSegue(withIdentifier: "findRoutes", sender: self)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Trip Planner"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (locationManager.currentLocation == nil) {
            locationManager.requestLocation()
            SVProgressHUD.show(withStatus: NSLocalizedString("LOCATION_SERVICES_WAITING", comment: "Acquiring current location"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fromTextField.delegate = self
        self.toTextField.delegate = self
        
        if planner == nil {
            planner = Planner(from: nil, to: nil, dateRepresents: "departure", date: nil, which: "")
        }

        if planner?.from != nil {
            self.fromTextField.text = planner?.from?.qualifiedName
        }
        
        if planner?.to != nil {
            self.toTextField.text = planner?.to?.qualifiedName
        }
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .short
        
        if planner?.date == nil {
            planner?.date = Date()
        }
        
        date.text = dateFormatter1.string(from: planner!.date!)
        
        
        validator.registerField(fromTextField, errorLabel: fromError, rules: [RequiredRule()])
        validator.registerField(toTextField, errorLabel: toError, rules: [RequiredRule()])
        validator.registerField(date, errorLabel: dateError, rules: [RequiredRule()])
        validator.styleTransformers(success: {
            (validationRule) -> Void in
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderWidth = 0
            }
            if let errorLabel = validationRule.errorLabel {
                errorLabel.text = ""
                errorLabel.isHidden = true
            }
        }, error:  {
            (validationError) -> Void in
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
            if let errorLabel = validationError.errorLabel {
                errorLabel.text = validationError.errorMessage // works if you added labels
                errorLabel.isHidden = false
            }
        })
    }
    
    @IBAction func dateRepresentsToggle(_ sender: Any) {
        if dateRepresents.selectedSegmentIndex == 0 {
            planner?.dateRepresents = "departure"
        } else if dateRepresents.selectedSegmentIndex == 1 {
            planner?.dateRepresents = "arrival"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSearch" {
            let navViewControllers = segue.destination as! UINavigationController
            let destinationViewController = navViewControllers.viewControllers[0] as! LocationSearchTableViewController
            destinationViewController.planner = planner
            destinationViewController.locationManager = locationManager
        } else if segue.identifier == "findRoutes" {
            let destinationViewController = segue.destination as! RoutesTableViewController
            destinationViewController.planner = planner
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.accessibilityIdentifier == "from" {
            planner?.from = nil
        } else if textField.accessibilityIdentifier == "to" {
            planner?.to = nil
        }
        
        textField.text = ""
        textField.resignFirstResponder()
        
        return false
    }
    
    @IBAction func switchClick(_ sender: Any) {
        let toOrig = planner?.to
        let fromOrig = planner?.from
        
        planner?.from = toOrig
        planner?.to = fromOrig
        
        if planner?.from != nil {
            self.fromTextField.text = planner?.from?.qualifiedName
        } else {
            self.fromTextField.text = ""
        }
        
        if planner?.to != nil {
            self.toTextField.text = planner?.to?.qualifiedName
        } else {
            self.toTextField.text = ""
        }
    }
    
    @IBAction func findRoutesButton(_ sender: Any) {
        validator.validate(self)
    }
}

extension PlanningViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
}
