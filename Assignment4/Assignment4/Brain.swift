//
//  EngineDelegate.swift
//  assignment4
//
//  Created by Anela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

protocol EngineDelegateProtocol {
    func engineDidUpdate(_ withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegateProtocol? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    init(rows: Int, cols: Int)
    func step() -> GridProtocol
}

extension EngineProtocol {
    var refreshRate: Double {
        return 0.0
    }
}

class StandardEngine: EngineProtocol {
    
    fileprivate static var _sharedInstance = StandardEngine(rows: 10, cols: 10)
    
    static var sharedInstance: StandardEngine {
        get {
            return _sharedInstance
        }
    }
    
    var delegate: EngineDelegateProtocol?
    var grid: GridProtocol
    
    // In class, we discussed that we won't cover default values in protocols therefore the value of refreshRate is specified here.
    var refreshRate: Double = 0.0
    var refreshTimer: Timer?
    
    var refreshInterval: TimeInterval = 0 {
        didSet {
            if refreshInterval != 0 {
                if let timer = refreshTimer { timer.invalidate() }
                let sel = #selector(StandardEngine.timerDidFire(_:))
                refreshTimer = Timer.scheduledTimer(timeInterval: refreshInterval,
                                                               target: self,
                                                               selector: sel,
                                                               userInfo: nil,
                                                               repeats: true)
            }
            else if let timer = refreshTimer {
                timer.invalidate()
                self.refreshTimer = nil
            }
        }
    }

    
    var rows: Int {
        didSet {
            if let delegate = delegate {
                delegate.engineDidUpdate(grid)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        }
    }
    var cols: Int {
        didSet {
            if let delegate = delegate {
                delegate.engineDidUpdate(grid)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        }
    }
    
    required init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        grid = Grid(rows: rows, cols: cols)
    }
    
    
    // Calculates and returns the 'after' grid/matrix
    func step() -> GridProtocol {
        
        // Defining and initialising the 'after' cell grid
        let after: GridProtocol = Grid(rows: rows, cols: cols)
        
        // Stores the states of the cells in the next step in the 'after' matrix/grid
        for row in 0..<rows {
            for column in 0..<cols {
                let numberOfNeighboursAlive = countNeighboursAlive(row, col: column)
                
                switch numberOfNeighboursAlive {
                // Cell state unchanged i.e Alive -> Alive, Dead -> Dead
                case 2:
                    switch grid[row, column]! {
                    case .Born, .Living: after[row, column] = .Living
                    case .Died, .Empty: after[row, column] = .Empty
                    }
                // Cell reproduction i.e Alive -> Alive, Dead -> Alive
                case 3:
                    switch grid[row, column]! {
                    case .Born, .Living: after[row, column] = .Living
                    case .Died, .Empty: after[row, column] = .Born
                    }
                // Cell death: overcrowding/undercrowding i.e Alive -> Dead, Dead -> Dead
                default:
                    switch grid[row, column]! {
                    case .Born, .Living: after[row, column] = .Died
                    case .Died, .Empty: after[row, column] = .Empty
                    }
                }
            }
        }
    
        if let delegate = delegate {
            delegate.engineDidUpdate(grid)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        
        return after
    }
    
    // Counts number of alive neighbours for a given cell
    func countNeighboursAlive(_ row: Int, col: Int) -> Int {
        let cellNeighbours = grid.neighbours(row, col: col)
        var numberOfNeigboursAlive = 0
        for cell in cellNeighbours {
            let neighbourRow = cell.0
            let neighbourColumn = cell.1
            // Add count if neighbouring cell is alive
            if grid[neighbourRow, neighbourColumn] == .Born || grid[neighbourRow, neighbourColumn] == .Living {
                numberOfNeigboursAlive += 1
            }
        }
        return numberOfNeigboursAlive
    }
        
    @objc func timerDidFire(_ timer:Timer) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
    }
    
}
