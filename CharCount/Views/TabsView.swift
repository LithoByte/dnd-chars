//
//  TabsView.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/6/24.
//

import SwiftUI
import ComposableArchitecture

struct TabsView: View {
    @Bindable var store: StoreOf<TabsReducer>
    
    var body: some View {
        TabView(selection: $store.currentTab.sending(\.tabSelected)) {
            HitPointsView(store: store.scope(state: \.hpState, action: \.hpTab))
            .tabItem {
                VStack {
                    Image(systemName: "heart.fill")
                    Text("HP")
                }
            }
            .tag(Tab.hitPoints)
            IfLetStore(store.scope(state: \.spState, action: \.spTab)) { spellStore in
                SpellPointsView(store: spellStore)
                .tabItem {
                    VStack {
                        Image(systemName: "sun.min.fill")
                        Text("Spell Pts")
                    }
                }
                .tag(Tab.spellPoints)
            }
            IfLetStore(store.scope(state: \.slotsState, action: \.slotsTab)) { spellStore in
                SpellSlotsView(store: spellStore)
                .tabItem {
                    VStack {
                        Image(systemName: "sun.min.fill")//.foregroundStyle(LinearGradient(gradient: Gradient(colors: [.accent, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text("Spell Slots")//.foregroundStyle(LinearGradient(gradient: Gradient(colors: [.accent, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .tag(Tab.spellSlots)
            }
            ResourcesView(store: store.scope(state: \.resourceState, action: \.resourceTab))
            .tabItem {
                VStack {
                    Image(systemName: "briefcase.fill")
                    Text("Resources")
                }
            }
            .tag(Tab.resources)
        }
        .navigationTitle(store.name)
    }
}

#Preview {
    TabsView(store: Store(initialState: TabsReducer.State(&bekri), reducer: TabsReducer.init))
}
