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
                HStack {
                    TextField("Character Name", text: $store.name)
                        .textInputAutocapitalization(.words)
                        .padding(8)
                    TextField("AC", text: $store.ac)
                        .keyboardType(.numberPad)
                        .padding(8)
                }
                .padding(.horizontal, 8)
                HStack {
                    TextField("CON score", text: $store.conScore)
                        .keyboardType(.numberPad)
                        .padding(8)
                    TextField("INT score", text: $store.intScore)
                        .keyboardType(.numberPad)
                        .padding(8)
                    TextField("WIS score", text: $store.wisScore)
                        .keyboardType(.numberPad)
                        .padding(8)
                    TextField("CHA score", text: $store.chaScore)
                        .keyboardType(.numberPad)
                        .padding(8)
                }
                .padding(.horizontal, 8)
                Toggle(isOn: $store.isTough, label: {
                    Text("Has 'Tough' feat:")
                })
                .padding(.horizontal, 16)
                Toggle(isOn: $store.isObservant, label: {
                    Text("Has 'Observant' feat:")
                })
                .padding(.horizontal, 16)
                Toggle(isOn: $store.hasPerProficiency, label: {
                    Text("Has proficiency in Perception:")
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
