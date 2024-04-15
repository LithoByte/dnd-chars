//
//  NPC.swift
//  CharCount
//
//  Created by Elliot Schrock on 4/13/24.
//

import Foundation
import ComposableArchitecture

let archer = NPC(name: "Archer", ac: 16, hp: 75, maxHp: 75)
@ObservableState
struct NPC: Codable, Identifiable, Equatable {
    var id = Current.uuid()
    var name: String
    var ac: Int
    var hp: Int
    var maxHp: Int
}
