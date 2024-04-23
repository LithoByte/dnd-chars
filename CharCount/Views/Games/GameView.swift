//
//  GameView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

struct GameView: View {
    @Bindable var store: StoreOf<GameReducer>
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    if store.allCreatures.count > 0 {
                        ForEachStore(store.scope(state: \.allCreatures, action: GameReducer.Action.creature(_:_:))) { modelStore in
                            CardView(store: modelStore)
                        }
                        .onMove { indices, newOffset in
                            store.send(.move(indices, newOffset))
                        }
                        .onDelete { indices in
                            store.send(.delete(indices))
                        }
                    } else {
                        VStack(alignment: .center) {
                            Text("No players yet!")
                                .font(.title)
                            Text("If bluetooth is on and enabled, other people nearby can see your game and can join.\n\nIn the meantime, feel free to create some NPCs with the button below or the '+' in the upper right corner.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button(action: { store.send(.addNewNPCTapped) }, label: {
                                Text("Add NPC(s)")
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke()
                                    }
                            })
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle(store.game.name)
                .toolbar(content: {
                    HStack {
                        Spacer()
                        Button(action: { store.send(.addNewNPCTapped) }, label: {
                            Image(systemName: "plus")
                        })
                    }
                })
                
                if store.allCreatures.count > 0 {
                    Button(action: { store.send(.adjustHitPointsTapped) }) {
                        Text("Damage/Healing")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                
                HStack {
                    Button(action: { store.send(.addNewNPCTapped) }) {
                        Text("Add NPC")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(.horizontal, 4)
                    Button(action: { store.send(.addManualCharacterTapped) }) {
                        Text("Add Character")
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 12)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear(perform: {
                store.send(.advertiser(.stopAdvertising))
            })
            .blur(radius: (store.shouldBlur ? 5 : 0))
            
            IfLetStore(store.scope(state: \.editNPC, action: \.editNPC)) { editStore in
                VStack {
                    NewNPCView(store: editStore)
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
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding()
            }
            IfLetStore(store.scope(state: \.editCharacter, action: \.editCharacter)) { editStore in
                VStack {
                    EditManualCharacterView(store: editStore)
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
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding()
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
                        .padding(8)
                        
                        Button(action: { store.send(.addPoints) }) {
                            Text("Healing")
                                .foregroundStyle(.green)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(8)
                    }
                    .padding(.horizontal, 8)
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
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                    }
                    .padding()
                Spacer()
            }
        }
    }
}

let creatures = [CardReducer.State(character: bekri), CardReducer.State(npc: archer), CardReducer.State(character: rieta), CardReducer.State(character: beolac)]
#Preview {
    NavigationStack {
        GameView(store: Store(initialState: GameReducer.State(game: Game(name: "Elliot's Game"), allCreatures: IdentifiedArray(uniqueElements: creatures)), reducer: GameReducer.init))
    }
}
