//
//  LocationSearchTableViewController.swift
//  CWall
//
//  Created by Moughon, James on 5/31/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit
import MapboxGeocoder
import CoreLocation

class LocationSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var planner: Planner?
    let geocoder = Geocoder.shared
    var locationManager: LocationManager!
    
    @IBOutlet var tableView: UITableView!
    
    var searchBar: UISearchBar?
    var searchActive : Bool = false
    var searchedPlaces: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.searchBar == nil {
            self.searchBar = UISearchBar()
            self.searchBar!.searchBarStyle = UISearchBar.Style.prominent
            self.searchBar!.delegate = self
            self.searchBar!.placeholder = "Search for place";
        }
        
        self.navigationItem.titleView = searchBar
        
        let options = ReverseGeocodeOptions(location: locationManager!.currentLocation!)
        
        geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            placemark.name = "Current Location: " + placemark.name
            self.searchedPlaces.add(placemark)
            self.tableView.reloadData()
        }
        
        if planner?.which == "from" && planner?.from != nil{
            if (planner?.from?.genres == nil) {
                self.searchBar!.text = planner?.from?.qualifiedName
            } else {
                self.searchBar!.text = planner?.from?.name
            }
            self.searchBar!.setShowsCancelButton(true, animated: true)
            self.searchMe()
        } else if planner?.which == "to" && planner?.to != nil {
            if (planner?.to?.genres == nil) {
                self.searchBar!.text = planner?.to?.qualifiedName
            } else {
                self.searchBar!.text = planner?.to?.name
            }
            
            self.searchBar!.setShowsCancelButton(true, animated: true)
            self.searchMe()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchMe), object: nil)
        self.perform(#selector(self.searchMe), with: nil, afterDelay: 0.5)
        if(searchBar.text!.isEmpty){
            searchActive = false;
            if (self.searchedPlaces.count > 1) { self.searchedPlaces.removeObjects(in: NSMakeRange(1, self.searchedPlaces.count - 1)) }
            self.tableView.reloadData()
        } else {
            searchActive = true;
        }
    }
    
    @objc func searchMe() {
        if(searchBar?.text!.isEmpty)!{ } else {
            if (self.searchedPlaces.count > 1) { self.searchedPlaces.removeObjects(in: NSMakeRange(1, self.searchedPlaces.count - 1)) }
            self.tableView.reloadData()
            self.searchPlaces(query: (searchBar?.text)!)
        }
    }
    
    @objc func searchPlaces(query: String) {
        guard let locValue: CLLocationCoordinate2D = locationManager?.currentLocation?.coordinate else { return }
        let options = ForwardGeocodeOptions(query: query)
        
        // To refine the search, you can set various properties on the options object.
        options.allowedISOCountryCodes = ["US"]
        options.focalLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        options.maximumResultCount = 10
        options.allowedScopes = [.address, .pointOfInterest]
        
        let texasNortheastCorner = CLLocationCoordinate2D(latitude: 36.451097, longitude: -93.599244)
        let texasSouthwestCorner = CLLocationCoordinate2D(latitude: 25.5417, longitude: -106.874509)
        let texasRegion = RectangularRegion(southWest: texasSouthwestCorner, northEast: texasNortheastCorner)
        
        options.allowedRegion = texasRegion
        
        geocoder.geocode(options) { (placemarks, attribution, error) in
            for place in placemarks ?? [] {
                self.searchedPlaces.add(place)
            }

            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath)
        let pred = self.searchedPlaces.object(at: indexPath.row) as! Placemark

        cell.textLabel?.text = pred.name
        cell.detailTextLabel?.text = pred.qualifiedName
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "planning") {
            guard let selectedItemPath = tableView.indexPathForSelectedRow else { return }
            let place = self.searchedPlaces[selectedItemPath.row] as! Placemark
            let navViewControllers = segue.destination as! UITabBarController
            let destinationViewController = navViewControllers.viewControllers?[0] as! PlanningViewController
            
            if planner?.which == "from" {
                planner?.from = place
            } else if planner?.which == "to" {
                planner?.to = place
            }
            
            destinationViewController.planner = planner
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearching()
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }
    
    func cancelSearching(){
        searchActive = false;
        self.searchBar!.resignFirstResponder()
        self.searchBar!.text = ""
        self.dismiss(animated: true, completion:nil)
    }
}
