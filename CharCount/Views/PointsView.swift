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
                state.currentPoints += value
            case .didTap:
                return .send(.delegate(.didTap(state)))
            case .delegate(_):
                break
            }
            return .none
        }
    }
}

struct PointsView: View {
    @Bindable var store: StoreOf<PointsReducer>
    
    var body: some View {
        VStack {
            HStack {
                Text("Max \(store.title): \(store.maxPoints)")
                    .foregroundStyle(.secondary)
            }
            VStack {
                Text("\(store.currentPoints)")
//                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.accent, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundStyle(Color.accentColor)
                    .font(.largeTitle)
                    .padding(.vertical, 4)
                Text("Current \(store.title)")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1)
        }
        .padding()
        .onTapGesture {
            store.send(.didTap)
        }
    }
}

#Preview {
    PointsView(store: Store(initialState: PointsReducer.State(title: "Hit Points", currentPoints: 42, maxPoints: 42, pointsType: .innate), reducer: PointsReducer.init))
}
