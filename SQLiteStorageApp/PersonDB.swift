//
//  PersonDB.swift
//  SQLiteStorageApp
//
//  Created by Jason Hoffman on 2/20/18.
//  Copyright © 2018 Jason Hoffman. All rights reserved.
//

import Foundation
import SQLite

// This class represents the person SQLite database
class PersonDB {
    // All attributes private and must be set using methods provided
    private let people = Table("people")
    private let id = Expression<String>("id")
    private let firstname = Expression<String?>("firstname")
    private let lastname = Expression<String?>("lastname")
    private let lat = Expression<Double?>("lat")
    private let long = Expression<Double?>("long")
    
    // Initializes instance of DB
    static let instance = PersonDB()
    private let db: Connection?
    
    private init() {
        // Creates a path to the app's directories
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            // Connect do DB
            db = try Connection("\(path)/PersonDB.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    

    
    /*
     
     Creates a table. SQL instruction would be similar to:
     
     create table 'peopledb' if not exists (
     'id' text pimary key not null,
     'firstname' text,
     'lastname' text,
     'lat' real,
     'long' real
     )
    */
    
    func createTable() {
        do {
            try db!.run(people.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(firstname)
                table.column(lastname)
                table.column(lat)
                table.column(long)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    // Insert into 'persondb' ('id', 'firstname', 'lastname', 'lat', 'long') values (values here)
    func addPerson(pid: String, fn: String, ln: String, latt: Double, lon: Double) -> Int64? {
        do {
            
            let rid = try db!.run(people.insert(id <- createId()!, firstname <- fn, lastname <- ln, lat <- latt, long <- lon))
            return rid // Returning row ID, not person ID
        } catch {
            print("Insert failed")
            return nil
        }
    }

    
    // Return all people in DB as array
    // select * from 'peopledb'
    func getPeople() -> [Person] {
        // Init array with type Person
        var people = [Person]()

        do {
            // Get all people and append to array
            for person in try db!.prepare(self.people) {
                people.append(Person(
                    id:     person[id],
                    fn:     person[firstname]!,
                    ln:     person[lastname]!,
                    lat:    person[lat]!,
                    long:   person[long]!
                ))
            }
        } catch {
            print("Select failed")
        }
        
        // Return array
        return people
    }
    
    // Delete person from DB
    // delete from 'peopledb' where
    func deletePerson(pid: String) -> Bool {
        do {
            // select * from 'peopledb' where id =
            let person = people.filter(id == pid)
            try db!.run(person.delete()) // Delete
            return true
        } catch {
            print("delete failed")
        }
        
        return false
    }
    
    // Creates randomly generated id and return as string for
    // initializing IDs when people are created
    func createId() -> String? {
        var nums: [String] = []
        for _ in 0...5 {
            nums.append(String(arc4random_uniform(10)))
        }
        return nums.joined()
    }
}
