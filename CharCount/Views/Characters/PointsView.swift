//
//  PointsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct PointsReducer {
    
    typealias State = PointSource
    
    enum Action: Equatable {
        case adjustPoints(Int)
        case didTap
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case didTap(PointSource)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .adjustPoints(let value):
                let newValue = state.currentPoints + value
                if newValue <= state.maxPoints && newValue >= 0 {
                    state.currentPoints = newValue
                }
            case .didTap:
                return .send(.delegate(.didTap(state)))
            case .delegate(_): break
            }
            return .none
        }
    }
}

let buttonSize: CGFloat = 40 // 56
struct PointsView: View {
    @Bindable var store: StoreOf<PointsReducer>
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Text("Max: \(store.maxPoints)")
                            .foregroundStyle(.secondary)
                    }
                    VStack {
                        Text("\(store.currentPoints)")
                            .foregroundStyle(Color.accentColor)
                            .font(.largeTitle)
                            .padding(.vertical, 4)
                        Text("\(store.title)")
                            .foregroundStyle(Color.accentColor)
                    }
                    .onTapGesture {
                        store.send(.didTap)
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                VStack {
                    Button(action: { store.send(.adjustPoints(1)) }, label: {
                        Image(systemName: "plus")
                            .padding(4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(buttonSize / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .frame(width: buttonSize, height: buttonSize, alignment: .center)
                    })
                    .buttonStyle(.borderless)
                    Button(action: { store.send(.adjustPoints(-1)) }, label: {
                        Image(systemName: "minus")
                            .padding(4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(buttonSize / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .frame(width: buttonSize, height: buttonSize, alignment: .center)
                    })
                    .buttonStyle(.borderless)
                }
                .background(Color.increment)
                .cornerRadius((buttonSize + 8) / 2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
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
    PointsView(store: Store(initialState: PointsReducer.State(title: "Hit Points", currentPoints: 42, maxPoints: 42, pointsType: .innate), reducer: PointsReducer.init))
}
