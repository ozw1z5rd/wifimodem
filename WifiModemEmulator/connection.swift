//
//  connection.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation

/// This module interfaces the wifimode to a TCP/IP Socket, it is also able to listen for incoming connection.
/// in this last case, the Commodore 64 must handle the incoming call otherwise the remote will establish the connection without getting any data
class Connection {
    
    /// If there are chars avaialable inside the TCP/IP buffer returns True.
    /// - Returns: true when the socket has data
    func hasChars() -> Bool {
        return true
    }
    
    func getSSID() -> String {
        return "TODO"
    }
    func isActive() -> Bool {
        return true
    }
    func getPassword() -> String {
        return "*********"
    }
    /// Get a single char from the Socket, if no data is available this function will wait for it
    /// - Returns: a single char
    func getChar() -> Character {
        return Character(" ")
    }
    /// Get all the available chars from the current Socket, this function will block if no data is available
    /// - Returns: return all the available chars in the Socket
    func getAllChars() -> String {
        return "   "
    }
    func isConnected() -> Bool {
        return true
    }
    func putChars(_ buffer: String) {
    
    }
    func getIpAddress() -> String {
        return "127.0.0.1"
    }
    func hasClient() -> Bool  {
        return false
    }

}
