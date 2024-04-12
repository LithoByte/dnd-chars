//
//  CharCountTests.swift
//  CharCountTests
//
//  Created by Elliot Schrock on 4/6/24.
//

import XCTest
@testable import CharCount
import ComposableArchitecture

final class CharCountTests: XCTestCase {
    override func setUpWithError() throws {
        Current = withDependencies({
            $0.uuid = .incrementing
        }, operation: {
            Env()
        })
    }
    
    func testBekriHitpoints() throws {
        XCTAssertEqual(try bekri.maxHitPoints(), 60)
    }
    
    func testBekriSpellLevel() throws {
        XCTAssertEqual(bekri.maxSpellLevel(), 6)
    }
    
    func testBekriSpellPoints() throws {
        XCTAssertEqual(bekri.maxSpellPoints(), 73)
    }
    
    func testRowarenHitpoints() throws {
        XCTAssertEqual(try rowaren.maxHitPoints(), 42)
    }
    
    func testRowarenSpellLevel() throws {
        XCTAssertEqual(rowaren.maxSpellLevel(), 4)
    }
    
    func testRowarenSpellPoints() throws {
        XCTAssertEqual(rowaren.maxSpellPoints(), 44)
    }
    
    func testRietaHitpoints() throws {
        XCTAssertEqual(try rieta.maxHitPoints(), 67)
    }
    
    func testRietaSpellLevel() throws {
        XCTAssertEqual(rieta.maxSpellLevel(), 2)
    }
    
    func testRietaSpellPoints() throws {
        XCTAssertEqual(rieta.maxSpellPoints(), 17)
    }
    
    func testRietaSpellSlots() throws {
        let levels = rieta.maxSpellSlots()
        XCTAssertEqual(levels.count, 2)
        XCTAssertEqual(levels[0].slots.count, 4)
        XCTAssertEqual(levels[0].level, .first)
        XCTAssertEqual(levels[1].slots.count, 5)
        XCTAssertEqual(levels[1].level, .second)
    }
}
