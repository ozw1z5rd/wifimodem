//
//  WifiModem.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 AlessioPalma. All rights reserved.
//

import Foundation


enum ledName : String  {
    case TX, RX, CONNECTED, RI
}

enum ledStatus : String {
    case ON, OFF
}

enum message : String {
    case OK = "OK\n", ERROR = "ERROR/n"
}

class WifiModemEmulator {
    let serial: Serial
    let display: Display
    let connection: Connection
    var cmdMode: Bool
    var polarity: Serial.Polarity = Serial.Polarity.NORMAL
    var flowControl: Serial.flowControl
    var verbosity: Bool = false
    var telnet: Bool = false
    var echo: Bool = false
    
    var atCommand: String
    var echoActive: Bool
    let ATCMD_MAX_LENGTH = 128
    let ATCMD_ESCAPE_SEQ = "+++"
    
    let MESSAGE_HELP = ""
    
    init(virtualSerial: Serial, virtualDisplay: Display) {
        self.serial = Serial()
        self.display = Display()
        self.cmdMode = false
        self.atCommand = ""
        self.echoActive = true
        self.flowControl = Serial.flowControl.NONE
        self.connection = Connection()
    }
    
    func led(name: ledName, status: ledStatus) {
        print("Setting \(name) to \(status)")
    }
    
    func updateDisplay() {
        self.display.visualize(textContent: "Nothing to display")
    }
    
    func handleFlowControl() {
        
    }
    
    func answerCall()  {
    
    }
    
    func connectWifi() {
        
    }
    
    func disconnectWifi() {
        
    }
    
    func checkButtons() {
        
    }
    
    func callConnected() {
        
    }
    
    func readSettings () {
        
    }
    
    func reply(message: message) {
        
    }
    
    func setCarrier(_ x: Any ) {
        
    }
    func processATCommand() {
        self.atCommand.trimmingCharacters(in: .newlines)
        if self.atCommand == ""  {
            return
        }
        let upCmd = self.atCommand.uppercased()
        switch upCmd {
        case "AT":
            self.reply(message: message.OK)
    
        case "ATNET0":
            self.telnet = false
            self.reply(message: message.OK)
            
        case "ATNET1":
            self.telnet = true
            self.reply(message: message.OK)
            
        case "ATNET?":
            self.serial.putChars(String(self.telnet))
            self.reply(message: message.OK)
            
        case "ATA":
            if self.connection.hasClient() {
                self.answerCall()
            }
    
        case "AT?":
            self.serial.putChars(self.MESSAGE_HELP)
            self.reply(message: message.OK)
            
        case "ATZ":
            self.readSettings()
            self.reply(message: message.OK)
            
        case "AT$C0":
            self.disconnectWifi()
            self.reply(message: message.OK)
            
        case "AT$C1":
            self.connectWifi()
            self.reply(message: message.OK)
            
        case "ATE?", "ATE0", "ATE1":
            if upCmd.contains("?") {
                self.serial.putChars(String(self.echo))
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.echo = false
                self.reply(message: message.OK)
                
            } else  {
                self.echo = true
                self.reply(message: message.OK)
            }
        
        case "ATV?", "ATV0", "ATV1":
            if upCmd.contains("?") {
                self.serial.putChars(String(self.verbosity))
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.verbosity = false
                self.reply(message: message.OK)
            }
            else {
                self.verbosity = true
                self.reply(message: message.OK)
            }
            
        case "AT&P?", "AT&P0", "AT&P1":
            if upCmd.contains("?") {
                self.serial.putChars("TODO")
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.polarity = Serial.Polarity.CBM
                self.serial.setPolarity(mode: Serial.Polarity.CBM)
                self.reply(message: message.OK)
            }
            else if upCmd.contains("1") {
                self.polarity = Serial.Polarity.NORMAL
                self.serial.setPolarity(mode: Serial.Polarity.NORMAL)
                self.reply(message: message.OK)
                self.setCarrier(self.callConnected())
            }
        
        case "AT&K", "AT&K0", "AT&K1", "AT&K2":
            if upCmd.contains("?") {
                self.serial.putChars("TODO")
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.flowControl = Serial.flowControl.NONE
                self.serial.setFlowControl(mode: Serial.flowControl.NONE)
                self.reply(message: message.OK)
            }
            else if upCmd.contains("1") {
                self.flowControl = Serial.flowControl.SOFTWARE
                self.serial.setFlowControl(mode: Serial.flowControl.SOFTWARE)
                self.reply(message: message.OK)
            }
            else if upCmd.contains("2") {
                self.flowControl = Serial.flowControl.HARDWARE
                self.serial.setFlowControl(mode: Serial.flowControl.HARDWARE)
                self.reply(message: message.OK)
            }
            
        default:
            self.reply(message: message.ERROR)
        }
    }
    
    func handleATMode() {
        if self.serial.hasChars {
            let c = self.serial.getChar()
            if (c == "\n") || (c == "\r") {
                self.processATCommand()
            }
            //        BACKSPACE           DELETE               CHR$(20)
            else if ( c == "\u{8}" ) || ( c == "\u{7c}" ) || ( c == "\u{14}" ) {
                self.atCommand.remove(at: self.atCommand.index(before: self.atCommand.endIndex))
                if self.echoActive {
                    self.serial.putChar(c)
                }
            }
            else {
                if self.atCommand.count < self.ATCMD_MAX_LENGTH {
                    self.atCommand.append(c)
                    if self.echoActive {
                        self.serial.putChar(c)
                    }
                }
            }
        }
    }
    
    func handleConnectedMode() {
        if self.serial.hasChars {
            self.led(name:ledName.TX, status: ledStatus.ON)
            var ongoingData = self.serial.getAllChars()
            if ongoingData.contains(self.ATCMD_ESCAPE_SEQ) {
                self.cmdMode = true
            }
            if self.connection.isActive() {
                self.connection.putChars(ongoingData)
            }
        }
        else {
            self.led(name: ledName.TX, status: ledStatus.OFF)
        }
        if self.connection.isConnected() {
            self.led(name: ledName.CONNECTED, status: ledStatus.ON)
            if self.connection.hasChars {
                self.led(name: ledName.RX, status: ledStatus.ON)
                var incomingData = self.connection.getChar()
                self.serial.putChar(incomingData)
            }
            else {
                self.led(name: ledName.RX, status: ledStatus.OFF)
            }
        }
        else {
            self.cmdMode = true
            self.led(name: ledName.CONNECTED, status: ledStatus.OFF)
        }
    }
    
    func handleIncomingConnection() {
        
    }
    
    func loop() {
        self.updateDisplay()
        self.handleFlowControl()
        self.handleIncomingConnection()
        self.checkButtons()
        if self.cmdMode {
            self.handleATMode()
        }
        else {
            self.handleConnectedMode()
        }
    }
}
