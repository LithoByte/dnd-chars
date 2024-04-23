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
struct GameListView<RowContent: View,
                       EditContent: View,
                       DetailsContent: View>: View {
    @Environment(\.scenePhase) var scenePhase
    let title: String
    @Bindable var store: StoreOf<GameListReducer>
    let rowContent: (StoreOf<GameItemReducer>) -> RowContent
    let detailsContent: (StoreOf<GameReducer>) -> DetailsContent
    let editContent: (StoreOf<EditGameReducer>) -> EditContent
    
    var body: some View {
        WithPerceptionTracking {
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
                        rowContent(gameStore)
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
            .navigationTitle("Games")
            .toolbar(content: {
                HStack {
                    Spacer()
                    Button(action: { store.send(.addNewTapped) }, label: {
                        Image(systemName: "plus")
                    })
                }
            })
            .navigationDestination(item: $store.scope(state: \.details, action: \.details)) { store in
                detailsContent(store)
            }
            .navigationDestination(item: $store.scope(state: \.tabs, action: \.tabs)) { store in
                TabsView(store: store)
            }
            .sheet(item: $store.scope(state: \.new, action: \.edit)) { editStore in
                NavigationStack {
                    editContent(editStore)
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { store.send(.cancelGame) }
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save") { store.send(.saveGame) }
                            }
                        })
                        .navigationTitle("New Game")
                }
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
}

#Preview {
    NavigationStack {
        GameListView(
            title: "Games",
            store: Store(
                initialState: GameListReducer.State(
                    allGames: IdentifiedArray(uniqueElements: [Game(name: "Elliot's game")]),
                    gameToItemState: { $0 }
                ),
                reducer: GameListReducer.init),
            rowContent: GameRowView.init,
            detailsContent: GameView.init,
            editContent: EditGameView.init
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
