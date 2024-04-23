//
//  Model.swift
//  Template
//
//  Created by Elliot Schrock on 3/23/24.
//

import Foundation
import ComposableArchitecture

@ObservableState
struct Game: Codable, Equatable, Identifiable, Hashable {
    var id: UUID? = Current.uuid()
    var name: String
    var isCreator = false
    var playerCount = 0
}
