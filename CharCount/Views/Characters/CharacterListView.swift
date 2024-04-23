//
//  CharacterListView.swift
//  Template
//
//  Created by Elliot Schrock on 2/15/24.
//

import SwiftUI
import ComposableArchitecture

let margin: CGFloat = 16
struct CharacterListView<RowContent: View,
                       EditContent: View,
                       DetailsContent: View>: View {
    @Environment(\.scenePhase) var scenePhase
    let title: String
    @Bindable var store: StoreOf<CharacterListReducer>
    let rowContent: (StoreOf<CharacterItemReducer>) -> RowContent
    let detailsContent: (StoreOf<TabsReducer>) -> DetailsContent
    let editContent: (StoreOf<EditCharacterReducer>) -> EditContent
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                List {
                    if self.store.displayedCharacterStates.count > 0 {
                        ForEachStore(self.store.scope(state: \.displayedCharacterStates, action: CharacterListReducer.Action.character(_:_:))) { characterStore in
                            rowContent(characterStore)
                        }
                        .onDelete { indexSet in
                            store.send(.delete(indexSet))
                        }
                    } else {
                        VStack(alignment: .center) {
                            Text("No characters yet!")
                                .font(.title)
                            Text("Add one with the button below or the '+' in the upper right corner.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button(action: { store.send(.addNewTapped) }, label: {
                                Text("Add character")
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke()
                                    }
                            })
                        }
                    }
                }
                .navigationTitle(title)
                .toolbar(content: {
                    HStack {
                        Spacer()
                        Button(action: { store.send(.addNewTapped) }, label: {
                            Image(systemName: "plus")
                        })
                        Button(action: { store.send(.gamesTapped) }, label: {
                            Image(systemName: "person.3.fill")
                        })
                    }
                })
                .onAppear {
                    store.send(.didAppear)
                }
                .navigationDestination(item: $store.scope(state: \.details, action: \.details)) { store in
                    detailsContent(store)
                }
                .navigationDestination(item: $store.scope(state: \.games, action: \.games)) { store in
                    GameListView(
                        title: "Games",
                        store: store,
                        rowContent: GameRowView.init,
                        detailsContent: GameView.init,
                        editContent: EditGameView.init
                    )
                }
                .sheet(item: $store.scope(state: \.new, action: \.new)) { editStore in
                    NavigationStack {
                        editContent(editStore)
                            .toolbar(content: {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { store.send(.cancelCharacter) }
                                }
                                ToolbarItem(placement: .primaryAction) {
                                    Button("Save") { store.send(.saveCharacter) }
                                }
                            })
                            .navigationTitle("New Character")
                    }
                }
                .sheet(item: $store.scope(state: \.edit, action: \.edit)) { editStore in
                    NavigationStack {
                        editContent(editStore)
                            .toolbar(content: {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { store.send(.cancelCharacter) }
                                }
                                ToolbarItem(placement: .primaryAction) {
                                    Button("Save") { store.send(.saveCharacter) }
                                }
                            })
                            .navigationTitle("Edit Character")
                    }
                }
            }
            .searchable(text: $store.localFilter)
            .onChange(of: scenePhase) {
                store.send(.didChangeScenePhase)
            }
//            .accentColor(LinearGradient(gradient: Gradient(colors: [.accent, .indigo]), startPoint: .leading, endPoint: .trailing))
        }
    }
}

#Preview {
    CharacterListView(
        title: "Characters",
        store: Store(
            initialState: CharacterListReducer.State(
                allCharacters: IdentifiedArray(uniqueElements: []),
                characterToItemState: { $0 }
            ),
            reducer: CharacterListReducer.init),
        rowContent: CharacterRowView.init,
        detailsContent: TabsView.init,
        editContent: EditCharacterView.init
    )
}
