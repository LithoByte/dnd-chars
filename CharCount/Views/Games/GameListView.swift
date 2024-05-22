//
//  GameListView.swift
//  Template
//
//  Created by Elliot Schrock on 4/18/24.
//

import SwiftUI
import ComposableArchitecture
import CoreBluetooth

let listMargin: CGFloat = 16
struct GameListView: View {
    @Bindable var store: StoreOf<GameListReducer>
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            List {
                if CBCentralManager.authorization == .notDetermined {
                    VStack(alignment: .center) {
                        Text("To see games nearby, enable bluetooth")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("You'll also need to enable bluetooth to create/host your own game — at least with this app 🙂")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: { store.send(.requestBle) }, label: {
                            Text("Enable bluetooth")
                                .padding()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke()
                                }
                        })
                    }
                } else if CBCentralManager.authorization == .denied {
                    DeniedBluetooth()
                } else if store.displayedGameStates.count > 0 {
                    ForEachStore(self.store.scope(state: \.displayedGameStates, action: GameListReducer.Action.game(_:_:))) { gameStore in
                        GameRowView(store: gameStore)
                    }
                } else {
                    VStack(alignment: .center) {
                        Text("No games detected yet!")
                            .font(.title)
                        Text("If you're expecting one, make sure bluetooth is turned on, and otherwise, give it a sec. \n\nYou can also host your own with the button below or the '+' in the upper right corner.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: { store.send(.addNewTapped) }, label: {
                            Text("Host game")
                                .padding()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke()
                                }
                        })
                    }
                }
            }
            .searchable(text: $store.localFilter)
            .navigationTitle("Games Nearby")
            .toolbar {
                HStack {
                    Spacer()
                    Button(action: { store.send(.addNewTapped) }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .blur(radius: (store.shouldBlur ? 5 : 0))
            
            IfLetStore(store.scope(state: \.new, action: \.edit)) { editStore in
                Spacer()
                VStack {
                    EditGameView(store: editStore)
                    HStack {
                        Button(action: { store.send(.cancelGame) }) {
                            Text("Cancel")
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                        }
                        .padding()
                        
                        Button(action: { store.send(.saveGame) }) {
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
                Spacer()
            }
        }
        .navigationDestination(item: $store.scope(state: \.details, action: \.details)) { store in
            GameView(store: store)
        }
        .navigationDestination(item: $store.scope(state: \.tabs, action: \.tabs)) { store in
            TabsView(store: store)
        }
        .sheet(item: $store.scope(state: \.choose, action: \.choose), content: { chooseStore in
            CharacterChooserView(store: chooseStore)
        })
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .onChange(of: scenePhase) { newScenePhase in
            store.send(.didChangeScenePhase(newScenePhase))
        }
    }
}

let previewGames = [Game(name: "Oshland", playerCount: 1), Game(name: "Graywall", playerCount: 3), Game(name: "Dawn", playerCount: 3), Game(name: "The Adjusters", playerCount: 5), Game(name: "High Five Heroes", playerCount: 6)]

#Preview {
    NavigationStack {
        GameListView(
            store: Store(
                initialState: GameListReducer.State(
                    allGames: IdentifiedArray(uniqueElements: previewGames),
                    gameToItemState: { $0 }
                ),
                reducer: GameListReducer.init)
        )
    }
}

struct DeniedBluetooth: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Bluetooth access denied")
                .font(.title)
            Text("Looks like you denied access to bluetooth — without it, we can't detect nearby games. If you'd like to join or host a game, go to settings and give permission to use bluetooth.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil) }, label: {
                Text("Go to settings")
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke()
                    }
            })
        }
    }
}
