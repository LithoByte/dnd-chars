//
//  GameReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct GameReducer {
    
    @ObservableState
    struct State: Equatable {
        var game: Game
        var allCreatures: IdentifiedArrayOf<CardReducer.State>
        var advertiser: BLEPeripheralManagerReducer.State?
        @Presents var editPoints: EditPointsReducer.State?
        @Presents var editNPC: NewNPCReducer.State?
        @Presents var editCharacter: ManualCharacterReducer.State?
        
        var shouldBlur: Bool {
            return editPoints != nil || editNPC != nil || editCharacter != nil
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case creature(CardReducer.State.ID, CardReducer.Action)
        case onAppear
        case addNewNPCTapped, saveTapped, cancelTapped
        case addManualCharacterTapped
        case addPoints
        case removePoints
        case move(IndexSet, Int)
        case delete(IndexSet)
        case adjustHitPointsTapped
        case advertiser(BLEPeripheralManagerReducer.Action)
        case editNPC(NewNPCReducer.Action)
        case editSource(EditSourceReducer.Action)
        case editPoints(EditPointsReducer.Action)
        case editCharacter(ManualCharacterReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.game.isCreator {
                    state.advertiser = BLEPeripheralManagerReducer.State(game: state.game)
                    return .send(.advertiser(.initialize))
                }
            case .advertiser(.delegate(.didInitialize)):
                return .send(.advertiser(.startAdvertising))
            case .advertiser(.delegate(.didAdd(let character))):
                state.allCreatures.append(CardReducer.State(character: character))
            case .adjustHitPointsTapped:
                state.editPoints = EditPointsReducer.State(sources: state.allCreatures.compactMap { $0.npc }.map { ChecklistItem(title: $0.name) }.reversed())
            case .addNewNPCTapped:
                state.editNPC = NewNPCReducer.State()
            case .addManualCharacterTapped:
                state.editCharacter = ManualCharacter(name: "", ac: "", dc: "", pp: "")
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
                } else if let manualCharacter = state.editCharacter {
                    state.allCreatures.insert(CardReducer.State(manualCharacter: manualCharacter), at: 0)
                }
                state.editNPC = nil
                state.editPoints = nil
                state.editCharacter = nil
            case .cancelTapped:
                state.editNPC = nil
                state.editPoints = nil
                state.editCharacter = nil
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
        .ifLet(\.editCharacter, action: /Action.editCharacter) {
            ManualCharacterReducer()
        }
        .ifLet(\.advertiser, action: \.advertiser) {
            BLEPeripheralManagerReducer()
        }
    }
}
