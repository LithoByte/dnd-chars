//
//  GameRowView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct GameRowView: View {
    @Bindable var store: StoreOf<GameItemReducer>
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                Text(store.name).padding()
                Spacer()
                Text("\(store.playerCount) player(s)")
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                store.send(.didTap)
            }
        }
    }
}

#Preview {
    GameRowView(store: Store(initialState: Game(name: "Elliot's game"), reducer: { GameItemReducer() }))
}
