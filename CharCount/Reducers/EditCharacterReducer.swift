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
        let conScore = abilityScores.first(where: { $0.ability == .CON })?.score
        let intScore = abilityScores.first(where: { $0.ability == .INT })?.score
        let wisScore = abilityScores.first(where: { $0.ability == .WIS })?.score
        let chaScore = abilityScores.first(where: { $0.ability == .CHA })?.score
        let conString = conScore != nil ? "\(conScore!)" : ""
        let intString = intScore != nil ? "\(intScore!)" : ""
        let wisString = wisScore != nil ? "\(wisScore!)" : ""
        let chaString = chaScore != nil ? "\(chaScore!)" : ""
        return EditCharacterReducer.State(id: id,
                                          name: name,
                                          ac: "\(armorClass)",
                                          conScore: conString,
                                          intScore: intString,
                                          wisScore: wisString,
                                          chaScore: chaString,
                                          firstSetOfLevels: levels.first,
                                          secondSetOfLevels: levels.count > 1 ? levels[1] : nil,
                                          thirdSetOfLevels: levels.count > 2 ? levels[2] : nil,
                                          fourthSetOfLevels: levels.count > 3 ? levels[3] : nil,
                                          usesSpellPoints: usesSpellPoints,
                                          hasPerProficiency: skillProficiencies.contains(.perception),
                                          isObservant: isObservant,
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
        var ac: String = ""
        var conScore: String = ""
        var intScore: String = ""
        var wisScore: String = ""
        var chaScore: String = ""
        // technically, you can only multiclass 4 times
        var firstSetOfLevels: ClassLevel?
        var secondSetOfLevels: ClassLevel?
        var thirdSetOfLevels: ClassLevel?
        var fourthSetOfLevels: ClassLevel?
        var usesSpellPoints = false
        var hasPerProficiency = false
        var isObservant: Bool = false
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
                    state.secondSetOfLevels = ClassLevel(classEnum: .artificer, count: 0)
                } else if let _ = state.secondSetOfLevels {
                    state.thirdSetOfLevels = ClassLevel(classEnum: .artificer, count: 0)
                } else if let _ = state.thirdSetOfLevels {
                    state.fourthSetOfLevels = ClassLevel(classEnum: .artificer, count: 0)
                } else {
                    state.firstSetOfLevels = ClassLevel(classEnum: .artificer, count: 0)
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
