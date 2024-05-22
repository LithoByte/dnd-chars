//
//  CharacterRowView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct CharacterRowView: View {
    @Bindable var store: StoreOf<CharacterItemReducer>
    
    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(store.name)
                    Text("\(store.levels.map { $0.classEnum.rawValue }.joined(separator: "/"))")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("lvl \(store.levels.map { $0.count }.reduce(0, +))")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                store.send(.didTap)
            }
            .swipeActions(edge: .leading) {
                Button { store.send(.edit) } label: {
                    Label("Edit", systemImage: "")
                }
                .tint(.accentColor)
            }
    }
}

#Preview {
    CharacterRowView(store: Store(initialState: bekri, reducer: { CharacterItemReducer() }))
}
