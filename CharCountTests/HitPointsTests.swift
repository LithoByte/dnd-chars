//
//  HitPointsTests.swift
//  CharCountTests
//
//  Created by Elliot Schrock on 4/12/24.
//

import XCTest
import ComposableArchitecture
@testable import CharCount

@MainActor
final class HitPointsTests: XCTestCase {
    override func setUpWithError() throws {
        Current = withDependencies({
            $0.uuid = .incrementing
        }, operation: {
            Env()
        })
    }
    
    func testIncrement() async throws {
        let source = PointSource(title: "HP", currentPoints: 20, maxPoints: 39, pointsType: .innate)
        let state = HitPointsReducer.State(sources: [source])
        let store = TestStore(initialState: state, reducer: { HitPointsReducer() })
        
        await store.send(.source(source.id, .adjustPoints(1))) {
            $0.sources[id: source.id]?.currentPoints += 1
        }
    }
}
