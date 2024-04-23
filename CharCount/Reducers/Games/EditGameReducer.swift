//
//  EditGameReducer.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EditGameReducer {
    @ObservableState
    public struct State: Equatable, Identifiable {
        var id = Current.uuid()
        var game: Game
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_): break
            }
            return .none
        }
    }
}
