//
//  Character.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation
import ComposableArchitecture

var bekri = Character(name: "Bekri", 
                      armorClass: 21,
                      levels: [ClassLevel(classEnum: .cleric, count: 2), ClassLevel(classEnum: .wizard, count: 9)],
                      abilityScores: [AbilityScore(ability: .CON, score: 13), AbilityScore(ability: .INT, score: 20), AbilityScore(ability: .WIS, score: 18), AbilityScore(ability: .CHA, score: 8)],
                      skillProficiencies: [.perception])
let rowaren = Character(name: "Rowaren",
                        armorClass: 22,
                        levels: [ClassLevel(classEnum: .wizard, count: 8)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .INT, score: 22), AbilityScore(ability: .WIS, score: 8), AbilityScore(ability: .CHA, score: 13)])
let rieta = Character(name: "Rieta",
                      armorClass: 18,
                      levels: [ClassLevel(classEnum: .paladin, count: 8), ClassLevel(classEnum: .warlock, count: 3)],
                      abilityScores: [AbilityScore(ability: .CON, score: 11), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 10), AbilityScore(ability: .CHA, score: 18)],
                      skillProficiencies: [.perception])
let nociel = Character(name: "Nociel Lagronnie",
                       armorClass: 18,
                       levels: [ClassLevel(classEnum: .fighter, count: 6)],
                       abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)],
                       skillProficiencies: [.perception])
let haalgar = Character(name: "Haalgar",
                        armorClass: 20,
                        levels: [ClassLevel(classEnum: .warlock, count: 5), ClassLevel(classEnum: .paladin, count: 6)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)], isTough: true)
let tasirinn = Character(name: "Tasirinn Iorziros",
                         armorClass: 20,
                         levels: [ClassLevel(classEnum: .paladin, count: 7), ClassLevel(classEnum: .ranger, count: 5)],
                         abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)],
                         skillProficiencies: [.perception])
let sosira = Character(name: "Sosira Iorziros",
                       armorClass: 20,
                       levels: [ClassLevel(classEnum: .paladin, count: 6), ClassLevel(classEnum: .ranger, count: 3)],
                       abilityScores: [AbilityScore(ability: .CON, score: 16), AbilityScore(ability: .INT, score: 11), AbilityScore(ability: .WIS, score: 14), AbilityScore(ability: .CHA, score: 18)],
                       skillProficiencies: [.perception])
let beolac = Character(name: "Beolac",
                       armorClass: 15,
                       levels: [ClassLevel(classEnum: .warlock, count: 2), ClassLevel(classEnum: .sorcerer, count: 4)],
                       abilityScores: [AbilityScore(ability: .CON, score: 10), AbilityScore(ability: .INT, score: 14), AbilityScore(ability: .WIS, score: 8), AbilityScore(ability: .CHA, score: 18)])
let ludreau = Character(name: "Ludreau St. Cherie",
                        levels: [ClassLevel(classEnum: .warlock, count: 10)],
                        abilityScores: [AbilityScore(ability: .CON, score: 15), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 7), AbilityScore(ability: .CHA, score: 20)])
let adeleor = Character(name: "Adeleor Fortheciel",
                        armorClass: 16,
                        levels: [ClassLevel(classEnum: .bard, count: 5)],
                        abilityScores: [AbilityScore(ability: .CON, score: 12), AbilityScore(ability: .INT, score: 10), AbilityScore(ability: .WIS, score: 12), AbilityScore(ability: .CHA, score: 16)],
                        skillProficiencies: [.perception])
let jollian = Character(name: "Jollian Bringlebrow",
                        armorClass: 14,
                        levels: [ClassLevel(classEnum: .wizard, count: 5)],
                        abilityScores: [AbilityScore(ability: .CON, score: 16), AbilityScore(ability: .INT, score: 18), AbilityScore(ability: .WIS, score: 10), AbilityScore(ability: .CHA, score: 15)])
let narak = Character(name: "Narak",
                      armorClass: 21,
                        levels: [ClassLevel(classEnum: .paladin, count: 5), ClassLevel(classEnum: .sorcerer, count: 7)],
                        abilityScores: [AbilityScore(ability: .CON, score: 14), AbilityScore(ability: .INT, score: 11), AbilityScore(ability: .WIS, score: 10), AbilityScore(ability: .CHA, score: 18)])

// AC, PP, DC, rearrange for init, combat NPCs
@ObservableState
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
