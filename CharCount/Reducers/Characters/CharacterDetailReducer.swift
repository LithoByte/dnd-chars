//
//  CharacterDetailReducer.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CharacterDetailReducer {
    @ObservableState
    public struct State: Equatable, Identifiable {
        var id = Current.uuid()
        var character: Character
    }
    public enum Action: Equatable {}
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {}
        }
    }
}
