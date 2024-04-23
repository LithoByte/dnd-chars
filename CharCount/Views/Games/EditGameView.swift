//
//  EditGameView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct EditGameView: View {
    @Bindable var store: StoreOf<EditGameReducer>
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                TextField("Game Title", text: $store.game.name)
                    .textInputAutocapitalization(.words)
                    .padding(8)
                Spacer()
            }
        }
    }
}

#Preview {
    EditGameView(store: Store(initialState: EditGameReducer.State(game: Game(name: "")), reducer: { EditGameReducer() }))
}
