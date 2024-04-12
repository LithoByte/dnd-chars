//
//  SpellPointsReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import ComposableArchitecture

@Reducer
struct SpellPointsReducer {
    
    @ObservableState
    struct State: Equatable {
        var source: PointsReducer.State
        var spellLevels: [SpellLevel]
        var wizardLevels: ClassLevel?
        var proficiencyBonus: Int
    }
    
    enum Action: Equatable {
        case source(PointsReducer.Action)
        case castSpellOfLevel(SpellLevel)
        case restoreTapped
        case arcaneRecoveryTapped
        case harnessDivinePowerTapped
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.source, action: \.source) {
            PointsReducer()
        }
        Reduce { state, action in
            switch action {
            case .source(_): break
            case .castSpellOfLevel(let level):
                if state.source.currentPoints >= SpellLevel.points(for: level) {
                    return .send(.source(.adjustPoints(-SpellLevel.points(for: level))))
                }
            case .restoreTapped:
                state.source.currentPoints = state.source.maxPoints
            case .arcaneRecoveryTapped:
                if let levels = state.wizardLevels {
                    let halfWizardLevelRoundedUp = levels.count.isMultiple(of: 2) ? levels.count / 2 : levels.count / 2 + 1
                    state.source.currentPoints = min(state.source.currentPoints + SpellLevel.points(for: .first) * halfWizardLevelRoundedUp, state.source.maxPoints)
                }
            case .harnessDivinePowerTapped:
                let halfProficiencyBonusRoundedUp = state.proficiencyBonus.isMultiple(of: 2) ? state.proficiencyBonus / 2 : state.proficiencyBonus / 2 + 1
                state.source.currentPoints = min(state.source.currentPoints + SpellLevel.points(for: .first) * halfProficiencyBonusRoundedUp, state.source.maxPoints)
            }
            return .none
        }
    }
}
