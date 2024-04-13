//
//  CharacterListTests.swift
//  CharCountTests
//
//  Created by Elliot Schrock on 4/12/24.
//

import XCTest
import ComposableArchitecture
@testable import CharCount

@MainActor
final class CharacterListTests: XCTestCase {
    override func setUpWithError() throws {
        Current = withDependencies({
            $0.uuid = .incrementing
        }, operation: {
            Env()
        })
    }
    
    func testIncrement() async throws {
        bekri.hpSources = [PointSource(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, title: "Hit Points", currentPoints: 31, maxPoints: 60, pointsType: .innate)]
        let state = CharacterListReducer.State(
            allCharacters: IdentifiedArray(uniqueElements: [bekri]),
            characterToItemState: { $0 }
        )
        let store = TestStore(initialState: state, reducer: { CharacterListReducer() })
        
        await store.withExhaustivity(.off(showSkippedAssertions: true)) {
            await store.send(.character(bekri.id, .delegate(.didTap(bekri))))
        }
        var source = store.state.details?.hpState.sources.first
        source?.currentPoints -= 1
        XCTAssertNotNil(source)
        await store.send(.details(.presented(.hpTab(.source(source!.id, .adjustPoints(-1)))))) {
            $0.details?.hpState.sources[id: source!.id]?.currentPoints -= 1
        }
        await store.receive(.details(.presented(.delegate(.saveHitPoints(bekri.id, [source!]))))) {
            $0.allCharacters[id: bekri.id]?.hpSources = [source!]
        }
    }

}


































