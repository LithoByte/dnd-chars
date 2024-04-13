//
//  SpellCasting.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation

enum SpellLevel: Int, Hashable, Codable, CaseIterable, RawRepresentable {
    case first = 1
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
    
    func toString() -> String {
        return switch self {
        case .first: "1st"
        case .second: "2nd"
        case .third: "3rd"
        case .fourth: "4th"
        case .fifth: "5th"
        case .sixth: "6th"
        case .seventh: "7th"
        case .eighth: "8th"
        case .ninth: "9th"
        }
    }
    
    static func points(for level: SpellLevel) -> Int {
        switch level {
        case .first: return 2
        case .second: return 3
        case .third: return 5
        case .fourth: return 6
        case .fifth: return 7
        case .sixth: return 9
        case .seventh: return 10
        case .eighth: return 11
        case .ninth: return 13
        }
    }
}

struct SpellSlot: Codable, Equatable, Hashable, Identifiable {
    var id = Current.uuid()
    var isUsed = false
    var level: SpellLevel
}

struct SlotLevel: Codable, Equatable, Hashable, Identifiable {
    var id = Current.uuid()
    var level: SpellLevel
    var slots: [SpellSlot]
    
    init(level: SpellLevel, count: Int) {
        self.level = level
        self.slots = [SpellSlot].init(repeating: SpellSlot(level: level), count: count)
    }
    
    init(id: UUID = Current.uuid(), level: SpellLevel, slots: [SpellSlot]) {
        self.id = id
        self.level = level
        self.slots = slots
    }
}

extension Array where Element == SlotLevel {
    static func +(_ lhs: [SlotLevel], _ rhs: [SlotLevel]) -> [SlotLevel] {
        var newLevels = [SlotLevel]()
        for level in SpellLevel.allCases {
            let leftLevel = lhs.first { $0.level == level }
            let rightLevel = rhs.first { $0.level == level }
            if let leftLevel, let rightLevel {
                newLevels.append(SlotLevel(level: level, count: leftLevel.slots.count + rightLevel.slots.count))
            } else if let leftLevel {
                newLevels.append(SlotLevel(level: level, count: leftLevel.slots.count))
            } else if let rightLevel {
                newLevels.append(SlotLevel(level: level, count: rightLevel.slots.count))
            }
        }
        return newLevels
    }
}

extension SpellSlot {
    static func totalSlots(forCasterLevels levels: Int, warlockLevels: Int) -> [SlotLevel] {
        let regularSlots = SpellSlot.slots(forCasterLevels: levels)
        let warlockSlots = SpellSlot.warlockSlots(for: warlockLevels)
        
        return regularSlots + warlockSlots
    }
    
    static func warlockSlots(for levels: Int) -> [SlotLevel] {
        return switch levels {
        case _ where levels <= 0: []
        case 1:
            [SlotLevel(level: .first, count: 1)]
        case 2:
            [SlotLevel(level: .first, count: 2)]
        case 3...4:
            [SlotLevel(level: .second, count: 2)]
        case 5...6:
            [SlotLevel(level: .third, count: 2)]
        case 7...8:
            [SlotLevel(level: .fourth, count: 2)]
        case 9...10:
            [SlotLevel(level: .fifth, count: 2)]
        case 11...12:
            [SlotLevel(level: .fifth, count: 3), SlotLevel(level: .sixth, count: 1)]
        case 13...14:
            [SlotLevel(level: .fifth, count: 3), SlotLevel(level: .sixth, count: 1), SlotLevel(level: .seventh, count: 1)]
        case 15...16:
            [SlotLevel(level: .fifth, count: 3), SlotLevel(level: .sixth, count: 1), SlotLevel(level: .seventh, count: 1), SlotLevel(level: .eighth, count: 1)]
        case _ where levels >= 17:
            [SlotLevel(level: .fifth, count: 4), SlotLevel(level: .sixth, count: 1), SlotLevel(level: .seventh, count: 1), SlotLevel(level: .eighth, count: 1), SlotLevel(level: .ninth, count: 1)]
        default: []
        }
    }
    
