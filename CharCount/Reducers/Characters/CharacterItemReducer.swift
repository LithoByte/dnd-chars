//
//  CharacterCharacterItemReducer.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CharacterItemReducer {
    typealias State = Character
    
    public enum Action: Equatable {
        case didTap
        case edit
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case didTap(Character)
            case edit(Character)
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTap:
                return .send(.delegate(.didTap(state)))
            case .edit:
                return .send(.delegate(.edit(state)))
            case .delegate(_):
                return .none
            }
        }
    }
}
