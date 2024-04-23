//
//  ResourcesView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/12/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ResourcesReducer {
    @ObservableState
    struct State: Equatable {
        var sources = IdentifiedArray(uniqueElements: [PointsReducer.State]())
        @Presents var editSource: EditSourceReducer.State?
        
        var shouldBlur: Bool {
            return editSource != nil
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case source(PointsReducer.State.ID, PointsReducer.Action)
        case addTapped, saveTapped, cancelTapped
        case restoreTapped
        case delete(IndexSet)
        case editSource(EditSourceReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .delete(let indexSet):
                state.sources.remove(atOffsets: indexSet)
            case .source(_, .delegate(.didTap(let source))):
                state.editSource = EditSourceReducer.State(id: source.id, name: source.title, currentPoints: "\(source.currentPoints)", maxPoints: "\(source.maxPoints)", pointsType: .other, isPoints: false)
            case .source(_, _): break
            case .addTapped:
                state.editSource = EditSourceReducer.State(name: "", currentPoints: "", maxPoints: "", pointsType: .other, isPoints: false)
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
            case .editSource(_): break
            default: break
            }
            return .none
        }
        .ifLet(\.editSource, action: /Action.editSource) {
            EditSourceReducer()
        }
        .forEach(\.sources, action: /Action.source(_:_:)) {
            PointsReducer()
        }
    }
}

struct ResourcesView: View {
    @Bindable var store: StoreOf<ResourcesReducer>
    
    var body: some View {
        
        ZStack {
            
            VStack {
                List {
                    ForEachStore(self.store.scope(state: \.sources, action: ResourcesReducer.Action.source(_:_:))) { pointsStore in
                        PointsView(store: pointsStore)
                    }
                    .onDelete { indexSet in
                        store.send(.delete(indexSet))
                    }
                }
                
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
                        Text("Add Resource")
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
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    ResourcesView(store: Store(initialState: ResourcesReducer.State(sources: bekriSources), reducer: ResourcesReducer.init))
}
