//
//  Serial.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//
    
import Foundation

class Serial {
    
    enum Exception: Error {
        case CANT_OPEN
        case CANT_WRITE
        case Ohoh
    }
    
    /// Control flow supported by the serial
    enum FlowControl : String {
        case NONE = "None"
        case HARDWARE = "CTS/RTS"
        case SOFTWARE = "XON/XOFF"
        func asString() -> String {
            return self.rawValue
        }
    }
    
    private var fd_serial: Int32 = 0
    private var internalBuffer = ""
    private let debug = true
    private let bufferSize: Int = 512
    private var buffer = UnsafeMutableRawPointer.allocate(byteCount: 512, alignment: 1)
    
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
    
    private func getCharsFromInternalBuffer(size: Int = 0) throws -> String {
        // do we need to refill the buffer?
        if (internalBuffer.count == 0) || (internalBuffer.count < size) || (size == -1 ) {
            let n = read(self.fd_serial, self.buffer, self.bufferSize )
            guard (n > 0) || (errno == EAGAIN) else {
                throw Exception.Ohoh
            }
            Logger.debug("\(n) bytes read")
            let s = String(bytesNoCopy: self.buffer, length: n, encoding: String.Encoding.ascii, freeWhenDone: false)
            self.internalBuffer += s!
        }
        // just buffer refill, nothing more to do.
        guard size > 0 else {
            return ""
        }
        // return all the available data
        if (self.internalBuffer.count <= size ) || ( size < 0 ) {
            let data = self.internalBuffer
            self.internalBuffer = ""
            return data
        }
        // get size chars from the buffers to return to the caller
        // and removes them from the buffer
        let requestedData = String(internalBuffer.prefix(size))
        let range = internalBuffer.index(internalBuffer.startIndex, offsetBy: size)..<internalBuffer.endIndex
        internalBuffer = String(internalBuffer[range])
        return requestedData
    }
    
    var conversionMode: ConversionMode {
        set { self._conversionMode = newValue }
        get { return self._conversionMode }
    }
    
    /// this method returns true if there are charaters available inside the serial buffer
    func hasChars() -> Bool {
        do {
            _ = try getCharsFromInternalBuffer()
        } catch Exception.Ohoh {
            Logger.error("Cannot refill the buffer")
        } catch {
            Logger.error("More than Oh oh")
        }
        return internalBuffer.count > 0
    }
    
    /// returns all the available charaters in the serial buffer as string
    func getAllChars() -> String {
        var s = ""
        do {
            s = try getCharsFromInternalBuffer(size: -1)
        } catch Exception.Ohoh {
            Logger.error("Cannot read chars from the internal buffer")
        } catch {
            Logger.error("Even worse...")
        }
        return s
    }
    
    /// Get a single char from the Socket, if no data is available this function will wait for it
    /// - Returns: a single char
    func getChar() -> Character {
        var c:Character = Character("\u{00}")
        do {
            // 😮 wow...
            let s = try getCharsFromInternalBuffer(size: 1)
            if s.count > 0 {
                let t = s.prefix(1)
                c = Character(String(t))
            }
        }
        catch Exception.Ohoh {
            Logger.error("Cannot read data")
        }
        catch {
            Logger.error("Even worse..")
        }
        return c
    }

    /// This method sends a single 8 bit char over the serial line
    /// - Parameter char: the charater to be send over the serial line.
    func putChar(_ char: Character) {
        
    }
    
    /// Send a string of 8 bit chars over the serial line
    /// - Parameter chars: The string of char to be sent over the serial line
    func putChars(_ buffer: String)  throws {
        let n = write(self.fd_serial, buffer, buffer.count)
        guard n >= 0 else {
            throw Exception.CANT_WRITE
        }
    }
    
    private func setupSerial() throws {
        if self.debug {
            Logger.info("Opening /tmp/serial as emulation, this file must already exists and must be a FIFO mkfifo /tmp/serial")
            self.fd_serial = open("/tmp/serial", O_RDWR)
            guard self.fd_serial > 0 else {
                throw Exception.CANT_OPEN
            }
        }
    }
    
    init() {
        Logger.info("Serial module is initializing")
        self._baudRate = .B300
        self._flowControl = .NONE
        self._conversionMode = .NORMAL
        self._polarity = .NORMAL
    }
}


