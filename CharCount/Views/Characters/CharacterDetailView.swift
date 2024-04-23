//
//  CharacterDetailView.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import SwiftUI
import ComposableArchitecture

struct CharacterDetailView: View {
    @Bindable var store: StoreOf<CharacterDetailReducer>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text(store.character.name).font(.title)
                Text("Con score: \(store.character.abilityScores.first(where: { $0.ability == .CON })!.score), modifier: +\(store.character.modifier(for: .CON))")
                Text("HP: \(try! store.character.maxHitPoints())")
                Text("Spell Points: \(try! store.character.maxSpellPoints())")
                List(store.character.levels, id: \.classEnum) {
                    Text("\($0.count) levels of \($0.classEnum.rawValue)")
                }
                Spacer()
                Button(action: {}) {
                    Text("Edit").padding()
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding()
            }
        }
    }
}

#Preview {
    CharacterDetailView(store: Store(initialState: CharacterDetailReducer.State(character: bekri), reducer: { CharacterDetailReducer() }))
}
