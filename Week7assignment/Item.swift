//
//  Item.swift
//  Week7assignment
//
//  Created by 陈艺凡 on 3/17/25.
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
