//
//  Item.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 23/07/25.
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
