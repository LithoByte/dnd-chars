//
//  EditCharacterReducer.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

extension Character {
    func toEditState() -> EditCharacterReducer.State {
        return EditCharacterReducer.State(id: id,
                                          name: name,
                                          conScore: "\(abilityScores.first(where: { $0.ability == .CON })?.score ?? 0)",
                                          firstSetOfLevels: levels.first,
                                          secondSetOfLevels: levels.count > 1 ? levels[1] : nil,
                                          thirdSetOfLevels: levels.count > 2 ? levels[2] : nil,
                                          fourthSetOfLevels: levels.count > 3 ? levels[3] : nil,
                                          usesSpellPoints: usesSpellPoints,
                                          isTough: isTough
        )
    }
}

@Reducer
struct EditCharacterReducer {
    @ObservableState
    public struct State: Equatable {
        var id: Character.ID?
        var name: String
        var conScore: String = ""
        // technically, you can only multiclass 4 times
        var firstSetOfLevels: ClassLevel?
        var secondSetOfLevels: ClassLevel?
        var thirdSetOfLevels: ClassLevel?
        var fourthSetOfLevels: ClassLevel?
        var usesSpellPoints = true
        var isTough: Bool = false
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addLevels
        case firstLevels(EditLevelsReducer.Action)
        case secondLevels(EditLevelsReducer.Action)
        case thirdLevels(EditLevelsReducer.Action)
        case fourthLevels(EditLevelsReducer.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                break
            case .addLevels:
                if let _ = state.firstSetOfLevels {
                    state.secondSetOfLevels = ClassLevel(classEnum: .barbarian, count: 0)
                } else if let _ = state.secondSetOfLevels {
                    state.thirdSetOfLevels = ClassLevel(classEnum: .barbarian, count: 0)
                } else if let _ = state.thirdSetOfLevels {
                    state.fourthSetOfLevels = ClassLevel(classEnum: .barbarian, count: 0)
                } else {
                    state.firstSetOfLevels = ClassLevel(classEnum: .barbarian, count: 0)
                }
            case .firstLevels(_), .secondLevels(_), .thirdLevels(_), .fourthLevels(_): break
            }
            return .none
        }
        .ifLet(\.firstSetOfLevels, action: /Action.firstLevels) {
            EditLevelsReducer()
        }
        .ifLet(\.secondSetOfLevels, action: /Action.secondLevels) {
            EditLevelsReducer()
        }
        .ifLet(\.thirdSetOfLevels, action: /Action.thirdLevels) {
            EditLevelsReducer()
        }
        .ifLet(\.fourthSetOfLevels, action: /Action.fourthLevels) {
            EditLevelsReducer()
        }
    }
}
