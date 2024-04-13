//
//  Character.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

var bekri = Character(name: "Bekri", levels: [ClassLevel(classEnum: .cleric, count: 2), ClassLevel(classEnum: .wizard, count: 9)], abilityScores: [AbilityScore(ability: .CON, score: 13)], isTough: false)
let rowaren = Character(name: "Rowaren", levels: [ClassLevel(classEnum: .wizard, count: 8)], abilityScores: [AbilityScore(ability: .CON, score: 12)], isTough: false)
let rieta = Character(name: "Rieta", levels: [ClassLevel(classEnum: .paladin, count: 8), ClassLevel(classEnum: .warlock, count: 3)], abilityScores: [AbilityScore(ability: .CON, score: 11)], isTough: false)

struct Character: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = Current.uuid()
    var name: String
    var levels: [ClassLevel]
    var abilityScores: [AbilityScore]
    var hpSources = [PointSource]()
    var spellSlots = [SlotLevel]()
    var spellPoints: PointSource?
    var usesSpellPoints: Bool = false
    var resources = [PointSource]()
    var isTough: Bool
}

extension Character {
    func proficiencyBonus() -> Int {
        return proficiencyDie().average - 1
    }
    
    func proficiencyDie() -> Die {
        return Character.proficiencyDie(forLevel: levels.reduce(0, { $0 + $1.count }))
    }
    
    static func proficiencyDie(forLevel level: Int) -> Die {
        return switch level {
        case 5...8: .d6
        case 9...12: .d8
        case 13...16: .d10
        case _ where level >= 17: .d12
        default: .d4
        }
    }
}
