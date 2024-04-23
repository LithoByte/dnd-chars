//
//  EditManualCharacterView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/22/24.
//

import SwiftUI
import ComposableArchitecture

struct EditManualCharacterView: View {
    @Bindable var store: StoreOf<ManualCharacterReducer>
    
    var body: some View {
        HStack {
            VStack {
                TextField("Name", text: $store.name)
                    .textInputAutocapitalization(.words)
                    .padding(8)
                TextField("Spell DC", text: $store.dc)
                    .keyboardType(.numberPad)
                    .padding(8)
            }
            VStack {
                TextField("AC", text: $store.ac)
                    .keyboardType(.numberPad)
                    .padding(8)
                TextField("Passive Perception", text: $store.pp)
                    .keyboardType(.numberPad)
                    .padding(8)
            }
            .padding(.horizontal, 8)
        }
    }
}

//#Preview {
//    EditManualCharacterView()
//}
