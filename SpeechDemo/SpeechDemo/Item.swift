//
//  Item.swift
//  SpeechDemo
//
//  Created by 김지훈 on 2024/03/25.
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
