//
//  WifiModem.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 AlessioPalma. All rights reserved.
//

import Foundation
import os

enum ledName : String  {
    case TX="TX"
    case RX="RX"
    case CONNECTED="CONNECTED"
    case CD="CD"
    case RI="RI"
    case FLOWCTRL_SOFT="XONXOFF"
    case FLOWCTRL_HARD="CTSRTS"
    case READY="READY"
}

enum ledStatus : String {
    case ON, OFF
}

enum message : String {
    case OK = "OK\n"
    case ERROR = "ERROR/n"
}

class WifiModemEmulator {
    
    let serial: Serial
    let display: Display
    let connection: Connection
    
    var polarity: Serial.Polarity = Serial.Polarity.NORMAL
    var flowControl: Serial.flowControl = Serial.flowControl.NONE
    
    var verbosity: Bool = false
    var telnet: Bool = false
    var cmdMode: Bool = false
    var atCommand: String = ""
    var echoActive: Bool = true
    var autoAnswer: Bool = false
    
    let ATCMD_MAX_LENGTH = 128
    let ATCMD_ESCAPE_SEQ = "+++"
    
    let MESSAGE_HELP = ""
    
    func initializeLeds() {
        self.led(name: ledName.CD, status: ledStatus.OFF)
        self.led(name: ledName.CONNECTED, status: ledStatus.OFF)
        self.led(name: ledName.FLOWCTRL_HARD, status: ledStatus.OFF)
        self.led(name: ledName.FLOWCTRL_SOFT, status: ledStatus.OFF)
        self.led(name: ledName.READY, status: ledStatus.ON)
        self.led(name: ledName.RI, status: ledStatus.OFF)
        self.led(name: ledName.RX, status: ledStatus.OFF)
        self.led(name: ledName.TX, status: ledStatus.OFF)
    }
    
    init(virtualSerial: Serial, virtualDisplay: Display) {
        os_log("Initializing serial")
        self.serial = virtualSerial
        os_log("inizializing display")
        self.display = virtualDisplay
        os_log("initializing connection")
        self.connection = Connection()
        os_log("initializing leds")
        self.initializeLeds()
        os_log("init terminated")
    }
    
    func led(name: ledName, status: ledStatus) {
        os_log("%@ => %@", name.rawValue, status.rawValue)
    }
    
    func updateDisplay() {
        os_log("test")
        let message = """
            flow mode \(self.flowControl)
            Polarity \(self.polarity)
        """
        self.display.visualize(textContent: message)
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
        os_log("Sending back:%@", message.rawValue)
    }
    
    func setCarrier(_ x: Any ) {
        
    }
    
    func processATCommand() {
        self.atCommand = self.atCommand.trimmingCharacters(in: .newlines)
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
                self.serial.putChars("TODO")
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.echoActive = false
                self.reply(message: message.OK)
                
            } else  {
                self.echoActive = true
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
                self.flowControl = self.serial.setFlowControl(mode: Serial.flowControl.NONE)
                self.reply(message: message.OK)
            }
            else if upCmd.contains("1") {
                self.flowControl = self.serial.setFlowControl(mode: Serial.flowControl.SOFTWARE)
                self.reply(message: message.OK)
            }
            else if upCmd.contains("2") {
                self.flowControl = self.serial.setFlowControl(mode: Serial.flowControl.HARDWARE)
                self.reply(message: message.OK)
            }
        case "AT$SB=300", "AT$SB=1200", "AT$SB=2400", "AT$SB=4800", "AT$SB=9600", "AT$SB=19200",
             "AT$SB=38400":
            let pos = upCmd.firstIndex(of: "=")
            // TODO: be sure that the baud rate value is correct
            let baudRate = Int(upCmd[upCmd.index(pos!, offsetBy: 1)...])
            self.serial.setBaudRate(rate: (Serial.BaudRate( rawValue: baudRate!)! ))
            
        case "AT$SB?":
            self.serial.putChars(String(self.serial.getBaudRateAsString().rawValue))
            
        case "AT$MB?":
            // TODO
            self.serial.putChars("busyMsg")
            self.reply(message: message.OK)
            
        case "ATI", "ATI0", "ATI1":
            self.serial.putChars(self.networkStatus())
            // TODO update display with the newtorn status
            self.reply(message: message.OK)
            
        case "AT&V":
            self.serial.putChars(self.currentSettings())
            self.serial.putChars(self.storedSetting())
            self.reply(message: message.OK)
        
        case "AT&W":
            self.saveSettings()
            self.reply(message: message.OK)
        
        case "AT$SSID?":
            self.serial.putChars(self.connection.getSSID())
            // todo
            self.reply(message: message.OK)
            
        
        case "AT&PASS?":
            self.serial.putChars(self.connection.getPassword())
            self.reply(message: message.OK)
            
        case "ATS0=0":
            self.autoAnswer = false
            self.reply(message: message.OK)
            
        case "ATS0=1":
            self.autoAnswer = true
            self.reply(message: message.OK)
            
        case "ATS0?":
            self.serial.putChars(String(self.autoAnswer))
        default:
            // AT&Z
            // AT$SSID="
            // AT$PASS=
            //
            
            self.reply(message: message.ERROR)
        }
    }
    
    func saveSettings() {
        
    }
    
    func storedSetting() -> String {
        return "TODO"
    }
    
    func currentSettings() -> String {
        return "TODO"
    }
    
    func networkStatus() -> String {
        // TODO
        return "TODO"
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
            let ongoingData = self.serial.getAllChars()
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
                let incomingData = self.connection.getChar()
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
