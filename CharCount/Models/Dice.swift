//
//  Dice.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

public enum Die: Int, RawRepresentable, Codable, Equatable { case d4 = 4, d6 = 6, d8 = 8, d10 = 10, d12 = 12, d20 = 20, d100 = 100 }
public extension Die {
    var average: Int { return self.rawValue / 2 + 1 }
}
