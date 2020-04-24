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
print ("    _______________________")
print ("___/ WIFI MODEM TEST BENCH \\__________________________")
print ("")
print ("  1 ... CHECK THE SERIAL CLASS")
print ("  2 ... CHECK CONNECTION CLASS")
print ("")
print ("SELECT")
let choose = readLine()
2
if choose == "2" {
    
    print ("                       _______________________")
    print ("______________________/ CONNECTION CLASS TEST \\__")
    
    Logger.info("Starting...")
    let c = Connection(address: "bbs.retroacademy.it", port: 6510, bufferSz: 512)
    Logger.info("After connection init")
    if c.call() {
        Logger.info("Connection OK!")
        var talking = true
        var ct = 1024
        while talking {
            do {
                try c.putChars("")
                usleep(10000)
                ct -= 1
                if ct < 0 {
                    talking = false
                }
            } catch {
                Logger.error("Cannot send chars")
            }
            
            let s = c.getChar()
            print("\(s)", terminator: "")
            usleep(10000)
        }
    } else {
        Logger.info("Start 'nc -l 0.0.0.0 64738' inside a terminal before to run this program.")
        Logger.error("Connection failed")
    }

    if false && c.call() {
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
}
else {
    print ("                       ___________________")
    print ("______________________/ SERIAL CLASS TEST \\______")
    
    let ser = Serial()
}

