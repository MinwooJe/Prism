//
//  PrismLogger.swift
//  Prism
//
//  Created by MinwooJe on 3/11/26.
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
