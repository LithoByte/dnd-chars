//
//  EditLevelsReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EditLevelsReducer {
    typealias State = ClassLevel
    
    enum Action: Equatable {
        case setLevels(String)
        case setClass(ClassEnum)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setLevels(let levelsString):
                if let levels = Int(levelsString) {
                    state.count = levels
                }
            case .setClass(let classEnum):
                state.classEnum = classEnum
            }
            return .none
        }
    }
}
