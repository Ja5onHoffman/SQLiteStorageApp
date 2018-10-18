//
//  ViewController.swift
//  SQLiteStorageApp
//
//  Created by Jason Hoffman on 2/20/18.
//  Copyright © 2018 Jason Hoffman. All rights reserved.
//

import UIKit
import SQLite3
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    
    var people = [Person]()
    let locationManager = CLLocationManager()
    var location: CLLocation!
    let numFormatter = NumberFormatter()
    var lat: Double!
    var lon: Double!
    
    @IBOutlet weak var fn: UITextField!
    @IBOutlet weak var ln: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self  // Set up tableView delegate
        locationManager.delegate = self // Set up CLLocationManager delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // High accuracy
        people = PersonDB.instance.getPeople()  // Get array of people from database for use in table
        
        // If locationManager status is unknown, request authorization
        if CLLocationManager.locationServicesEnabled() {
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined {
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        } else {
            print("locationServices disabled")
        }
        
        loadData()
    }
    
    // Action to run when 'save' button is clicked
    @IBAction func savePerson(_ sender: Any) {
        let person = Person() // Init empty person
        // Get data from text fields
        person.firstname = fn.text
        person.lastname = ln.text
        // If location then set person location
        if let location = locationManager.location {
            person.lat = location.coordinate.latitude
            person.long = location.coordinate.longitude
        } else {  // Else set to default location
            person.lat = 44.5
            person.long = -123.2
        }
        
        // Add Person to table
        let _: Int64 = PersonDB.instance.addPerson(pid: person.id!, fn: fn.text!, ln: ln.text!, latt: person.lat!, lon: person.long!)!
        
        // Reest text field
        fn.text = ""
        ln.text = ""
        
        // Reload everything
        loadData()
    }
    
    // This function gets fresh data from the database and
    // refreshes the tableView
    func loadData() {
        do {
            try people = PersonDB.instance.getPeople()
        } catch {
            print("Could not load data")
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        
        self.tableView.reloadData()
    }
    
    
    //MARK: tableView delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count // Number of cells should equal number of people in array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        numFormatter.maximumFractionDigits = 10
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        // For each row in tableView, get corresponding person by index from array
        let person: Person? = people[indexPath.row]
        
        // Set text in cell to person name
        if let fn = person?.firstname, let ln = person?.lastname {
            cell.textLabel?.text = fn + " " + ln
        }
        
        // Set location in cell
        if let latt = numFormatter.string(from: NSNumber(value: (person?.lat)!)), let lon = numFormatter.string(from: NSNumber(value: (person?.long)!)) {
            cell.detailTextLabel?.text = "Location " + latt + " " + lon
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // This handles deletion of items in the tableView
        if editingStyle == .delete {
            // Get person by index of selected row
            let person = people[indexPath.row]
            tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)  // Delete row
            PersonDB.instance.deletePerson(pid: person.id!) // Delete person from database
            people.remove(at: indexPath.row) // Remove from array
            tableView.endUpdates()
            
            loadData() // loadData() calls tableView.reloadData()
        }
    }
    
    //MARK: Location manager delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Required but not used
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

