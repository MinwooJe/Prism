//
//  PrismLogger.swift
//  Prism
//
//  Created by 제민우 on 10/31/25.
//

import Foundation
import os

enum PrismLogger {
    
    private enum Subsystem {
        static let bundleID = Bundle.main.bundleIdentifier ?? ""
        
        static let network = bundleID + "Network"
    }
    
    static let network = Logger(subsystem: Subsystem.network, category: "Network")
    
}
