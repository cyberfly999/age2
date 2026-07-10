//
//  Item.swift
//  Age2
//
//  Created by Vinzenz Hehlen on 10.07.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
