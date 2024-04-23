//
//  HitPointsReducer.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HitPointsReducer {
    
    @ObservableState
    struct State: Equatable {
        var sources = IdentifiedArray(uniqueElements: [PointsReducer.State]())
        @Presents var editSource: EditSourceReducer.State?
        @Presents var editPoints: EditPointsReducer.State?
        
        var shouldBlur: Bool {
            return editSource != nil || editPoints != nil
        }
    }
    
    enum Action: Equatable {
        case source(PointsReducer.State.ID, PointsReducer.Action)
        case addTapped, saveTapped, cancelTapped
        case restoreTapped
        case adjustHitPointsTapped
        case addPoints
        case removePoints
        case delete(IndexSet)
        case editSource(EditSourceReducer.Action)
        case editPoints(EditPointsReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delete(let indexSet):
                state.sources.remove(atOffsets: indexSet)
            case .source(_, .delegate(.didTap(let source))):
                state.editSource = EditSourceReducer.State(id: source.id, name: source.title, currentPoints: "\(source.currentPoints)", maxPoints: "\(source.maxPoints)", pointsType: source.pointsType)
            case .source(_, _): break
            case .adjustHitPointsTapped:
                state.editPoints = EditPointsReducer.State(sources: state.sources.map { ChecklistItem(title: $0.title) }.reversed())
            case .addTapped:
                state.editSource = EditSourceReducer.State(name: "", currentPoints: "", maxPoints: "", pointsType: .temporary)
            case .restoreTapped:
                let newSources = state.sources.map { PointsReducer.State(title: $0.title, currentPoints: $0.maxPoints, maxPoints: $0.maxPoints, pointsType: $0.pointsType) }
                state.sources = IdentifiedArray(uniqueElements: newSources)
            case .addPoints:
                if let pointsState = state.editPoints, var points = Int(pointsState.points) {
                    let titles = pointsState.sources.filter { $0.isChecked }.map { $0.title }
                    var newSources = [PointsReducer.State]()
                    PointsType.allCases.forEach {
                        add(points: &points, forType: $0, inSources: state.sources.elements, inTitles: titles, withNewSources: &newSources)
                    }
                    
                    state.sources = IdentifiedArray(uniqueElements: newSources.sorted { $0.pointsType.orderValue() < $1.pointsType.orderValue() })
                }
                state.editPoints = nil
            case .removePoints:
                if let pointsState = state.editPoints, var points = Int(pointsState.points) {
                    let titles = pointsState.sources.filter { $0.isChecked }.map { $0.title }
                    var newSources = [PointsReducer.State]()
                    PointsType.allCases.reversed().forEach {
                        remove(points: &points, forType: $0, inSources: state.sources.elements, inTitles: titles, withNewSources: &newSources)
                    }
                    
                    state.sources = IdentifiedArray(uniqueElements: newSources.sorted { $0.pointsType.orderValue() < $1.pointsType.orderValue() })
                }
                state.editPoints = nil
            case .saveTapped:
                if let source = state.editSource, let maxPts = Int(source.maxPoints) {
                    if let _ = state.sources[id: source.id] {
                        state.sources[id: source.id]?.title = source.name
                        state.sources[id: source.id]?.currentPoints = Int(source.currentPoints ?? "\(maxPts)") ?? 0
                        state.sources[id: source.id]?.maxPoints = maxPts
                        state.sources[id: source.id]?.pointsType = source.pointsType
                    } else {
                        var sources = state.sources
                        sources.append(PointsReducer.State(title: source.name, currentPoints: maxPts, maxPoints: maxPts, pointsType: source.pointsType))
                        sources.sort { $0.pointsType.orderValue() < $1.pointsType.orderValue() }
                        state.sources = sources
                    }
                }
                state.editSource = nil
            case .cancelTapped:
                state.editSource = nil
                state.editPoints = nil
            case .editSource(_): break
            case .editPoints(_): break
            }
            return .none
        }
        .ifLet(\.editSource, action: /Action.editSource) {
            EditSourceReducer()
        }
        .ifLet(\.editPoints, action: /Action.editPoints) {
            EditPointsReducer()
        }
        .forEach(\.sources, action: /Action.source(_:_:)) {
            PointsReducer()
        }
    }
}

func add(points: inout Int, forType type: PointsType, inSources sources: [PointsReducer.State], inTitles titles: [String], withNewSources newSources: inout [PointsReducer.State]) {
    for source in sources.filter({ $0.pointsType == type }) {
        if points > 0 && titles.contains(source.title) {
            let newCurrent = min(source.maxPoints, source.currentPoints + points)
            newSources.append(PointsReducer.State(title: source.title, currentPoints: newCurrent, maxPoints: source.maxPoints, pointsType: source.pointsType))
            points -= (source.maxPoints - source.currentPoints)
        } else {
            newSources.append(source)
        }
    }
}

func remove(points: inout Int, forType type: PointsType, inSources sources: [PointsReducer.State], inTitles titles: [String], withNewSources newSources: inout [PointsReducer.State]) {
    for source in sources.filter({ $0.pointsType == type }) {
        if points > 0 && titles.contains(source.title) {
            let newCurrent = max(0, source.currentPoints - points)
            newSources.append(PointsReducer.State(title: source.title, currentPoints: newCurrent, maxPoints: source.maxPoints, pointsType: source.pointsType))
            points -= source.currentPoints
        } else {
            newSources.append(source)
        }
    }
}
