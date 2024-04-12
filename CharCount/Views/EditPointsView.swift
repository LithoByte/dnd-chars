//
//  EditPointsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/8/24.
//

import SwiftUI
import ComposableArchitecture

struct ChecklistItem: Equatable {
    var isChecked = true
    var title: String
}

@Reducer
struct EditPointsReducer {
    @ObservableState
    struct State: Equatable {
        var sources = [ChecklistItem]()
        var points: String = ""
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toggle(String)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_): break
            case .toggle(let title):
                state.sources = state.sources.map {
                    if $0.title == title {
                        return ChecklistItem(isChecked: !$0.isChecked, title: $0.title)
                    }
                    return $0
                }
            }
            return .none
        }
    }
}

struct EditPointsView: View {
    @Bindable var store: StoreOf<EditPointsReducer>
    @FocusState var isFocusedYes
    
    var body: some View {
        TextField("Points", text: $store.points)
            .font(.title)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($isFocusedYes)
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1)
            }
            .padding(.horizontal, 16)
        Text("Applied to:")
        List(store.sources, id: \.title) { item in
            HStack{
                Button(action: { store.send(.toggle(item.title)) }) {
                    Image(systemName: item.isChecked ? "checkmark.square" : "square")
                }
                Text(item.title)
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: 200)
        .onAppear {
            isFocusedYes = true
        }
    }
}

#Preview {
    EditPointsView(store: Store(initialState: EditPointsReducer.State(sources: [ChecklistItem(title: "innate"), ChecklistItem(title: "temp")].reversed()), reducer: EditPointsReducer.init))
}
