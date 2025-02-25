//
//  GameTests.swift
//  CharCountTests
//
//  Created by Elliot Schrock on 4/27/24.
//

import XCTest
import ComposableArchitecture
@testable import CharCount

@MainActor
final class GameTests: XCTestCase {
    override func setUpWithError() throws {
        Current = withDependencies({
            $0.uuid = .incrementing
        }, operation: {
            Env()
        })
    }
    
    func testReorder() async throws {
        let bekriCard = CardReducer.State(character: bekri)
        let rietaCard = CardReducer.State(character: rieta)
        let nocielCard = CardReducer.State(character: nociel)
        let jollianCard = CardReducer.State(character: jollian)
        let narakCard = CardReducer.State(character: narak)
        let rowarenCard = CardReducer.State(character: rowaren)
        let state = GameReducer.State(
            game: Game(name: "Greywall"),
            allCreatures: IdentifiedArray(uniqueElements: [bekriCard, rietaCard, nocielCard, jollianCard, narakCard, rowarenCard])
        )
        let store = TestStore(initialState: state, reducer: { GameReducer() })
        
        await store.send(.move(IndexSet([0]), 4)) {
            $0.allCreatures = IdentifiedArray(uniqueElements: [rietaCard, nocielCard, jollianCard, bekriCard, narakCard, rowarenCard])
        }
    }
}























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































