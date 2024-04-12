//
//  Abilities.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

public enum Ability: Int, Hashable, Codable, Equatable {
    case STR, DEX, CON, INT, WIS, CHA
    
    struct MissingError: Error {}
}

public struct AbilityScore: Codable, Equatable, Hashable {
    var ability: Ability
    var score: Int
}

extension Character {
    func modifier(for ability: Ability) -> Int {
        return (abilityScores.first(where: { $0.ability == ability })!.score - 10) / 2
    }
}
