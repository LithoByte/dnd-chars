//
//  Character.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

var bekri = Character(name: "Bekri", 
                      levels: [ClassLevel(classEnum: .cleric, count: 2), ClassLevel(classEnum: .wizard, count: 9)],
                      abilityScores: [AbilityScore(ability: .CON, score: 13), AbilityScore(ability: .INT, score: 20), AbilityScore(ability: .WIS, score: 18), AbilityScore(ability: .CHA, score: 8)])
let rowaren = Character(name: "Rowaren",
                        levels: [ClassLevel(classEnum: .wizard, count: 8)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .WIS, score: 8), AbilityScore(ability: .CHA, score: 13)])
let rieta = Character(name: "Rieta",
                      levels: [ClassLevel(classEnum: .paladin, count: 8), ClassLevel(classEnum: .warlock, count: 3)],
                      abilityScores: [AbilityScore(ability: .CON, score: 11), AbilityScore(ability: .WIS, score: 10), AbilityScore(ability: .CHA, score: 18)])
let nociel = Character(name: "Nociel Lagronnie",
                       levels: [ClassLevel(classEnum: .fighter, count: 6)],
                       abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .WIS, score: 18), AbilityScore(ability: .CHA, score: 8)])
let haalgar = Character(name: "Haalgar",
                        levels: [ClassLevel(classEnum: .warlock, count: 5), ClassLevel(classEnum: .paladin, count: 6)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)], isTough: true)
let tasirinn = Character(name: "Tasirinn Iorziros",
                         levels: [ClassLevel(classEnum: .paladin, count: 7), ClassLevel(classEnum: .ranger, count: 5)],
                         abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)])
let sosira = Character(name: "Sosira Iorziros",
                       levels: [ClassLevel(classEnum: .paladin, count: 6), ClassLevel(classEnum: .ranger, count: 3)],
                       abilityScores: [AbilityScore(ability: .CON, score: 16), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)])
let beolac = Character(name: "Beolac",
                       levels: [ClassLevel(classEnum: .warlock, count: 2), ClassLevel(classEnum: .sorcerer, count: 4)],
                       abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .WIS, score: 18), AbilityScore(ability: .CHA, score: 8)])
let ludreau = Character(name: "Ludreau St. Cherie",
                        levels: [ClassLevel(classEnum: .warlock, count: 10)],
                        abilityScores: [AbilityScore(ability: .CON, score: 15), AbilityScore(ability: .WIS, score: 18), AbilityScore(ability: .CHA, score: 8)])
let adeleor = Character(name: "Adeleor Fortheciel",
                        levels: [ClassLevel(classEnum: .bard, count: 5)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .WIS, score: 12), AbilityScore(ability: .CHA, score: 16)])
let jollian = Character(name: "Jollian Bringlebrow",
                        levels: [ClassLevel(classEnum: .wizard, count: 5)],
                        abilityScores: [AbilityScore(ability: .CON, score: 16), AbilityScore(ability: .WIS, score: 10), AbilityScore(ability: .CHA, score: 15)])

// AC, PP, DC, rearrange for init, combat NPCs
struct Character: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = Current.uuid()
    var name: String
    var armorClass: Int = 10
    var levels: [ClassLevel]
    var abilityScores: [AbilityScore]
    var hpSources = [PointSource]()
    var spellSlots = [SlotLevel]()
    var spellPoints: PointSource?
    var usesSpellPoints: Bool = false
    var resources = [PointSource]()
    var skillProficiencies = [Skill]()
    var isTough: Bool = false
    var isObservant: Bool = false
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
