//
//  CardView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CardReducer {
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var id = Current.uuid()
        var character: Character?
        var npc: NPC?
    }
    
    enum Action: Equatable {
        case character(CharacterItemReducer.Action)
        case npc(NPCReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default: break
            }
            return .none
        }
        .ifLet(\.character, action: \.character) {
            CharacterItemReducer()
        }
        .ifLet(\.npc, action: \.npc) {
            NPCReducer()
        }
    }
}

struct CardView: View {
    @Bindable var store: StoreOf<CardReducer>
    
    var body: some View {
        IfLetStore(store.scope(state: \.character, action: \.character)) { store in
            CharacterCardView(store: store)
        }
        IfLetStore(store.scope(state: \.npc, action: \.npc)) { store in
            NPCCardView(store: store).accentColor(store.hp == 0 ? Color.secondary : .indigo)
        }
    }
}

let charCard = CardReducer.State(character: bekri)
let npcCard = CardReducer.State(npc: archer)
#Preview {
    CardView(store: Store(initialState: npcCard, reducer: CardReducer.init))
}
