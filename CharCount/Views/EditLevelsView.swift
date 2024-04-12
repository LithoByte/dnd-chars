//
//  EditLevelsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/7/24.
//

import SwiftUI
import ComposableArchitecture

struct EditLevelsView: View {
    var store: StoreOf<EditLevelsReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                TextField("0", text: viewStore.binding(get: \.count.description, send: { .setLevels($0) }))
                    .frame(maxWidth: 24)
                    .keyboardType(.numberPad)
                Text("levels of")
                Picker("", selection: viewStore.binding(get: \.classEnum, send: { .setClass($0) })) {
                    ForEach(ClassEnum.allCases, id: \.self) {
                        Text($0.rawValue).tag(Optional($0))
                    }
                }
            }
        }
    }
}

#Preview {
    EditLevelsView(store: Store(initialState: ClassLevel(classEnum: .wizard, count: 9), reducer: EditLevelsReducer.init))
}
