//
//  GameListReducer.swift
//  Template
//
//  Created by Elliot Schrock on 4/18/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import CoreBluetooth

@Reducer
struct GameListReducer {
    
    @ObservableState
    struct State: Equatable {
        var allGames: IdentifiedArrayOf<Game> = .init()
        var displayedGameStates: IdentifiedArrayOf<GameItemReducer.State> {
            var displayedGames = allGames
            if let searchableStringFrom = gameToSearchableString {
                if !localFilter.isEmpty {
                    displayedGames = allGames.filter({ game in
                        return matchesWordsPrefixes(localFilter, searchableStringFrom(game))
                    })
                }
            }
            return IdentifiedArray(uniqueElements: displayedGames.map { gameToItemState($0) })
        }
        var localFilter = ""
        @Presents var new: EditGameReducer.State?
        @Presents var edit: EditGameReducer.State?
        @Presents var details: GameReducer.State?
        @Presents var tabs: TabsReducer.State?
        @Presents var choose: CharacterChooserReducer.State?
        var detector: GameDetectorReducer.State?
        var chosenGame: Game?
        
        var gameToItemState: (Game) -> GameItemReducer.State
        var gameToSearchableString: ((Game) -> String)?
        
        static func == (lhs: GameListReducer.State, rhs: GameListReducer.State) -> Bool {
            return lhs.allGames == rhs.allGames
            && lhs.localFilter == rhs.localFilter
            && lhs.details == rhs.details
            && lhs.new == rhs.new
            && lhs.edit == rhs.edit
        }
        
        init(allGames: IdentifiedArrayOf<Game> = .init(), localFilter: String = "", new: EditGameReducer.State? = nil, edit: EditGameReducer.State? = nil, details: GameReducer.State? = nil, gameToItemState: @escaping (Game) -> GameItemReducer.State, gameToSearchableString: ( (Game) -> String)? = nil) {
            self.allGames = allGames
            self.localFilter = localFilter
            self.new = new
            self.edit = edit
            self.details = details
            self.gameToItemState = gameToItemState
            self.gameToSearchableString = gameToSearchableString
        }
    }
    
    enum Action: BindableAction {
        case addNewTapped
        case requestBle
        case onAppear
        case onDisappear
        case didChangeScenePhase(ScenePhase)
        case cancelGame, saveGame
        
        case binding(BindingAction<State>)
        case game(GameItemReducer.State.ID, GameItemReducer.Action)
        case edit(PresentationAction<EditGameReducer.Action>)
        case details(PresentationAction<GameReducer.Action>)
        case detector(GameDetectorReducer.Action)
        case choose(PresentationAction<CharacterChooserReducer.Action>)
        case tabs(PresentationAction<TabsReducer.Action>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
//        Scope(state: \.detector, action: \.detector) { GameDetectorReducer() }
        Reduce { state, action in
            switch action {
            case .addNewTapped:
                state.new = EditGameReducer.State(game: Game(name: ""))
            case .requestBle:
                state.detector = GameDetectorReducer.State()
                return .send(.detector(.initialize))
            case .onAppear:
                if CBCentralManager.authorization == .allowedAlways || CBCentralManager.authorization == .restricted {
                    //start detecting
                    state.detector = GameDetectorReducer.State()
                    return .send(.detector(.initialize))
                }
            case .onDisappear:
                return .send(.detector(.stopDetecting))
            case .didChangeScenePhase(let scenePhase):
                if scenePhase == .active {
                    //start detecting
                    return .send(.detector(.initialize))
                } else {
                    //stop detecting
                    return .send(.detector(.stopDetecting))
                }
            case .saveGame:
                let newGame = Game(name: state.new!.game.name, isCreator: true)
                state.allGames.append(newGame)
                state.new = nil
                state.details = GameReducer.State(game: newGame, allCreatures: IdentifiedArray(uniqueElements: []))
            case .cancelGame:
                state.new = nil
            case .game(let id, .didTap):
                if let game = state.allGames[id: id] {
                    if game.isCreator {
                        state.details = GameReducer.State(game: game, allCreatures: IdentifiedArray(uniqueElements: []))
                    } else {
                        // choose your character
                        state.chosenGame = game
                        state.choose = CharacterChooserReducer.State(allCharacters: IdentifiedArray(uniqueElements: loadData()))
                    }
                }
            case .detector(.delegate(.didDetectGames(let games))):
                for game in games {
                    if state.allGames.filter({ $0.name == game.name }).count == 0 {
                        state.allGames.append(game)
                    }
                }
            case .choose(.presented(.character(let id, .didTap))):
                if var character = state.choose?.allCharacters[id: id] {
                    defer {
                        state.choose = nil
                        state.tabs = TabsReducer.State(&character)
                    }
                    return .send(.detector(.join(state.chosenGame!, character)))
                }
            case .binding(_): break
            case .edit(_): break
            case .details(_): break
            case .detector(_): break
            case .choose(_): break
            case .tabs(_): break
            }
            return .none
        }
        .ifLet(\.$new, action: \.edit) {
            EditGameReducer()
        }
        .ifLet(\.$edit, action: \.edit) {
            EditGameReducer()
        }
        .ifLet(\.$details, action: \.details) {
            GameReducer()
        }
        .ifLet(\.$choose, action: \.choose) {
            CharacterChooserReducer()
        }
        .ifLet(\.$tabs, action: \.tabs) {
            TabsReducer()
        }
        .ifLet(\.detector, action: \.detector) {
            GameDetectorReducer()
        }
        /// not necessary unless item reducer edits the games
//        .forEach(\.displayedGameStates, action: AddableListReducer.Action.game(_:_:)) {
//            GameItemReducer()
//        }
    }
}
