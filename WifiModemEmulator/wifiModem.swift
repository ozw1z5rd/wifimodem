//
//  WifiModem.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation
import os

class WifiModemEmulator {
    
    enum message : String {
        case OK = "OK\n"
        case ERROR = "ERROR/n"
        case UNIMPLEMENTED = "NOT IMPLEMENTED\n"
    }
    
    let serial: Serial
    let display: Display
    let connection: Connection
    let led: Led
    
    var verbosity: Bool = false
    var telnet: Bool = false
    var cmdMode: Bool = false
    var hexMode: Bool = false
    var petMode: Bool = false
    var echoActive: Bool = true
    var autoAnswer: Bool = false
    
    var atCommand: String = ""
    let ATCMD_MAX_LENGTH = 128
    let ATCMD_ESCAPE_SEQ = "+++"

    let MESSAGE_HELP = ""
    
    
    init(virtualSerial: Serial, virtualDisplay: Display, virtualLEDS: Led) {
        Logger.info("Initializing serial")
        self.serial = virtualSerial
        Logger.info("inizializing display")
        self.display = virtualDisplay
        Logger.info("initializing connection")
        self.connection = Connection()
        Logger.info("initializing leds")
        self.led = virtualLEDS
        self.led.initialize()
        Logger.info("init terminated")
    }
    
    func updateDisplay() {
        Logger.info("test")
        let message = """
        flow mode \(self.serial.flowControlMode.asString())
        Polarity \(self.serial.polarity.asString())
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
                self.serial.polarity = Serial.Polarity.CBM
                self.reply(message: message.OK)
            }
            else if upCmd.contains("1") {
                self.serial.polarity = Serial.Polarity.NORMAL
                self.reply(message: message.OK)
                self.setCarrier(self.callConnected())
            }
        
        case "AT&K", "AT&K0", "AT&K1", "AT&K2":
            if upCmd.contains("?") {
                self.serial.putChars("TODO")
                self.reply(message: message.OK)
            }
            else if upCmd.contains("0") {
                self.serial.flowControlMode = Serial.FlowControl.NONE
                self.reply(message: message.OK)
            }
            else if upCmd.contains("1") {
                self.serial.flowControlMode = Serial.FlowControl.SOFTWARE
                self.reply(message: message.OK)
            }
            else if upCmd.contains("2") {
                self.serial.flowControlMode = Serial.FlowControl.HARDWARE
                self.reply(message: message.OK)
            }
        case "AT$SB=300", "AT$SB=1200", "AT$SB=2400", "AT$SB=4800", "AT$SB=9600", "AT$SB=19200",
             "AT$SB=38400":
            let pos = upCmd.firstIndex(of: "=")
            // TODO: be sure that the baud rate value is correct
            let baudRate = Int(upCmd[upCmd.index(pos!, offsetBy: 1)...])
            // we can be sure that the baudRate is correctly mapped and
            // the Serial returns an existing value
            self.serial.baudRate = Serial.BaudRate(rawValue: baudRate!)!
            
        case "AT$SB?":
            self.serial.putChars(String(self.serial.baudRate.asString()))
            
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
            
        case "AT&F":
            self.resetSettingsToDefaults()
            self.reply(message: message.OK)
            
        case "ATS0=0":
            self.autoAnswer = false
            self.reply(message: message.OK)
            
        case "ATS0=1":
            self.autoAnswer = true
            self.reply(message: message.OK)
            
        case "ATS0?":
            self.serial.putChars(String(self.autoAnswer))
            self.reply(message: message.OK)
            
        case "ATPET=1":
            self.petMode = true
            self.reply(message: message.OK)
            
        case "ATPET=0":
            self.petMode = false
            self.reply(message: message.OK)
            
        case "ATPET?":
            self.serial.putChars(String(self.petMode))
            self.reply(message: message.OK)
        
        case "ATHEX=0":
            self.hexMode = false
            self.reply(message: message.OK)
            
        case "ATHEX=1":
            self.hexMode = true
            self.reply(message: message.OK)
            
        case "ATHEX?":
            self.serial.putChars(String(self.hexMode))
            self.reply(message: message.OK)
            
        case "ATH":
            self.reply(message: message.OK)
            
        case "AT$RB":
            self.reply(message: message.OK)
            
        case "ATO":
            self.reply(message: message.OK)
            
        case "AT$SP?":
            self.reply(message: message.OK)
            
        case "ATIP?":
            self.serial.putChars(self.connection.getIpAddress())
            self.reply(message: message.OK)
            
        case "AT$UPDATE":
            self.reply(message: message.UNIMPLEMENTED)
            
        case "AT$RESTART":
            self.reply(message: message.UNIMPLEMENTED)
            
        case "AT$SCAN":
            self.scanForNewSSID()
            self.reply(message: message.OK)
            
        default:
            if upCmd.hasPrefix("AT&Z") {
                
            }
            else if upCmd.hasSuffix("AT$SSID=") {
                
            }
            else if upCmd.hasSuffix("AT$PASS=") {
                
            }
            else if upCmd.hasSuffix("AT$SP=") {
                
            }
            else if upCmd.hasSuffix("ATGET") {
                self.reply(message: message.UNIMPLEMENTED)
            } else {
                self.reply(message: message.ERROR)
            }
        }
    }
    
    func scanForNewSSID() {
        
    }
    
    func resetSettingsToDefaults() {
        
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
        if self.serial.hasChars() {
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
        if self.serial.hasChars() {
            self.led.write(Led.Unit.TX, Led.Status.ON)
            let ongoingData = self.serial.getAllChars()
            if ongoingData.contains(self.ATCMD_ESCAPE_SEQ) {
                self.cmdMode = true
            }
            if self.connection.isActive() {
                do {
                    try self.connection.putChars(ongoingData)
                }  catch Connection.Exception.Ohoh {
                    Logger.error("Error Writing data")
                } catch {
                    Logger.error("Other errors...")
                }
            }
        }
        else {
            self.led.write(Led.Unit.TX, Led.Status.OFF)
        }
        if self.connection.isConnected() {
            self.led.write(Led.Unit.RX, Led.Status.ON)
            if self.connection.hasChars() {
            
                let incomingData = self.connection.getChar()
                self.serial.putChar(incomingData)
            }
            else {
                self.led.write(Led.Unit.RX, Led.Status.OFF)
            }
        }
        else {
            self.cmdMode = true
            
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
