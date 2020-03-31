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
    
    let OK = true
    let KO = false
    enum Exception: Error {
        case Ohoh
    }
    
    private var socket_fd: Int32 = -1
    private var _port: UInt16 = 0
    private var address4: String = "localhost"
    private let buffer: UnsafeMutableRawPointer
    private var connected: Bool = false
    private var bufferSize: Int = 0
    private var internalBuffer: String = ""
    
    var port: UInt16 {
        get {
            return self._port
        }
        set {
            self._port = newValue
        }
    }
    
    init(address: String = "localhost", port: UInt16 = 6510, bufferSz: Int = 1024) {
        self.address4 = address
        self._port = port
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: bufferSz, alignment: 1)
        self.bufferSize = bufferSz
        bzero(self.buffer, bufferSz - 1)
    }
    
    deinit {
        if self.socket_fd > 0 {
            close(self.socket_fd)
        }
        self.buffer.deallocate()
    }
    
    func connect() -> Bool {
        Logger.info("Starting Listening TCP connection to \(self.address4):\(self.port)")
        self.socket_fd = socket(AF_INET, SOCK_STREAM, 0)
        if self.socket_fd == -1 {
            Logger.error("Cannot create a socket_fd!")
            return KO
        }
        var sock_opt_on = Int32(1)
        setsockopt(self.socket_fd, SOL_SOCKET, SO_REUSEADDR, &sock_opt_on, socklen_t(MemoryLayout.size(ofValue: sock_opt_on)))
        var server_addr = sockaddr_in()
        let server_addr_size = socklen_t(MemoryLayout.size(ofValue: server_addr))
        server_addr.sin_len=UInt8(server_addr_size)
        server_addr.sin_family = sa_family_t(AF_INET) // IPV4
        server_addr.sin_port = UInt16(self.port).bigEndian
        
        let bind_server = withUnsafePointer(to: &server_addr) {
            bind(self.socket_fd, UnsafeRawPointer($0).assumingMemoryBound(to: sockaddr.self), server_addr_size)
        }
        if bind_server == 1 {
            Logger.error("Cannot Bind port \(self.port)")
            return KO
        }
        
        if listen(self.socket_fd, 5) == -1 {
            Logger.error("Cannot start listening")
            return KO
        }

        var client_addr = sockaddr_storage()
        var client_addr_len = socklen_t(MemoryLayout.size(ofValue: client_addr))
        let client_fd = withUnsafeMutablePointer(to: &client_addr) {
            accept(self.socket_fd, UnsafeMutableRawPointer($0).assumingMemoryBound(to: sockaddr.self), &client_addr_len)
        }
        if client_fd == -1 {
            Logger.error("Cannot accept connection")
            return KO
        }
        
        // no blocking read
        let flags: Int32 = fcntl(self.socket_fd, F_GETFL)
        let rc = fcntl(self.socket_fd, F_SETFL, flags | O_NONBLOCK )
        if rc < 0 {
            Logger.error("Cannot set no blocking on socket")
        }
        self.connected = true
        return OK
    }
    
    /// If there are chars avaialable inside the TCP/IP buffer returns True.
    /// - Returns: true when the socket has data
    func hasChars() -> Bool {
        return false
    }
    
    func bufferContainsChars() -> Bool {
        return false
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
    
    func getCharFromInternalBuffer(size: Int = 0) -> String {
        if size == 0 {
            return ""
        }
        // don't fill to much the internal buffer
        if self.internalBuffer.count < size {
            let n = read(self.socket_fd, self.buffer, Int(self.bufferSize))
            if n > 0 {
                let s = String(bytesNoCopy: self.buffer, length: size, encoding: String.Encoding.ascii, freeWhenDone: false)
                self.internalBuffer += s!
            }
        }
        if self.internalBuffer.count <= size {
            return self.internalBuffer
        }
        let strIndx = self.internalBuffer.index(self.internalBuffer.startIndex, offsetBy: size)
        //TODO adesso deve prendere size caratteri dal buffer interno ed
        //     accorciare quest'ultimo.
        return self.internalBuffer
    }
    
    /// Get a single char from the Socket, if no data is available this function will wait for it
    /// - Returns: a single char
    func getChar() -> Character {
        return Character(" ")
    }
    
    /// Get all the available chars from the current Socket, this function will block if no data is available
    /// - Returns: return all the available chars in the Socket
    func getAllChars() -> String {
        return "take all the data from the internal buffer"
    }
    
    func isConnected() -> Bool {
        return self.connected
    }
    
    func putChars(_ buffer: String) throws {
        //TODO some way to check the result
        let n = write(self.socket_fd, buffer, buffer.count)
        if n < 0 {
            throw Exception.Ohoh
        }
    }

    func getIpAddress() -> String {
        return self.address4
    }
    
    func hasClient() -> Bool  {
        return false
    }

}
