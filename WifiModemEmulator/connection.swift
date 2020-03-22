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
    
    func isActive() -> Bool {
        return true
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
