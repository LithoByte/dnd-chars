//
//  EditCharacterView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct EditCharacterView: View {
    @Bindable var store: StoreOf<EditCharacterReducer>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                TextField("Character name", text: $store.name)
                    .padding()
                TextField("Con score", text: $store.conScore)
                    .padding()
                Toggle(isOn: $store.isTough, label: {
                    Text("Has 'Tough' feat:")
                })
                .padding(.horizontal, 16)
                Toggle(isOn: $store.usesSpellPoints, label: {
                    Text("Use spell points:")
                })
                .padding(.horizontal, 16)
                Button("Add Levels") {
                    store.send(.addLevels)
                }
                List {
                    IfLetStore(store.scope(state: \.firstSetOfLevels, action: EditCharacterReducer.Action.firstLevels)) { store in
                        EditLevelsView(store: store)
                    }
                    IfLetStore(store.scope(state: \.secondSetOfLevels, action: EditCharacterReducer.Action.secondLevels)) { store in
                        EditLevelsView(store: store)
                    }
                    IfLetStore(store.scope(state: \.thirdSetOfLevels, action: EditCharacterReducer.Action.thirdLevels)) { store in
                        EditLevelsView(store: store)
                    }
                    IfLetStore(store.scope(state: \.fourthSetOfLevels, action: EditCharacterReducer.Action.fourthLevels)) { store in
                        EditLevelsView(store: store)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    EditCharacterView(store: Store(initialState: EditCharacterReducer.State(name: bekri.name, conScore: "13", firstSetOfLevels: ClassLevel(classEnum: .cleric, count: 2), secondSetOfLevels: ClassLevel(classEnum: .wizard, count: 9)), reducer: { EditCharacterReducer() }))
}
