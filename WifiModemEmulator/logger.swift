//
//  logger.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 28/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation

/// This class is a wrapper over the available logging system, it is required because this code is supposed
/// to run on a raspberry
class Logger {
    static func println(_ msg: String) {
        print("wifimodem - \(msg)")
    }
    static func info(_ msg: String) {
        Logger.println(msg)
    }
    static func error(_ msg: String) {
        Logger.println(msg)
    }
    static func warn(_ msg: String){
        Logger.println(msg)
    }
}
