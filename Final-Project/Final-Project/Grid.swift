//
//  Grid.swift
//  FinalProject
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

// Defining the 4 possibles states of a cell
enum CellState: String {
    case Alive = "Alive"
    case Empty = "Empty"
    case Born = "Born"
    case Died = "Died"
    
    // Function that returns the raw value of the state of the cell. Note: It doesn't need the Switch statement
    func description() -> String {
        return self.rawValue
    }
    
    // Function that returns array of all possibles cell states
    static func allValues() -> [CellState] {
        return [.Alive, .Empty, .Born, .Died]
    }
    
    // Function that returns the appropriate cell state when a cell is clicked
    static func toggle(_ value: CellState) -> CellState {
        StandardEngine.sharedInstance.checkChanges = true
        switch value {
        case .Empty, .Died:
            return .Alive
        case .Alive, .Born:
            return .Empty
        }
    }
    
    func isLiving() -> Bool {
        switch self {
        case .Alive, .Born: return true
        case .Died, .Empty: return false
        }
    }
}

// Variables storing number of cells in different states
var numBorn: Int = 0
var numLiving: Int = 0
var numDied: Int = 0
var numEmpty: Int = 0


typealias Position = (row: Int, col: Int)

typealias Cell = (position: Position, state: CellState)

typealias CellInitializer = (Position) -> CellState

protocol GridProtocol: class {
    var rows: Int { get }
    var cols: Int { get }
    var cells: [Cell] { get set }
    
    var living: Int { get }
    var dead:   Int { get }
    var alive:  Int { get }
    var born:   Int { get }
    var died:   Int { get }
    var empty:  Int { get }

    func neighbors(_ pos: Position) -> [Position]
    func livingNeighbors(_ position: Position) -> Int
    subscript (i: Int, j: Int) -> CellState { get set }
}


class Grid: GridProtocol {
    
    fileprivate(set) var rows: Int
    fileprivate(set) var cols: Int
    var cells: [Cell]
    
    var living: Int { return cells.reduce(0) { return  $1.state.isLiving() ?  $0 + 1 : $0 } }
    var dead:   Int { return cells.reduce(0) { return !$1.state.isLiving() ?  $0 + 1 : $0 } }
    var alive:  Int { return cells.reduce(0) { return  $1.state == .Alive  ?  $0 + 1 : $0 } }
    var born:   Int { return cells.reduce(0) { return  $1.state == .Born   ?  $0 + 1 : $0 } }
    var died:   Int { return cells.reduce(0) { return  $1.state == .Died   ?  $0 + 1 : $0 } }
    var empty:  Int { return cells.reduce(0) { return  $1.state == .Empty  ?  $0 + 1 : $0 } }
    
    init(_ rows: Int, _ cols: Int, cellInitializer: CellInitializer = { _ in .Empty }) {
        self.rows = rows
        self.cols = cols
        self.cells = (0..<rows*cols).map {
            let pos = Position($0 / cols, $0 % cols)
            return Cell(pos, cellInitializer(pos))
        }
    }
    
    subscript (i: Int, j: Int) -> CellState {
        get {
            return cells[i * cols + j].state
        }
        set {
            cells[i * cols + j].state = newValue
        }
    }
    
    // Position offsets to find row and column of neighbouring cells
    fileprivate static let offsets:[Position] = [
        (-1, -1), (-1, 0), (-1, 1),
        ( 0, -1),          ( 0, 1),
        ( 1, -1), ( 1, 0), ( 1, 1)
    ]
    
    func neighbors(_ pos: Position) -> [Position] {
        return Grid.offsets.map { Position((pos.row + rows + $0.row) % rows,
            (pos.col + cols + $0.col) % cols) }
    }
    
    func livingNeighbors(_ position: Position) -> Int {
        return neighbors(position)
            .reduce(0) {
                self[$1.row, $1.col].isLiving() ? $0 + 1 : $0
        }
    }
}
