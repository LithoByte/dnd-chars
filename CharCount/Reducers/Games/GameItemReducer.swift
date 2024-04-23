//
//  GameItemReducer.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct GameItemReducer {
    
    typealias State = Game
    
    public enum Action: Equatable {
        case didTap
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTap: break
            }
            return .none
        }
    }
}
