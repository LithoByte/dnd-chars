//
//  GameView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct GameReducer {
    
    @ObservableState
    struct State: Equatable {
        var gameTitle: String
        var allCreatures: IdentifiedArrayOf<CardReducer.State>
        @Presents var editPoints: EditPointsReducer.State?
        @Presents var editNPC: NewNPCReducer.State?
        
        var shouldBlur: Bool {
            return editPoints != nil || editNPC != nil
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case creature(CardReducer.State.ID, CardReducer.Action)
        case addTapped, saveTapped, cancelTapped
        case addPoints
        case removePoints
        case move(IndexSet, Int)
        case delete(IndexSet)
        case adjustHitPointsTapped
        case editNPC(NewNPCReducer.Action)
        case editSource(EditSourceReducer.Action)
        case editPoints(EditPointsReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .adjustHitPointsTapped:
                state.editPoints = EditPointsReducer.State(sources: state.allCreatures.compactMap { $0.npc }.map { ChecklistItem(title: $0.name) }.reversed())
            case .addTapped:
                state.editNPC = NewNPCReducer.State()
            case .delete(let indices):
                state.allCreatures.remove(atOffsets: indices)
            case .move(let set, let offset):
                state.allCreatures.move(fromOffsets: set, toOffset: offset)
            case .saveTapped:
                if let npcState = state.editNPC, let ac = Int(npcState.ac), let hp = Int(npcState.hp) {
                    if let count = Int(npcState.count) {
                        for i in 0..<count {
                            let npc = NPC(name: "\(npcState.name) \(count - i)", ac: ac, hp: hp, maxHp: hp)
                            state.allCreatures.insert(CardReducer.State(npc: npc), at: 0)
                        }
                    } else {
                        let npc = NPC(name: npcState.name, ac: ac, hp: hp, maxHp: hp)
                        state.allCreatures.insert(CardReducer.State(npc: npc), at: 0)
                    }
                }
                state.editNPC = nil
                state.editPoints = nil
            case .cancelTapped:
                state.editNPC = nil
                state.editPoints = nil
            case .addPoints:
                if let pointsState = state.editPoints, let points = Int(pointsState.points) {
                    let titles = pointsState.sources.filter { $0.isChecked }.map { $0.title }
                    for card in state.allCreatures.filter({ $0.npc != nil }).filter({ titles.contains($0.npc?.name ?? "") }) {
                        let creature = card.npc!
                        let newPoints = min(creature.maxHp, creature.hp + points)
                        state.allCreatures[id: card.id]?.npc?.hp = newPoints
                    }
                }
                state.editPoints = nil
            case .removePoints:
                if let pointsState = state.editPoints, let points = Int(pointsState.points) {
                    let titles = pointsState.sources.filter { $0.isChecked }.map { $0.title }
                    for card in state.allCreatures.filter({ $0.npc != nil }).filter({ titles.contains($0.npc?.name ?? "") }) {
                        let creature = card.npc!
                        let newPoints = max(0, creature.hp - points)
                        state.allCreatures[id: card.id]?.npc?.hp = newPoints
                    }
                }
                state.editPoints = nil
            default: break
            }
            return .none
        }
        .ifLet(\.editPoints, action: /Action.editPoints) {
            EditPointsReducer()
        }
        .ifLet(\.editNPC, action: /Action.editNPC) {
            NewNPCReducer()
        }
    }
}

struct GameView: View {
    @Bindable var store: StoreOf<GameReducer>
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEachStore(store.scope(state: \.allCreatures, action: GameReducer.Action.creature(_:_:))) { modelStore in
                        CardView(store: modelStore)
                    }
                    .onMove { indices, newOffset in
                        store.send(.move(indices, newOffset))
                    }
                    .onDelete { indices in
                        store.send(.delete(indices))
                    }
                }
                .listStyle(.plain)
                .navigationTitle(store.gameTitle)
                .toolbar(content: {
                    HStack {
                        Spacer()
                        Button(action: { store.send(.addTapped) }, label: {
                            Image(systemName: "plus")
                        })
                    }
                })
                
                
                Button(action: { store.send(.adjustHitPointsTapped) }) {
                    Text("Damage/Healing")
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding(.horizontal, 16)
            }
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
        GameView(store: Store(initialState: GameReducer.State(gameTitle: "Elliot's Game", allCreatures: IdentifiedArray(uniqueElements: creatures)), reducer: GameReducer.init))
    }
}
