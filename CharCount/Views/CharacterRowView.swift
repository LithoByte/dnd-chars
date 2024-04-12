//
//  CharacterRowView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct CharacterRowView: View {
    var store: StoreOf<CharacterItemReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text(viewStore.name)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                store.send(.didTap)
            }
            .swipeActions(edge: .leading) {
                Button { viewStore.send(.edit) } label: {
                    Label("Edit", systemImage: "")
                }
                .tint(.accentColor)
            }
        }
    }
}

#Preview {
    CharacterRowView(store: Store(initialState: bekri, reducer: { CharacterItemReducer() }))
}
