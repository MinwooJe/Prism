//
//  PrismLogger.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
//

import Foundation
import os

enum PrismLogger {
    private static let subsystem = "com.Prism"

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let disk = Logger(subsystem: subsystem, category: "Disk")
}
