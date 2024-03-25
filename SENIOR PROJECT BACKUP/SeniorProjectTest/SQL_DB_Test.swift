//
//  SQL_DB_Test.swift
//  SeniorProjectTest
//
//  Created by Gabriella Huegel on 2/24/24.
//

import Foundation
import SQLite
import UIKit

enum SideMenuOptionModel: Int, CaseIterable {
    case dashboard
    case pickTwo
    case burgers
    case settings
    
    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .pickTwo:
            return "Pick Two"
        case .burgers:
            return "Burgers"
        case .settings:
            return "Settings"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .dashboard:
            return "house"
        case .pickTwo:
            return "2.square"
        case .burgers:
            return "fork.knife"
        case .settings:
            return "gear"
        }
    }
}
extension SideMenuOptionModel: Identifiable {
    var id: Int { return self.rawValue }
}

class LoginController: ObservableObject {
    
    @Published var isSignedIn = false // changes view in real time
    @Published var name = ""
    @Published var email = ""
    
    @Published var foodList = [Food_Item]()
    @Published var calculationOrder = [Food_Item]()
    
    func addToCalc(item: Food_Item) {
        calculationOrder.append(item)
    }
    
    func removeFromCalc(item: Food_Item) {
        calculationOrder.removeAll { $0 == item }
    }
    
    func signOut() {
        self.isSignedIn = false
    }
    
    func resetPassword(username: String, newPassword: String, oldPassword: String) -> Bool {
        var success = false
        // Path to the SQLite database file
        let dbPath = Bundle.main.path(forResource: "mydatabase", ofType: "db")!
        do {
            // Establish a connection to the SQLite database
            let db = try Connection(dbPath)
            
            let users = Table("users")
            let storedUsername = Expression<String>("email")
            let storedPassword = Expression<String>("password")
            
            let userQuery = users.filter(username == storedUsername && storedPassword == oldPassword)
            
                
            if let user = try db.pluck(userQuery) {
                let updateUser = users.filter(username == storedUsername)
                        .update(storedPassword <- newPassword)
                try db.run(updateUser)
                
                success = true
            }
            
            
        } catch {
            print("Error: \(error)")
        }
        return success
    }
    
    func login(username: String, password: String) -> Bool {
        var success = true
        
        // Path to the SQLite database file
        let dbPath = Bundle.main.path(forResource: "mydatabase", ofType: "db")!
        do {
            // Establish a connection to the SQLite database
            let db = try Connection(dbPath)
            
            let users = Table("users")
            let storedUsername = Expression<String>("email")
            let storedPassword = Expression<String>("password")
            let storedName = Expression<String>("name")
            
            let query = users.select(storedName)
                .filter(storedUsername == username && storedPassword == password)
            
            let emailQuery = users.select(storedUsername)
            
            if let user = try db.pluck(query) {
                // Login successful
                success = true
                
                self.isSignedIn = true
                self.name = user[storedName]
                self.foodList = fetchFoodItems()
            }
            
            if let user2 = try db.pluck(emailQuery) {
                success = true
                
                self.email = user2[storedUsername]
            }
            
            
        } catch {
            print("Error: \(error)")
        }
        return success
    }//end login function
    
    //function to get weights in db
    func getWeights() {
        // Define your SQLite database connection
        do {
        let dbPath = Bundle.main.path(forResource: "mydatabase", ofType: "db")!
        let db = try Connection(dbPath)

        // Define table structure and columns
        let food_items = Table("food")
        let storedWeight = Expression<Double>("weight") // Assuming the 'weight' column is of type REAL in SQLite

        
            // Fetch a single row from the 'food_items' table
            for item in try db.prepare(food_items) {
                // Retrieve the 'weight' column value and cast it to Double
                let weight: Double = try item.get(storedWeight)
                
                // Now 'weight' contains the value of the 'weight' column as a Double
                print("Weight: \(weight)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
    // Function to fetch rows from SQLite database and store them in a list
    func fetchFoodItems() -> [Food_Item] {
        
        var foodItemList = [Food_Item]()
        
        do {
            // Path to the SQLite database file
            let dbPath = Bundle.main.path(forResource: "mydatabase", ofType: "db")!
            
            // Establish a connection to the SQLite database
            let db = try Connection(dbPath)
            
            // Define table structure and columns
            let food_items = Table("food")
            let storedFoodName = Expression<String>("name")
            let storedRestaurant = Expression<String>("restaurant")
            let storedWeight = Expression<Double>("weight")
            let storedPoints = Expression<Double>("pointValue")
            
            // Fetch all rows from the 'food_items' table
            for item in try db.prepare(food_items) {
                // Create Food_Item instance for each row and append to foodItemList
                let foodItem = Food_Item(name: item[storedFoodName],
                                         rest: item[storedRestaurant],
                                         weight: item[storedWeight],
                                         id: item[storedPoints],
                                         imageName: item[storedFoodName])
                foodItemList.append(foodItem)
            }
        } catch {
            print("Error: \(error)")
        }
        return foodItemList
    }




    func getAllTables() {
        // Path to the SQLite database file
        let dbPath = Bundle.main.path(forResource: "mydatabase", ofType: "db")!
        
        do {
            // Establish a connection to the SQLite database
            let db = try Connection(dbPath)
            
            // Define table structure and columns
            let users = Table("users")
            let name = Expression<String>("name")
            let items = Table("food_items")
            let food_name = Expression<String>("name")
            
            // Fetch all rows from the 'users' table and print them to the console
            for user in try db.prepare(users) {
                print("Name: \(user[name])")
            }
            for item in try db.prepare(items) {
                print("Item: \(item[food_name])")
            }
        } catch {
            print("Error: \(error)")
        }
    }// end get all tables func
}//end of class
