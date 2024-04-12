//
//  Classes.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

public struct ClassLevel: Codable, Equatable, Identifiable, Hashable {
    public var id = Current.uuid()
    var classEnum: ClassEnum
    var count: Int
}

public enum ClassEnum: String, Codable, Equatable, CaseIterable, Hashable { case barbarian, bard, cleric, druid, fighter, monk, paladin, ranger, rogue, sorcerer, warlock, wizard }
public extension ClassEnum {
    func spellCastingAbility() -> Ability {
        switch self {
        case .barbarian:
            return Ability.INT
        case .bard:
            return Ability.CHA
        case .cleric:
            return Ability.WIS
        case .druid:
            return Ability.WIS
        case .fighter:
            return Ability.INT
        case .monk:
            return Ability.WIS
        case .paladin:
            return Ability.CHA
        case .ranger:
            return Ability.WIS
        case .rogue:
            return Ability.INT
        case .sorcerer:
            return Ability.CHA
        case .warlock:
            return Ability.CHA
        case .wizard:
            return Ability.INT
        }
    }
    
    func hitDie() -> Die {
        switch self {
        case .barbarian:
            return Die.d12
        case .bard:
            return Die.d8
        case .cleric:
            return Die.d8
        case .druid:
            return Die.d8
        case .fighter:
            return Die.d10
        case .monk:
            return Die.d8
        case .paladin:
            return Die.d10
        case .ranger:
            return Die.d10
        case .rogue:
            return Die.d8
        case .sorcerer:
            return Die.d6
        case .warlock:
            return Die.d8
        case .wizard:
            return Die.d6
        }
    }
}

extension Character {
    func casterLevels() -> Int {
        let fullCasterLevels = levels.reduce(0, {
            switch $1.classEnum {
            case .bard, .cleric, .druid, .sorcerer, .wizard:
                return $0 + $1.count
            default:
                return $0
            }
        })
        let halfCasterLevels = levels.reduce(0, {
            switch $1.classEnum {
            case .paladin, .ranger:
                return $0 + $1.count
            default:
                return $0
            }
        })
        let quarterCasterLevels = levels.reduce(0, {
            switch $1.classEnum {
            case .rogue, .fighter:
                return $0 + $1.count
            default:
                return $0
            }
        })
        let levelCount = fullCasterLevels + halfCasterLevels / 2 + quarterCasterLevels / 3
        return levelCount
    }
}
