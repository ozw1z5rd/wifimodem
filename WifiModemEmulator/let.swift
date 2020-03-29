//
//  led.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 29/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation


class Led {
    
    enum Unit : String  {
        case TX = "SEND DATA"
        case RX = "RECEIVE DATA"
        case CONNECTED = "CONNECTED"
        case CD = "CARRIER DECTED"
        case RI = "RING"
        case FLOWCTRL_SOFT = "XON/XOFF"
        case FLOWCTRL_HARD = "CTS/RTS"
        case MR = "MODEM READY"
        case RS = "REQUEST TO SEND"
        case CS = "CLEAR TO SEND"
        case TR = "READY"
        case OH = "OFF HOCK"
        case AA = "AUTO ANSWER"
        
        func asString() -> String {
            return self.rawValue
        }
    }
    
    enum Status : Int {
        case ON = 1
        case OFF = 0
        func asString() -> String {
            return self.rawValue == 1 ? "ON" : "OFF"
        }
    }
        
    private var state: [Unit: Status] = [:]
    
    func write(_ unit: Unit, _ status: Status) {
        Logger.info("Let \(unit.asString()) set to \(status.asString())")
        self.state[unit] = status
    }
    
    func read(_ unit: Unit) -> String {
        // there is not risk that this code can fail
        return self.state[unit]!.asString()
    }
    
    /// Initialize the LEDS ( all off but RT )
    func initialize() {
        write(.TX, .OFF)
        write(.RX, .OFF)
        write(.CONNECTED, .OFF)
        write(.CD, .OFF)
        write(.RI, .OFF)
        write(.FLOWCTRL_SOFT, .OFF)
        write(.FLOWCTRL_HARD, .OFF)
        write(.MR, .OFF)
        write(.RS, .OFF)
        write(.CS, .OFF)
        write(.TR, .OFF)
        write(.OH, .OFF)
        write(.AA, .OFF)
    }
}
