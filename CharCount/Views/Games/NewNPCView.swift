//
//  NewNPCView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NewNPCReducer {
    
    @ObservableState
    struct State: Equatable {
        var name: String = ""
        var ac: String = ""
        var hp: String = ""
        var count: String = ""
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
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

struct NewNPCView: View {
    @Bindable var store: StoreOf<NewNPCReducer>
    
    var body: some View {
        HStack {
            VStack {
                TextField("Name", text: $store.name)
                    .textInputAutocapitalization(.words)
                    .padding(8)
                TextField("How many?", text: $store.count)
                    .keyboardType(.numberPad)
                    .padding(8)
            }
            VStack {
                TextField("AC", text: $store.ac)
                    .keyboardType(.numberPad)
                    .padding(8)
                TextField("HP", text: $store.hp)
                    .keyboardType(.numberPad)
                    .padding(8)
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    NewNPCView(store: Store(initialState: NewNPCReducer.State(), reducer: NewNPCReducer.init))
}
