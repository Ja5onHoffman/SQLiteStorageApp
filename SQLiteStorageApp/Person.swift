//
//  Person.swift
//  SQLiteStorageApp
//
//  Created by Jason Hoffman on 2/20/18.
//  Copyright © 2018 Jason Hoffman. All rights reserved.
//

import Foundation

// This class represents the person object that we're saving to the SQLite database
class Person {
    let id: String?
    var firstname: String?
    var lastname: String?
    var lat: Double?
    var long: Double?
    
    // Empty person initialization
    init() {
        self.id = "0"
        self.firstname = ""
        self.lastname = ""
        self.lat = 44.5
        self.long = -123.2
    }
    
    // Person initializer
    init(id: String, fn: String, ln: String, lat: Double, long: Double) {
        print("init")
        self.id = id
        self.firstname = fn
        self.lastname = ln
        self.lat = lat
        self.long = long
    }
}
