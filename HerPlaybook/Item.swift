//
//  Item.swift
//  HerPlaybook
//
//  Created by Ahmad Taylor on 2/6/26.
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
