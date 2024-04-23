//
//  TabsReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import ComposableArchitecture
import Foundation

enum Tab: Equatable {
    case hitPoints, spellPoints, spellSlots, resources
}

@Reducer
struct TabsReducer {
    @ObservableState
    struct State: Equatable {
        var id: Character.ID
        var name: String
        var currentTab: Tab = .hitPoints
        var hpState: HitPointsReducer.State
        var spState: SpellPointsReducer.State?
        var slotsState: SpellSlotsReducer.State?
        var resourceState: ResourcesReducer.State
        
        init(_ character: inout Character) {
            id = character.id
            name = character.name
            if character.hpSources.count == 0 {
                hpState = HitPointsReducer.State(sources: IdentifiedArray<UUID, PointsReducer.State>(uniqueElements: [PointSource(title: "Hit Points", currentPoints: try! character.maxHitPoints(), maxPoints: try! character.maxHitPoints(), pointsType: .innate)]))
            } else {
                hpState = HitPointsReducer.State(sources: IdentifiedArray<UUID, PointsReducer.State>(uniqueElements: character.hpSources))
            }
            if character.usesSpellPoints {
                if let spellSource = character.spellPoints {
                    spState = SpellPointsReducer.State(source: spellSource, spellLevels: (1...character.maxSpellLevel()).map { SpellLevel(rawValue: $0)! }, wizardLevels: character.levels.first { $0.classEnum == .wizard }, proficiencyBonus: character.proficiencyBonus())
                } else {
                    let spellSource = PointsReducer.State(title: "Spell Points", currentPoints: character.maxSpellPoints(), maxPoints: character.maxSpellPoints(), pointsType: .innate)
                    spState = SpellPointsReducer.State(source: spellSource, spellLevels: (1...character.maxSpellLevel()).map { SpellLevel(rawValue: $0)! }, wizardLevels: character.levels.first { $0.classEnum == .wizard }, proficiencyBonus: character.proficiencyBonus())
                }
            } else {
                if character.spellSlots.count > 0 {
                    slotsState = SpellSlotsReducer.State(slots: character.spellSlots.map { SlotLevel(level: $0.level, slots: $0.slots) })
                } else {
                    slotsState = SpellSlotsReducer.State(slots: character.maxSpellSlots().map { SlotLevel(level: $0.level, slots: $0.slots) })
                }
            }
            resourceState = ResourcesReducer.State(sources: IdentifiedArray<UUID, PointsReducer.State>(uniqueElements: character.resources))
        }
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case hpTab(HitPointsReducer.Action)
        case spTab(SpellPointsReducer.Action)
        case slotsTab(SpellSlotsReducer.Action)
        case resourceTab(ResourcesReducer.Action)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case saveSpellPoints(Character.ID, PointSource)
            case saveHitPoints(Character.ID, [PointSource])
            case saveSpellSlots(Character.ID, [SlotLevel])
            case saveResources(Character.ID, [PointSource])
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.hpState, action: \.hpTab, child: { HitPointsReducer() })
        Scope(state: \.resourceState, action: \.resourceTab, child: { ResourcesReducer() })
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.currentTab = tab
            case .hpTab(_):
                return .send(.delegate(.saveHitPoints(state.id, state.hpState.sources.elements)))
            case .spTab(_):
                return .send(.delegate(.saveSpellPoints(state.id, state.spState!.source)))
            case .slotsTab(_):
                return .send(.delegate(.saveSpellSlots(state.id, state.slotsState!.slots)))
            case .resourceTab(_):
                return .send(.delegate(.saveResources(state.id, state.resourceState.sources.elements)))
            case .delegate(_):
                break
            }
            return .none
        }
        .ifLet(\.spState, action: \.spTab) {
            SpellPointsReducer()
        }
        .ifLet(\.slotsState, action: \.slotsTab) {
            SpellSlotsReducer()
        }
    }
}