    static func slots(forCasterLevels levels: Int) -> [SlotLevel] {
        switch levels {
        case 1:
            return [SlotLevel(level: .first, count: 2)]
        case 2:
            return [SlotLevel(level: .first, count: 3)]
        case 3:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 2)]
        case 4:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3)]
        case 5:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 2)]
        case 6:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3)]
        case 7:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 1)]
        case 8: return [SlotLevel(level: .first, count: 4),
                        SlotLevel(level: .second, count: 3),
                        SlotLevel(level: .third, count: 3),
                        SlotLevel(level: .fourth, count: 2)]
        case 9:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 1)]
        case 10:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2)]
        case 11...12:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2),
                    SlotLevel(level: .sixth, count: 1)]
        case 13...14:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 1)]
        case 15...16:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2),
                    SlotLevel(level: .sixth, count: 1),
                    SlotLevel(level: .seventh, count: 1),
                    SlotLevel(level: .eighth, count: 1)]
        case 17...18:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2),
                    SlotLevel(level: .sixth, count: 1),
                    SlotLevel(level: .seventh, count: 1),
                    SlotLevel(level: .eighth, count: 1),
                    SlotLevel(level: .ninth, count: 1)]
        case 19:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2),
                    SlotLevel(level: .sixth, count: 2),
                    SlotLevel(level: .seventh, count: 1),
                    SlotLevel(level: .eighth, count: 1),
                    SlotLevel(level: .ninth, count: 1)]
        case _ where levels >= 20:
            return [SlotLevel(level: .first, count: 4),
                    SlotLevel(level: .second, count: 3),
                    SlotLevel(level: .third, count: 3),
                    SlotLevel(level: .fourth, count: 3),
                    SlotLevel(level: .fifth, count: 2),
                    SlotLevel(level: .sixth, count: 2),
                    SlotLevel(level: .seventh, count: 2),
                    SlotLevel(level: .eighth, count: 1),
                    SlotLevel(level: .ninth, count: 1)]
        default: return []
        }
    }
}

extension Character {
    func maxSpellSlots() -> [SlotLevel] {
        return SpellSlot.totalSlots(forCasterLevels: casterLevels(), warlockLevels: levels.first { $0.classEnum == .warlock }?.count ?? 0)
    }
    
    func spellSaveDC() -> Int {
        let dcs = levels.compactMap { $0.classEnum.spellCastingAbility() }.map { 8 + proficiencyBonus() + modifier(for: $0) }
        return dcs.max() ?? 8 + proficiencyBonus()
    }
    
    func maxSpellPoints() -> Int {
        return Character.maxSpellPoints(for: casterLevels())
    }
    
    static func maxSpellPoints(for levelCount: Int) -> Int {
        var spellPoints = 0
        switch levelCount {
        case 1:
            spellPoints = 4
        case 2:
            spellPoints = 6
        case 3:
            spellPoints = 14
        case 4:
            spellPoints = 17
        case 5:
            spellPoints = 27
        case 6:
            spellPoints = 32
        case 7:
            spellPoints = 38
        case 8:
            spellPoints = 44
        case 9:
            spellPoints = 57
        case 10:
            spellPoints = 64
        case 11...12:
            spellPoints = 73
        case 13...14:
            spellPoints = 83
        case 15...16:
            spellPoints = 94
        case 17:
            spellPoints = 107
        case 18:
            spellPoints = 114
        case 19:
            spellPoints = 123
        case 20:
            spellPoints = 133
        default:
            spellPoints = 0
        }
        return spellPoints
    }
    
    func maxSpellLevel() -> Int {
        return Character.maxSpellLevel(for: casterLevels())
    }
    
    static func maxSpellLevel(for levelCount: Int) -> Int {
        return switch levelCount {
        case 1...2: 1
        case 3...4: 2
        case 5...6: 3
        case 7...8: 4
        case 9...10: 5
        case 11...12: 6
        case 13...14: 7
        case 15...16: 8
        case _ where levelCount >= 17: 9
        default: 0
        }
    }
}
