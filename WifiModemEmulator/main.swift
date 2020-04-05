//
//  main.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation

//let modemWifi = WifiModemEmulator(
//    virtualSerial: Serial(),
//    virtualDisplay: Display(),
//    virtualLEDS: Led()
//)

// modemWifi.loop()

Logger.info("Starting...")
let c = Connection(address: "bbs.retroacademy.it", port: 6510, bufferSz: 512)
Logger.info("After connection init")
if c.call() {
    Logger.info("Connection OK!")
    var talking = true
    var ct = 20
    while talking {
        do {
            try c.putChars("")
            sleep(1)
            ct -= 1
            if ct < 0 {
                talking = false
            }
        } catch {
            Logger.error("Cannot send chars")
        }
    
        let s = c.getAllChars()
        if s.count > 0 {
            if s.contains("STOP") {
                talking = false
            } else {
                print(s)
            }
        }
        usleep(100000)
    }
} else {
    Logger.info("Start 'nc -l 0.0.0.0 64738' inside a terminal before to run this program.")
    Logger.error("Connection failed")
}

