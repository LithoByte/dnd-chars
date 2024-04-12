//
//  HitPointsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import SwiftUI
import ComposableArchitecture

struct HitPointsView: View {
    @Bindable var store: StoreOf<HitPointsReducer>
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEachStore(store.scope(state: \.sources, action: HitPointsReducer.Action.source(_:_:))) { store in
                        PointsView(store: store)
                    }
                    .onDelete { indexSet in
                        store.send(.delete(indexSet))
                    }
                }
                Spacer()
                
                Button(action: { store.send(.adjustHitPointsTapped) }) {
                    Text("Damage/Healing")
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Button(action: { store.send(.restoreTapped) }) {
                        Text("Restore all")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(4)
                    
                    Button(action: { store.send(.addTapped) }) {
                        Text("Add HP Source")
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
            .blur(radius: (store.shouldBlur ? 5 : 0))
            
            IfLetStore(store.scope(state: \.editSource, action: \.editSource)) { editStore in
                Spacer()
                VStack {
                    EditSourceView(store: editStore)
                    HStack {
                        Button(action: { store.send(.cancelTapped) }) {
                            Text("Cancel")
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                        }
                        .padding()
                        
                        Button(action: { store.send(.saveTapped) }) {
                            Text("Save")
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                        }
                        .padding()
                    }
                }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .padding()
                Spacer()
            }
            IfLetStore(store.scope(state: \.editPoints, action: \.editPoints)) { editStore in
                Spacer()
                VStack {
                    EditPointsView(store: editStore)
                    HStack {
                        Button(action: { store.send(.removePoints) }) {
                            Text("Damage")
                                .foregroundStyle(.red)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        
                        Button(action: { store.send(.addPoints) }) {
                            Text("Healing")
                                .foregroundStyle(.green)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                    }
                    Button(action: { store.send(.cancelTapped) }) {
                        Text("Cancel")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding()
                }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .padding()
                Spacer()
            }
        }
    }
}

let bekriSources = IdentifiedArray(uniqueElements: [
    PointsReducer.State(title: "Hit Points", currentPoints: 42, maxPoints: 42, pointsType: .innate),
    PointsReducer.State(title: "Additional HP", currentPoints: 5, maxPoints: 5, pointsType: .temporary),
    PointsReducer.State(title: "Temp HP", currentPoints: 5, maxPoints: 5, pointsType: .temporary),
    PointsReducer.State(title: "Arcane Ward HP", currentPoints: 10, maxPoints: 10, pointsType: .temporary)
])
#Preview {
    HitPointsView(store: Store(initialState: HitPointsReducer.State(sources: bekriSources), reducer: HitPointsReducer.init))
}
