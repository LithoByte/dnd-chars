//
//  NPCCardView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NPCReducer {
    typealias State = NPC
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case updateHP
        case removeTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case adjustHitPoints
            case removeTapped
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            default: break
            }
            return .none
        }
    }
}

struct NPCCardView: View {
    @Bindable var store: StoreOf<NPCReducer>
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("AC: \(store.ac)")
                            .foregroundStyle(.secondary)
                        VStack {
                            Text("\(store.name)")
                                .foregroundStyle(Color.accentColor)
                                .font(.largeTitle)
                                .padding(.vertical, 4)
                            Text("\(store.hp)hp")
                                .foregroundStyle(Color.accentColor)
                                .onTapGesture {
                                    store.send(.updateHP)
                                }
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1)
                }
                .padding(8)
            }
            Spacer()
        }
    }
}

#Preview {
    NPCCardView(store: Store(initialState: archer, reducer: NPCReducer.init))
}
