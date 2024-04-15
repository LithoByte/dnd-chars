//
//  CharacterCardView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

struct CharacterCardView: View {
    @Bindable var store: StoreOf<CharacterItemReducer>
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Text("DC: \(store.state.spellSaveDC())")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("PP: \(store.state.passivePerception())")
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(store.name)")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                        .padding(.vertical, 4)
                    Text("AC: \(store.armorClass)")
                        .foregroundStyle(Color.accentColor)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1)
        }
        .padding(8)
    }
}

#Preview {
    CharacterCardView(store: Store(initialState: bekri, reducer: CharacterItemReducer.init))
}
