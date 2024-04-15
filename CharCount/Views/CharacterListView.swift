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
                    ForEachStore(self.store.scope(state: \.displayedCharacterStates, action: CharacterListReducer.Action.character(_:_:))) { characterStore in
                        rowContent(characterStore)
                    }
                    .onDelete { indexSet in
                        store.send(.delete(indexSet))
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
                    GameView(store: store)
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
            .accentColor(viewAccentColor())
        }
    }
    
    func viewAccentColor() -> Color {
        return switch store.details?.currentTab {
        case .hitPoints, nil: .accent
        case .spellSlots, .spellPoints: .indigo
        case .resources: .brown
        }
    }
}

//let callState = NetCallReducer.State(session: Current.session, baseUrl: Current.baseUrl, endpoint: Endpoint(), pagingInfo: PagingMeta(perPage: 17), firingFunc: NetCallReducer.mockFire(with: json.data(using: .utf8)))
//let charactersState = NetCharactersReducer<Character, CharactersWrapper>.State(characters: .init(), charactersCallState: callState, unwrap: { $0.characters })
#Preview {
    CharacterListView(
        title: "Characters",
        store: Store(
            initialState: CharacterListReducer.State(
                allCharacters: IdentifiedArray(uniqueElements: [bekri]),
                characterToItemState: { $0 }
            ),
            reducer: CharacterListReducer.init),
        rowContent: CharacterRowView.init,
        detailsContent: TabsView.init,
        editContent: EditCharacterView.init
    )
}
