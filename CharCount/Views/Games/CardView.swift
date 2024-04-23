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
        var manualCharacter: ManualCharacter?
    }
    
    enum Action: Equatable {
        case character(CharacterItemReducer.Action)
        case npc(NPCReducer.Action)
        case manualCharacter(ManualCharacterReducer.Action)
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
        .ifLet(\.manualCharacter, action: \.manualCharacter) {
            ManualCharacterReducer()
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
        IfLetStore(store.scope(state: \.manualCharacter, action: \.manualCharacter)) { store in
            ManualCharacterCardView(store: store).accentColor(.brown)
        }
    }
}

let charCard = CardReducer.State(character: bekri)
let npcCard = CardReducer.State(npc: archer)
let manualCard = CardReducer.State(manualCharacter: ManualCharacter(name: "Bekri", ac: "21", dc: "17", pp: "18"))
#Preview {
    CardView(store: Store(initialState: manualCard, reducer: CardReducer.init))
}
