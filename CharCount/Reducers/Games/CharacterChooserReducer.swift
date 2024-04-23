//
//  CharacterChooserReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/19/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CharacterChooserReducer {
    
    @ObservableState
    struct State: Equatable {
        var allCharacters: IdentifiedArrayOf<Character> = IdentifiedArray(uniqueElements: loadData())
        var displayedCharacterStates: IdentifiedArrayOf<CharacterItemReducer.State> {
            var displayedCharacters = allCharacters
            if let searchableStringFrom = characterToSearchableString {
                if !localFilter.isEmpty {
                    displayedCharacters = allCharacters.filter({ character in
                        return matchesWordsPrefixes(localFilter, searchableStringFrom(character))
                    })
                }
            }
            return IdentifiedArray(uniqueElements: displayedCharacters.map { characterToItemState($0) })
        }
        var localFilter = ""
        var characterToItemState: (Character) -> CharacterItemReducer.State = { $0 }
        var characterToSearchableString: ((Character) -> String)? = { "\($0.name) \($0.levels.map { $0.classEnum.rawValue }.joined(separator: " "))" }
        
        static func == (lhs: CharacterChooserReducer.State, rhs: CharacterChooserReducer.State) -> Bool {
            return lhs.allCharacters == rhs.allCharacters
            && lhs.localFilter == rhs.localFilter
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case character(CharacterItemReducer.State.ID, CharacterItemReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            default: break
            }
            return .none
        }
        .forEach(\.allCharacters, action: /CharacterChooserReducer.Action.character(_:_:)) {
            CharacterItemReducer()
        }
    }
}

struct CharacterChooserView: View {
    @Bindable var store: StoreOf<CharacterChooserReducer>
    
    var body: some View {
        List {
            ForEachStore(self.store.scope(state: \.displayedCharacterStates, action: CharacterChooserReducer.Action.character(_:_:))) { characterStore in
                CharacterRowView(store: characterStore)
            }
        }
    }
}

#Preview {
    CharacterChooserView(store: Store(initialState: CharacterChooserReducer.State(allCharacters: IdentifiedArray(uniqueElements: [bekri, beolac, narak])), reducer: CharacterChooserReducer.init))
}
