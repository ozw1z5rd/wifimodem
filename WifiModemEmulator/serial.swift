//
//  Serial.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 AlessioPalma. All rights reserved.
//
    
import Foundation
import os

class Serial {
    
    enum flowControl : Int {
        case NONE = 0
        case HARDWARE = 1
        case SOFTWARE = 2
    }
    
    enum BaudRate : Int {
        case B300 = 300
        case B1200 = 1200
        case B2400 = 2400
        case B4800 = 4800
        case B9600 = 9600
        case B19200 = 19200
    }
    
    enum Polarity: String {
        case CBM, NORMAL
    }
    
    private var _hasChar: Int
    private var _baudRate: BaudRate
    private var _petMode: Bool
    private var _flowControl: flowControl
    
    var hasChars: Bool {
        set { }
        get { return self._hasChar > 0}
    }
    
    func getAllChars() -> String {
        return ""
    }
    
    func getChar() -> Character {
        return Character("")
    }
    
    func putChar(_ char: Character) {
        
    }
    
    func putChars(_ chars: String) {
        
    }
    
    func setBaudRate(rate: BaudRate) -> BaudRate {
        return self._baudRate
    }
    
    func setFlowControl(mode: flowControl) -> flowControl {
        return self._flowControl
    }
    
    func setPolarity(mode: Polarity) {
        
    }
    func getBaudRateAsString() -> BaudRate {
        return Serial.BaudRate(rawValue: 300)!
    }
    
    init() {
        self._hasChar = 0
        self._baudRate = BaudRate.B300
        self._petMode = false
        self._flowControl = Serial.flowControl.NONE
    }
}


