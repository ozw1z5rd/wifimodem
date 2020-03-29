//
//  main.swift
//  WifiModemEmulator
//
//  Created by bigfoot on 22/03/2020.
//  Copyright © 2020 Alessio Palma. All rights reserved.
//

import Foundation

let modemWifi = WifiModemEmulator(
    virtualSerial: Serial(),
    virtualDisplay: Display(),
    virtualLEDS: Led()
)

modemWifi.loop()








