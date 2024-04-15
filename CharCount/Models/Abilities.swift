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
    
    func passivePerception() -> Int {
        var passivePerception = 10
        passivePerception += modifier(for: .WIS)
        if skillProficiencies.contains(.perception) {
            passivePerception += proficiencyBonus()
        }
        if isObservant {
            passivePerception += 5
        }
        return passivePerception
    }
}

public enum Skill: String, Codable, CaseIterable, Equatable, Hashable { case acrobatics, animalHandling, arcana, athletics, deception, history, insight, intimidation, investigation, medicine, nature, perception, performance, persuasion, religion, sleightOfHand, stealth, survival }
public func ability(for skill: Skill) -> Ability {
    switch skill {
    case .acrobatics:
        return Ability.DEX
    case .animalHandling:
        return Ability.WIS
    case .arcana:
        return Ability.INT
    case .athletics:
        return Ability.STR
    case .deception:
        return Ability.CHA
    case .history:
        return Ability.INT
    case .insight:
        return Ability.WIS
    case .intimidation:
        return Ability.CHA
    case .investigation:
        return Ability.INT
    case .medicine:
        return Ability.WIS
    case .nature:
        return Ability.INT
    case .perception:
        return Ability.WIS
    case .performance:
        return Ability.CHA
    case .persuasion:
        return Ability.CHA
    case .religion:
        return Ability.INT
    case .sleightOfHand:
        return Ability.DEX
    case .stealth:
        return Ability.DEX
    case .survival:
        return Ability.WIS
    }
}
