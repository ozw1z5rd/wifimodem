//
//  main.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 AlessioPalma. All rights reserved.
//

import Foundation

let serial = Serial()
let display = Display()

let modemWifi = WifiModemEmulator(virtualSerial: serial, virtualDisplay: display)

modemWifi.loop()








