//
//  connection.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 AlessioPalma. All rights reserved.
//

import Foundation

class Connection {
    
    var hasChars: Bool {
        set { }
        get { return false }
    }
    func getSSID() -> String {
        "TODO"
    }
    func isActive() -> Bool {
        return true
    }
    func getPassword() -> String {
        return "*********"
    }
    func getChar() -> Character {
        return Character(" ")
    }
    func isConnected() -> Bool {
        return true
    }
    
    func putChars(_ buffer: String) {
    
    }
    
    func hasClient() -> Bool  {
        return false
    }
    func getAllChars() -> String {
        return "   "
    }
}
