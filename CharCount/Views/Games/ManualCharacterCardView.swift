//
//  ManualCharacterCardView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/22/24.
//

import SwiftUI
import ComposableArchitecture

@ObservableState
struct ManualCharacter: Codable, Identifiable, Equatable {
    var id = Current.uuid()
    var name: String
    var ac: String
    var dc: String
    var pp: String
}

@Reducer
struct ManualCharacterReducer {
    typealias State = ManualCharacter
    
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

struct ManualCharacterCardView: View {
    @Bindable var store: StoreOf<ManualCharacterReducer>
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Text("DC: \(store.state.dc)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("PP: \(store.state.pp)")
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(store.name)")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                        .padding(.vertical, 4)
                    Text("AC: \(store.ac)")
                        .foregroundStyle(Color.accentColor)
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
}

#Preview {
    ManualCharacterCardView(store: Store(initialState: ManualCharacter(name: "Bekri", ac: "21", dc: "17", pp: "18"), reducer: ManualCharacterReducer.init))
}

