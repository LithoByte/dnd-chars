//
//  SpellPointsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import SwiftUI
import ComposableArchitecture

struct SpellPointsView: View {
    @Bindable var store: StoreOf<SpellPointsReducer>
    
    var body: some View {
        VStack {
            List {
                PointsView(store: store.scope(state: \.source, action: SpellPointsReducer.Action.source))
            }
            Spacer()
            Text("Cast spell of level:")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count:  3), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                ForEach(store.spellLevels.map { "\($0.rawValue)" }, id: \.self) { num in
                    Button(action: { store.send(.castSpellOfLevel(SpellLevel(rawValue: Int(num)!)!)) }, label: {
                        Text("\(num)")
//                            .foregroundStyle(magicGradient)
                    })
                    .padding()
                    .overlay {
                        Capsule()
                            .stroke(Color.accentColor, lineWidth: 1)
                    }
                }
            }
            VStack {
                if let _ = store.wizardLevels {
                    Button(action: { store.send(.arcaneRecoveryTapped) }) {
                        Text("Arcane Recovery")
//                            .foregroundStyle(magicGradient)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(4)
                }
                
                if let _ = store.wizardLevels {
                    Button(action: { store.send(.harnessDivinePowerTapped) }) {
                        Text("Harness Divine Power")
//                            .foregroundStyle(magicGradient)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(4)
                }
                
                Button(action: { store.send(.restoreTapped) }) {
                    Text("Restore all")
//                        .foregroundStyle(magicGradient)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding(4)
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    SpellPointsView(store: Store(initialState: SpellPointsReducer.State(source: PointsReducer.State(title: "Spell Points", currentPoints: 42, maxPoints: 42, pointsType: .innate), spellLevels: [.first,.second,.third,.fourth,.fifth], wizardLevels: ClassLevel(classEnum: .wizard, count: 9), proficiencyBonus: bekri.proficiencyBonus()), reducer: SpellPointsReducer.init))
}
