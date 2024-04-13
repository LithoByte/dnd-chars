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

public enum ClassEnum: String, Codable, Equatable, CaseIterable, Hashable { case artificer, barbarian, bard, cleric, druid, fighter, monk, paladin, ranger, rogue, sorcerer, warlock, wizard }

extension ClassEnum {
    func resources(at level: Int) -> [PointSource] {
        switch self {
        case .artificer: return []
        case .barbarian:
            switch level {
            case _ where level < 1: return []
            case 1...2: return [PointSource(title: "Rage", currentPoints: 2, maxPoints: 2, pointsType: .other)]
            case 3...5: return [PointSource(title: "Rage", currentPoints: 3, maxPoints: 3, pointsType: .other)]
            case 6...11: return [PointSource(title: "Rage", currentPoints: 4, maxPoints: 4, pointsType: .other)]
            case 12...16: return [PointSource(title: "Rage", currentPoints: 5, maxPoints: 5, pointsType: .other)]
            case 17...19: return [PointSource(title: "Rage", currentPoints: 6, maxPoints: 6, pointsType: .other)]
            default: return []
            }
        case .bard: return []
        case .cleric:
            switch level {
            case 2...5: return [PointSource(title: "Channel Divinity", currentPoints: 1, maxPoints: 1, pointsType: .other)]
            case 6...17: return [PointSource(title: "Channel Divinity", currentPoints: 2, maxPoints: 2, pointsType: .other)]
            case _ where level > 17: return [PointSource(title: "Channel Divinity", currentPoints: 3, maxPoints: 3, pointsType: .other)]
            default: return []
            }
        case .druid:
            switch level {
            case 2...19: return [PointSource(title: "Wild Shape", currentPoints: 2, maxPoints: 2, pointsType: .other)]
            default: return []
            }
        case .fighter:
            switch level {
            case 1: return [PointSource(title: "Second Wind", currentPoints: 1, maxPoints: 1, pointsType: .other)]
            case 2...8: return [PointSource(title: "Second Wind", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Action Surge", currentPoints: 1, maxPoints: 1, pointsType: .other)]
            case 9...12: return [PointSource(title: "Second Wind", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Action Surge", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Indomitable", currentPoints: 1, maxPoints: 1, pointsType: .other)]
            case 13...16: return [PointSource(title: "Second Wind", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Action Surge", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Indomitable", currentPoints: 2, maxPoints: 2, pointsType: .other)]
            case _ where level > 16: return [PointSource(title: "Second Wind", currentPoints: 1, maxPoints: 1, pointsType: .other), PointSource(title: "Action Surge", currentPoints: 2, maxPoints: 2, pointsType: .other), PointSource(title: "Indomitable", currentPoints: 3, maxPoints: 3, pointsType: .other)]
            default: return []
            }
        case .monk:
            if level > 20 {
                return [PointSource(title: "Ki Points", currentPoints: 20, maxPoints: 20, pointsType: .other)]
            } else if level > 2 {
                return [PointSource(title: "Ki Points", currentPoints: level, maxPoints: level, pointsType: .other)]
            }
        case .paladin:
            /// need cha modifier for divine sense (1 + Cha)
            var resources = [PointSource(title: "Lay on Hands", currentPoints: 5 * level, maxPoints: 5 * level, pointsType: .other)]
            switch level {
            case 3...6: resources.append(PointSource(title: "Channel Divinity", currentPoints: 1, maxPoints: 1, pointsType: .other))
            case 7...14: resources.append(PointSource(title: "Channel Divinity", currentPoints: 2, maxPoints: 2, pointsType: .other))
            case _ where level > 14: resources.append(PointSource(title: "Channel Divinity", currentPoints: 3, maxPoints: 3, pointsType: .other))
            default: break
            }
            return resources
        case .ranger, .rogue: return []
        case .sorcerer: 
            if level > 20 {
                return [PointSource(title: "Sorcery Points", currentPoints: 20, maxPoints: 20, pointsType: .other)]
            } else if level > 2 {
                return [PointSource(title: "Sorcery Points", currentPoints: level, maxPoints: level, pointsType: .other)]
            }
        case .warlock: return []
        case .wizard:
            return [PointSource(title: "Arcane Recovery", currentPoints: 1, maxPoints: 1, pointsType: .other)]
        }
        return []
    }
}

public extension ClassEnum {
    func spellCastingAbility() -> Ability? {
        switch self {
        case .artificer:
            return Ability.INT
        case .barbarian:
            return nil
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
}

extension Character {
    func classResources() -> [PointSource] {
        var calcResources = [PointSource]()
        for levels in self.levels {
            calcResources.append(contentsOf: levels.classEnum.resources(at: levels.count))
        }
        if let _ = levels.first(where: { $0.classEnum == .bard })?.count, let chaScore = abilityScores.first(where: { $0.ability == .CHA })?.score {
            calcResources.append(PointSource(title: "Bardic Inspiration", currentPoints: max(1, modifier(for: .CHA)), maxPoints: max(1, modifier(for: .CHA)), pointsType: .other))
        }
        if let _ = levels.first(where: { $0.classEnum == .paladin })?.count, let chaScore = abilityScores.first(where: { $0.ability == .CHA })?.score {
            calcResources.append(PointSource(title: "Divine Sense", currentPoints: max(1, 1 + modifier(for: .CHA)), maxPoints: max(1, 1 + modifier(for: .CHA)), pointsType: .other))
        }
        return calcResources
    }
    
    mutating func levelUpResources() {
        resources = leveledUpResources()
    }
    
    func leveledUpResources() -> [PointSource] {
        var newResources = classResources()
        let titles = newResources.map { $0.title }
        let oldResources = resources.filter { !titles.contains($0.title) }
        newResources.append(contentsOf: oldResources)
        return newResources
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
