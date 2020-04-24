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
        case WriteFailed
        case ReadFailed
        case UnImplemented
    }
    
    private var socket_fd: Int32 = -1
    private var port: UInt16 = 0
    private var hostName: String = "localhost"
    private var ipaddress4: String = ""
    private let buffer: UnsafeMutableRawPointer
    private var connected: Bool = false
    private var bufferSize: Int = 0
    private var internalBuffer: String = ""
    
    init(address: String = "localhost", port: UInt16 = 6510, bufferSz: Int = 1024) {
        self.hostName = address
        self.port = port
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
    
    /// This function is required when the computer waits for incoming connection, at the montent is not implemented
    func waitCall() throws {
        throw Exception.UnImplemented
    }
    
    /// Convert an hostname into a list of ip addresses
    ///
    /// - Parameter hostname: hostname
    /// - Returns: a list of ip addresses as strings or empty list if no resolution was possible
    private func hostToIpAddress(_ hostname: String) -> [String] {
        var ipList: [String] = []
        guard let host = hostname.withCString({
            gethostbyname($0)
        }) else {
            return ipList
        }
        // no ip addresses found
        guard host.pointee.h_length > 0 else {
            return ipList
        }
        var index = 0
        while host.pointee.h_addr_list[index] != nil {
            var addr: in_addr = in_addr()
            // ! is required to compile this under linux on raspberry
            memcpy(&addr.s_addr, host.pointee.h_addr_list[index]!, Int(host.pointee.h_length))
            guard let remoteIPAsC = inet_ntoa(addr) else {
                return ipList
            }
            ipList.append(String.init(cString: remoteIPAsC))
            index += 1
        }
        return ipList
    }
    
    /// Close the connection to remote
    func hangup() {
        close(self.socket_fd)
        self.connected = false
    }
    
    func call() -> Bool {
        Logger.debug("Attempt to TCP-connect to \(self.hostName):\(self.port)")
        // https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20160215/001112.html
#if RASPBERRY
        // print(SOCK_STREAM) --> __socket_type(rawValue: 1)
        self.socket_fd = socket(AF_INET, Int32(1), 0)
#else
        self.socket_fd = socket(AF_INET, SOCK_STREAM, 0)
#endif
        guard self.socket_fd != -1 else {
            Logger.error("Cannot create a socket_fd!")
            return KO
        }
        Logger.debug("Socket descriptor created")
        //HACK -
        var sock_opt_on = Int32(1)
        
        setsockopt(self.socket_fd, SOL_SOCKET, SO_REUSEADDR, &sock_opt_on, socklen_t(MemoryLayout.size(ofValue: sock_opt_on)))
        
        let remote_addresses = self.hostToIpAddress(self.hostName)
        let remote_addr = remote_addresses[0]
        Logger.info("Found \(remote_addresses.count) addresses, using the 1st - Remote IP is \(remote_addr) I will use only the first")
        
        var server_addr = sockaddr_in()
        let server_addr_size = socklen_t(MemoryLayout.size(ofValue: server_addr))
#if RASPBERRY
        Logger.info("Code compiled for raspberry, no sin_len in address structure")
#else
        server_addr.sin_len = UInt8(server_addr_size)
#endif
        server_addr.sin_family = sa_family_t(AF_INET) // IPV4
        server_addr.sin_port = UInt16(self.port).bigEndian
        server_addr.sin_addr = remote_addr.withCString({
             in_addr(s_addr: inet_addr($0))
        })
        var rc = withUnsafePointer(to: &server_addr) {
            connect(self.socket_fd, UnsafeRawPointer($0).assumingMemoryBound(to: sockaddr.self), server_addr_size)
        }
   
        guard rc >= 0 else {
            Logger.error("Cannot connect \(self.port) error code is \(errno)")
            return KO
        }
        
        Logger.info("Connected ok")
        
        let flags: Int32 = fcntl(self.socket_fd, F_GETFL)
        rc = fcntl(self.socket_fd, F_SETFL, flags | O_NONBLOCK )
        
        guard rc >= 0 else {
            Logger.error("Cannot set no blocking on socket")
            return KO
        }
        
        self.ipaddress4 = remote_addr
        self.connected = true
        return OK
    }
    
    /// If there are chars avaialable  returns true.
    /// - Returns: true when the socket has data
    func hasChars() -> Bool {
        do {
            _ = try getCharsFromInternalBuffer(size: 0)
        } catch Exception.Ohoh {
            Logger.error("Cannot read the data")
        } catch {
            Logger.error("oh oh...")
        }
        return internalBuffer.count > 0
    }
    
    func getSSID() -> String {
        return "TODO"
    }
    
    func getPassword() -> String {
        return "*********"
    }
    
    /// Get upto "size" chars from the internal buffer, when it gets empty it is filled again from the socket buffer. The code attemps always to read 1K bytes from the
    /// socket, the data read are moved into the internal buffer where are left for later usage.
    /// - Parameter size: how many chars get from the internal buffer
    /// - Returns: a string composed upto "size" chars. How many chars are returned depend on the socket's buffer data availability
    func getCharsFromInternalBuffer(size: Int = 0) throws -> String {
        // If the availability is less than the request, try to get more data from the socket's buffer
        if (internalBuffer.count == 0) || (internalBuffer.count < size) || (size == -1) {
            let n = read(self.socket_fd, self.buffer, Int(self.bufferSize))
            if n > 0 {
                Logger.debug("\(n) bytes read")
                let s = String(bytesNoCopy: self.buffer, length: n, encoding: String.Encoding.ascii, freeWhenDone: false)
                self.internalBuffer += s!
            }
            guard (n > 0) || (errno == EAGAIN) else {
                throw Exception.Ohoh
            }
        }
        // return nothing, if the called uses size 0 is to fill the internal buffer from the socket's buffer
        // without char removal.
        guard size > 0 else {
            return ""
        }
        if (self.internalBuffer.count <= size) || (size == -1) {
            let data = self.internalBuffer
            self.internalBuffer = ""
            return data
        }
        
        // gets the requested chars and removes them from the internal buffer
        let requestedData = String(internalBuffer.prefix(size))
        let range = internalBuffer.index(internalBuffer.startIndex, offsetBy: size)..<internalBuffer.endIndex
        internalBuffer = String(internalBuffer[range])
        return requestedData
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
    
    /// Get all the available chars from the current Socket, this function will block if no data is available
    /// - Returns: return all the available chars in the Socket
    func getAllChars() -> String {
        var s:String = ""
        do {
            s = try getCharsFromInternalBuffer(size: -1)
        }
        catch Exception.Ohoh {
            Logger.error("Cannot read data")
        }
        catch {
            Logger.error("Even worse...")
        }
        return s
    }
    
    func isConnected() -> Bool {
        return self.connected
    }
    
    func putChars(_ buffer: String) throws {
        //TODO some way to check the result
        let n = write(self.socket_fd, buffer, buffer.count)
        guard n >= 0 else {
            throw Exception.Ohoh
        }
    }

    func getIpAddress() -> String {
        return self.hostName
    }
    
    func hasClient() -> Bool {
        return false
    }

}
