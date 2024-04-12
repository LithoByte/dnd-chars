//
//  EditSourceView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/8/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct EditSourceReducer {
    
    @ObservableState
    struct State: Equatable {
        var id = Current.uuid()
        var name: String
        var currentPoints: String
        var maxPoints: String
        var pointsType: PointsType
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case changedPointsType(PointsType)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .changedPointsType(let pointsType):
                state.pointsType = pointsType
            default: break
            }
            return .none
        }
    }
}

struct EditSourceView: View {
    @Bindable var store: StoreOf<EditSourceReducer>
    
    var body: some View {
        VStack {
            HStack {
                Text("Name: ")
                Spacer()
                TextField("Temporary Hit Points", text: $store.name)
                    .textInputAutocapitalization(.words)
                    .frame(maxWidth: 160)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 16)
            HStack {
                Text("Max: ")
                Spacer()
                TextField("42", text: $store.maxPoints)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 100)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            HStack {
                Text("Current: ")
                Spacer()
                TextField("42", text: $store.currentPoints)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 100)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            HStack {
                Text("Type: ")
                Spacer()
                Picker("Type", selection: $store.pointsType.sending(\.changedPointsType)) {
                    ForEach(PointsType.allCases, id: \.self) {
                        Text($0.rawValue).tag(Optional($0))
                    }
                }
            }
            .padding(.horizontal, 16)
            ScrollView {
                Text("""
- Use "innate" for your regular hit points, if the ones calculated are incorrect for some reason.
- Use "additional" for effects like the Aid spell, which increase your regular hit points by a certain amount.
- Use "temporary" for temp HP.
- Use "other" for things like Arcane Ward, which are not healed by regular means.
""").padding()
            }
        }
    }
}

#Preview {
    EditSourceView(store: Store(initialState: EditSourceReducer.State(name: "Temporary Hit Points", currentPoints: "", maxPoints: "10", pointsType: .temporary), reducer: EditSourceReducer.init))
}
