//
//  Brain.swift
//  Assignment3
//
//  Created by Angela Baruth on 17/03/17.
//  Copyright © 2017 Harvard Spring. All rights reserved.
//

import UIKit
import Foundation

// Defining the 4 possibles states of a cell
enum CellState: String {
    case Living = "Living"
    case Empty = "Empty"
    case Born = "Born"
    case Died = "Died"
    
    // Function that returns the raw value of the state of the cell. Note: It doesn't need the Switch statement
    func description() -> String {
        return self.rawValue
    }
    
    // Function that returns array of all possibles cell states
    static func allValues() -> [CellState] {
        return [.Living, .Empty, .Born, .Died]
    }
    
    // Function that returns the appropriate cell state when a cell is clicked
    static func toggle(_ value: CellState) -> CellState {
        switch value {
        case .Empty, .Died:
            return .Living
        case .Living, .Born:
            return .Empty
        }
    }
}

@IBDesignable class GridView: UIView {
    
    // IBInpectable Properties
    @IBInspectable var rows: Int = 20 {
        // Reinitialises "grid" to .Empty
        didSet {
            var copyArray: [[CellState]] = []
            for row in 0..<rows {
                copyArray.append([])
                for _ in 0..<cols {
                    copyArray[row].append(.Empty)
                }
            }
            grid = copyArray
        }
    }
    @IBInspectable var cols: Int = 20 {
        // Reinitialises "grid" to .Empty
        didSet {
            var copyArray: [[CellState]] = []
            for row in 0..<rows {
                copyArray.append([])
                for _ in 0..<cols {
                    copyArray[row].append(.Empty)
                }
            }
            grid = copyArray
        }
    }
    @IBInspectable var livingColor: UIColor = UIColor.green
    @IBInspectable var emptyColor: UIColor = UIColor.darkGray
    @IBInspectable var bornColor: UIColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.6)
    @IBInspectable var diedColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
    @IBInspectable var gridColor: UIColor = UIColor.black
    @IBInspectable var gridWidth: CGFloat = 2.0
    
    // Matrix holding the states of all the cells
    var grid = [[CellState]]()
    
    // Function that displays the grid with the cells in it on the screen
    override func draw(_ rect: CGRect) {
        
        // Create the path
        let gridPath = UIBezierPath()
        
        // Set the path's line width
        gridPath.lineWidth = gridWidth
        
        // The respective x and y coordinates of horizontal line to be drawn
        let rowX = bounds.origin.x
        var rowY = bounds.origin.y
        
        // Distance between 2 rows
        let rowDist = bounds.height / CGFloat(rows)
        
        for _ in 0...rows {
            
            // Draws horizontal line
            gridPath.move(to: CGPoint(x: rowX, y: rowY))
            gridPath.addLine(to: CGPoint(x: rowX + bounds.width, y: rowY))
            rowY += rowDist
        }
        
        // The respective x and y coordinates of vertical line to be drawn
        var colX = bounds.origin.x
        let colY = bounds.origin.y
        
        // Distance between 2 columns
        let colDist = bounds.width / CGFloat(cols)
        
        for _ in 0...cols {
            
            // Draws vertical line
            gridPath.move(to: CGPoint(x: colX, y: colY))
            gridPath.addLine(to: CGPoint(x: colX, y: colY + bounds.height))
            colX += colDist
        }
        
        // Set the stroke color
        gridColor.setStroke()
        
        // Draw the stroke
        gridPath.stroke()
        
        // Fill each cell with the color corresponding to its cell state
        for row in 0..<rows {
            for col in 0..<cols {
                // Note: Size measurements include 'gridWidth' to make the cells look more attractive
                let rectangle = CGRect(x: CGFloat(col) * colDist + gridWidth / 2, y: CGFloat(row) * rowDist + gridWidth / 2, width: colDist - gridWidth, height: rowDist - gridWidth)
                let path = UIBezierPath(ovalIn: rectangle)
                switch grid[row][col] {
                case .Living:
                    livingColor.setFill()
                case .Born:
                    bornColor.setFill()
                case .Empty:
                    emptyColor.setFill()
                case .Died:
                    diedColor.setFill()
                }
                path.fill()
            }
        }
    }
    
    
    // Handles the clicking of the cells
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.makeTouch(touch)
        }
    }
    
    func makeTouch(_ touch: UITouch) {
        
        // Determines coordinates of the touch location
        let point = touch.location(in: self)
        
        // Finds the width and height of a cell
        let cellHeight = (bounds.height) / CGFloat(rows)
        let cellWidth = (bounds.width) / CGFloat(cols)
        
        // Finds the corresponding row and column indices
        let cellX = Int(CGFloat(point.x) / cellWidth)
        let cellY = Int(CGFloat(point.y) / cellHeight)
        
        // 
        if cellX < cols && cellY < rows && cellX >= 0 && cellY >= 0 {
            grid[cellY][cellX] = CellState.toggle(grid[cellY][cellX])
        }
        
        // Updates the grid
        let updatedGrid = CGRect(x: CGFloat(cellX) * cellWidth + gridWidth / 2, y: CGFloat(cellY) * cellHeight + gridWidth / 2, width: cellWidth - gridWidth, height: cellHeight - gridWidth)
        self.setNeedsDisplay(updatedGrid)

    }
}
