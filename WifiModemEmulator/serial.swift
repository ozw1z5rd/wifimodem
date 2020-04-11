//
//  Serial.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//
    
import Foundation

class Serial {
    
    /// Control flow supported by the serial
    enum FlowControl : String {
        case NONE = "None"
        case HARDWARE = "CTS/RTS"
        case SOFTWARE = "XON/XOFF"
        func asString() -> String {
            return self.rawValue
        }
    }
    
    /// Allowed baud rates, 19200 is still good for zx-spectrum, commodore 64 cannot go beyond 2400
    enum BaudRate : Int {
        case B300 = 300
        case B1200 = 1200
        case B2400 = 2400
        case B4800 = 4800
        case B9600 = 9600
        case B19200 = 19200
        case B38400 = 38400
        func asString() -> String {
            return String(self.rawValue)
        }
    }
    
    /// Polarity defines which Voltage is read as 0 and which one is read as 1, this required additional hardware
    /// on the raspberry.
    enum Polarity: String {
        case CBM = "CBM"
        case NORMAL = "NORMAL"
        func asString() -> String {
            return self.rawValue
        }
    }
    
    /// in NORMAL mode no translation is executed on incoming/outgoing bytes, if mode is CBM this modules will
    /// execute a translation of the incoming bytes
    enum ConversionMode: String {
        case CBM = "CBM"
        case NORMAL = "NORMAL"
        func asString() -> String {
            return self.rawValue
        }
    }
    
    private var _baudRate: BaudRate
    private var _conversionMode: ConversionMode
    private var _flowControl: FlowControl
    private var _polarity: Polarity
    
    var polarity: Polarity {
        set {
            self._polarity = newValue
        }
        get {
            return self._polarity
        }
    }
    
    var flowControlMode: FlowControl {
        set {
            self._flowControl = newValue
        }
        get {
            return self._flowControl
        }
    }

    var baudRate: BaudRate {
        set {
            self._baudRate = newValue
        }
        get {
            return self._baudRate
        }
    }
    
    var conversionMode: ConversionMode {
        set { self._conversionMode = newValue }
        get { return self._conversionMode }
    }
    
    /// this method returns true if there are charaters available inside the serial buffer
    func hasChars() -> Bool {
        return true
    }
    
    /// returns all the available charaters in the serial buffer as string
    func getAllChars() -> String {
        return ""
    }
    
    /// get a single character from the serial buffer
    func getChar() -> Character {
        return Character("\u{00}")
    }

    /// This method sends a single 8 bit char over the serial line
    /// - Parameter char: the charater to be send over the serial line.
    func putChar(_ char: Character) {
        
    }
    
    /// Send a string of 8 bit chars over the serial line
    /// - Parameter chars: The string of char to be sent over the serial line
    func putChars(_ chars: String) {
        
    }
    
    init() {
        Logger.info("Serial module is initializing")
        self._baudRate = .B300
        self._flowControl = .NONE
        self._conversionMode = .NORMAL
        self._polarity = .NORMAL
    }
}


