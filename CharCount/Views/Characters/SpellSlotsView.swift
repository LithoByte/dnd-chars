//
//  SpellSlotsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/10/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SpellSlotsReducer {
    @ObservableState
    struct State: Equatable {
        var slots: [SlotLevel]
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case toggleSlot(SpellLevel, Int)
        case restoreTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .toggleSlot(let level, let index):
                state.slots = state.slots.map {
                    if $0.level == level {
                        var newSlots = $0.slots
                        newSlots[index].isUsed.toggle()
                        return SlotLevel(id: $0.id, level: level, slots: newSlots)
                    }
                    return $0
                }
            case .restoreTapped:
                state.slots = state.slots.map {
                    return SlotLevel(id: $0.id, level: $0.level, slots: $0.slots.map { SpellSlot(level: $0.level) })
                }
            default: break
            }
            return .none
        }
    }
}

let magicGradient = LinearGradient(gradient: Gradient(colors: [.teal, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing)

struct SpellSlotsView: View {
    @Bindable var store: StoreOf<SpellSlotsReducer>
    
    var body: some View {
        VStack {
            List {
                ForEach(store.slots) { slotSet in
                    HStack {
                        Text("\(slotSet.level.toString())")
                        Spacer()
                        ForEach(0..<slotSet.slots.count) { index in
                            Image(systemName: slotSet.slots[index].isUsed ? "checkmark.square" : "square")
                                .foregroundStyle(Color.accentColor)
                                .onTapGesture {
                                    store.send(.toggleSlot(slotSet.level, index))
                                }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: { store.send(.restoreTapped) }) {
                    Text("Restore all")
//                        .foregroundStyle(magicGradient)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1)
                }
                .padding(8)
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Spell Slots")
    }
}

#Preview {
    SpellSlotsView(store: Store(initialState: SpellSlotsReducer.State(slots: rieta.maxSpellSlots()), reducer: SpellSlotsReducer.init))
}
