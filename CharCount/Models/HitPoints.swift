//
//  HitPoints.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import Foundation
import ComposableArchitecture

@ObservableState
struct PointSource: Codable, Equatable, Identifiable, Hashable {
    var id = Current.uuid()
    var title: String
    var currentPoints: Int
    var maxPoints: Int
    var pointsType: PointsType
}

enum PointsType: String, Codable, CaseIterable {
    case innate, additional, temporary, other
    
    func orderValue() -> Int {
        switch self {
        case .innate: return 0
        case .additional: return 1
        case .temporary: return 2
        case .other: return 3
        }
    }
}
    
extension Character {
    func maxHitPoints() throws -> Int {
        guard let constitutionScore = abilityScores.first(where: { $0.ability == .CON })?.score else { throw Ability.MissingError() }
        var hitPoints = 0
        let modifier = (constitutionScore - 10) / 2
        if let firstClass = levels.first {
            let firstLevelPoints = firstClass.classEnum.hitDie().rawValue
            let firstClassPoints = firstLevelPoints + (firstClass.count - 1) * firstClass.classEnum.hitDie().average
            if levels.count > 1 {
                hitPoints += levels[1..<levels.count].reduce(firstClassPoints, { $0 + $1.count * $1.classEnum.hitDie().average })
            } else {
                hitPoints += firstClassPoints
                
            }
            hitPoints += modifier * levels.reduce(0, { $0 + $1.count })
            if isTough {
                hitPoints += 2 * levels.reduce(0, { $0 + $1.count })
            }
        }
        return hitPoints
    }
}

extension ClassEnum {
    func hitDie() -> Die {
        switch self {
        case .artificer:
            return .d8
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
