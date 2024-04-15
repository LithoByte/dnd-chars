//
//  CharacterListReducer.swift
//  Template
//
//  Created by Elliot Schrock on 2/26/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CharacterListReducer {
    
    @ObservableState
    struct State: Equatable {
        var allCharacters: IdentifiedArrayOf<Character>
        var displayedCharacterStates: IdentifiedArrayOf<CharacterItemReducer.State> {
            var displayedCharacters = allCharacters
            if let searchableStringFrom = characterToSearchableString {
                if !localFilter.isEmpty {
                    displayedCharacters = allCharacters.filter({ character in
                        return matchesWordsPrefixes(localFilter, searchableStringFrom(character))
                    })
                }
            }
            return IdentifiedArray(uniqueElements: displayedCharacters.map { characterToItemState($0) })
        }
        var localFilter = ""
        @Presents var new: EditCharacterReducer.State?
        @Presents var edit: EditCharacterReducer.State?
        @Presents var details: TabsReducer.State?
        @Presents var games: GameReducer.State?
        
        var characterToItemState: (Character) -> CharacterItemReducer.State
        var characterToSearchableString: ((Character) -> String)? = { "\($0.name) \($0.levels.map { $0.classEnum.rawValue }.joined(separator: " "))" }
        
        static func == (lhs: CharacterListReducer.State, rhs: CharacterListReducer.State) -> Bool {
            return lhs.allCharacters == rhs.allCharacters
            && lhs.localFilter == rhs.localFilter
            && lhs.details == rhs.details
            && lhs.new == rhs.new
            && lhs.edit == rhs.edit
        }
        
        init(allCharacters: IdentifiedArrayOf<Character> = .init(uniqueElements: loadData()), localFilter: String = "", new: EditCharacterReducer.State? = nil, edit: EditCharacterReducer.State? = nil, details: TabsReducer.State? = nil, characterToItemState: @escaping (Character) -> CharacterItemReducer.State, characterToSearchableString: ( (Character) -> String)? = nil) {
            self.allCharacters = allCharacters
            self.localFilter = localFilter
            self.new = new
            self.edit = edit
            self.details = details
            self.characterToItemState = characterToItemState
            self.characterToSearchableString = characterToSearchableString
        }
    }
    
    enum Action: Equatable, BindableAction {
        case gamesTapped
        case addNewTapped
        case saveCharacter, cancelCharacter
        case didAppear
        case didChangeScenePhase
        case didShowCharacterIndex(Int)
        case delete(IndexSet)
        
        case binding(BindingAction<State>)
        case character(CharacterItemReducer.State.ID, CharacterItemReducer.Action)
        case new(PresentationAction<EditCharacterReducer.Action>)
        case edit(PresentationAction<EditCharacterReducer.Action>)
        case details(PresentationAction<TabsReducer.Action>)
        case games(PresentationAction<GameReducer.Action>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .gamesTapped:
                state.games = GameReducer.State(gameTitle: "Elliot's Game", allCreatures: IdentifiedArray(uniqueElements: creatures))
            case .games(_): break
            case .addNewTapped:
                state.new = EditCharacterReducer.State(name: "")
            case .saveCharacter:
                if let new = state.new {
                    let levels = [new.firstSetOfLevels, new.secondSetOfLevels, new.thirdSetOfLevels, new.fourthSetOfLevels].compactMap({ $0 })
                    var newChar = Character(name: new.name,
                                            armorClass: Int(new.ac)!,
                                            levels: levels,
                                            abilityScores: [AbilityScore(ability: .CON, score: Int(new.conScore)!)],
                                            usesSpellPoints: new.usesSpellPoints,
                                            skillProficiencies: new.hasPerProficiency ? [.perception] : [],
                                            isTough: new.isTough,
                                            isObservant: new.isObservant)
                    if let con = Int(new.conScore), let int = Int(new.intScore), let wis = Int(new.wisScore), let cha = Int(new.chaScore) {
                        newChar.abilityScores = [AbilityScore(ability: .CON, score: con), AbilityScore(ability: .INT, score: int), AbilityScore(ability: .WIS, score: wis), AbilityScore(ability: .CHA, score: cha)]
                    } else if let con = Int(new.conScore) {
                        newChar.abilityScores = [AbilityScore(ability: .CON, score: con)]
                    }
                    newChar.levelUpResources()
                    state.allCharacters.append(newChar)
                }
                if let edit = state.edit {
                    if let oldChar = state.allCharacters[id: edit.id!] {
                        let levels = [edit.firstSetOfLevels, edit.secondSetOfLevels, edit.thirdSetOfLevels, edit.fourthSetOfLevels].compactMap({ $0 })
                        var newChar = oldChar
                        newChar.name = edit.name
                        newChar.armorClass = Int(edit.ac)!
                        newChar.levels = levels
                        if let con = Int(edit.conScore), let int = Int(edit.intScore), let wis = Int(edit.wisScore), let cha = Int(edit.chaScore) {
                            newChar.abilityScores = [AbilityScore(ability: .CON, score: con), AbilityScore(ability: .INT, score: int), AbilityScore(ability: .WIS, score: wis), AbilityScore(ability: .CHA, score: cha)]
                        } else if let con = Int(edit.conScore) {
                            newChar.abilityScores = [AbilityScore(ability: .CON, score: con)]
                        }
                        newChar.usesSpellPoints = edit.usesSpellPoints
                        newChar.levelUpResources()
                        newChar.skillProficiencies = edit.hasPerProficiency ? [.perception] : []
                        newChar.isObservant = edit.isObservant
                        newChar.isTough = edit.isTough
                        state.allCharacters[id: newChar.id] = newChar
                        state.edit = nil
                    }
                }
                state.new = nil
            case .cancelCharacter:
                state.new = nil
                state.edit = nil
            case .didAppear: break
            case .didChangeScenePhase:
                saveUnique(state.allCharacters.elements)
            case .didShowCharacterIndex(_): break
            case .character(_, .delegate(.didTap(let character))):
                state.details = TabsReducer.State(&state.allCharacters[id: character.id]!)
            case .character(_, .delegate(.edit(let character))):
                state.edit = state.allCharacters[id: character.id]!.toEditState()
            case .delete(let indexSet):
                let displayed = state.displayedCharacterStates//state.sources.remove(atOffsets: indexSet)
                let deletedIds = indexSet.map { displayed[$0].id }
                state.allCharacters.removeAll {
                    deletedIds.contains($0.id)
                }
            case .character(_, _): break
            case .binding(_): break
            case .new(_): break
            case .edit(_): break
            case .details(.presented(.delegate(.saveSpellPoints(let id, let spellPoints)))):
                state.allCharacters[id: id]?.spellPoints = spellPoints
                save(state.allCharacters.elements)
            case .details(.presented(.delegate(.saveSpellSlots(let id, let slots)))):
                state.allCharacters[id: id]?.spellSlots = slots
                save(state.allCharacters.elements)
            case .details(.presented(.delegate(.saveHitPoints(let id, let hitPoints)))):
                state.allCharacters[id: id]?.hpSources = hitPoints
                save(state.allCharacters.elements)
            case .details(.presented(.delegate(.saveResources(let id, let resources)))):
                state.allCharacters[id: id]?.resources = resources
                save(state.allCharacters.elements)
            case .details(_): break
            }
            return .none
        }
        .ifLet(\.$new, action: \.new) {
            EditCharacterReducer()
        }
        .ifLet(\.$edit, action: \.edit) {
            EditCharacterReducer()
        }
        .ifLet(\.$details, action: \.details) {
            TabsReducer()
        }
        .ifLet(\.$games, action: \.games) {
            GameReducer()
        }
        .forEach(\.allCharacters, action: /CharacterListReducer.Action.character(_:_:)) {
            CharacterItemReducer()
        }
    }
}

func matchesWordsPrefixes(_ search: String, _ text: String) -> Bool {
    let textWords = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
    let searchWords = search.components(separatedBy: CharacterSet.alphanumerics.inverted)
    for word in searchWords {
        var foundMatch = false
        for textWord in textWords {
            if textWord.prefix(word.count).caseInsensitiveCompare(word) == .orderedSame {
                foundMatch = true
                break
            }
        }
        if !foundMatch {
            return false
        }
    }
    return true
}

func loadData() -> [Character] {
    if let data = UserDefaults.standard.data(forKey: "characters"),
        let phrases = try? JSONDecoder().decode([Character].self, from: data) {
        return phrases
    }
    return []
}

func saveUnique(_ characters: [Character]) {
    var data = loadData()
    data.append(contentsOf: characters)
    let characterSet = Set(data)
    let saveData = Array(characterSet)
    save(saveData)
}

func save(_ characters: [Character]) {
    try? UserDefaults.standard.set(JSONEncoder().encode(characters), forKey: "characters")
}
