//
//  GridView.swift
//  assignment4
//
//  Created by Anela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Foundation

class GridView: UIView {

    // IBInspectables are not imperative in Assignent 4
    var livingColor: UIColor = UIColor.init(red: 27, green: 205, blue: 74, alpha: 1)
    var emptyColor: UIColor = UIColor.init(red: 85, green: 85, blue: 95, alpha: 1)
    var bornColor: UIColor = UIColor.init(red: 27, green: 205, blue: 74, alpha: 0.6)
    var diedColor: UIColor = UIColor.init(red: 85, green: 86, blue: 85, alpha: 0.6)
    var gridColor: UIColor = UIColor.init(red: 38, green: 38, blue: 38, alpha: 1)
    var gridWidth: CGFloat = 2.0
    
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
        let rowDist = bounds.height / CGFloat(StandardEngine.sharedInstance.rows)
        
        for _ in 0...StandardEngine.sharedInstance.rows {
            
            // Draws horizontal line
            gridPath.move(to: CGPoint(x: rowX, y: rowY))
            gridPath.addLine(to: CGPoint(x: rowX + bounds.width, y: rowY))
            rowY += rowDist
        }
        
        // The respective x and y coordinates of vertical line to be drawn
        var colX = bounds.origin.x
        let colY = bounds.origin.y
        
        // Distance between 2 columns
        let colDist = bounds.width / CGFloat(StandardEngine.sharedInstance.cols)
        
        for _ in 0...StandardEngine.sharedInstance.cols {
            
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
        for row in 0..<StandardEngine.sharedInstance.rows {
            for col in 0..<StandardEngine.sharedInstance.cols {
                // Note: Size measurements include 'gridWidth' to make the cells look more attractive
                let rectangle = CGRect(x: CGFloat(col) * colDist + gridWidth / 2, y: CGFloat(row) * rowDist + gridWidth / 2, width: colDist - gridWidth, height: rowDist - gridWidth)
                let path = UIBezierPath(ovalIn: rectangle)
                switch StandardEngine.sharedInstance.grid[row, col] {
                case .Living?:
                    livingColor.setFill()
                case .Born?:
                    bornColor.setFill()
                case .Died?:
                    diedColor.setFill()
                default:
                    emptyColor.setFill()
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.makeTouch(touch)
            
        }
    }
    
    func makeTouch(_ touch: UITouch) {
        
        // Determines coordinates of the touch location
        let point = touch.location(in: self)
        
        // Finds the width and height of a cell
        let cellHeight = (bounds.height) / CGFloat(StandardEngine.sharedInstance.rows)
        let cellWidth = (bounds.width) / CGFloat(StandardEngine.sharedInstance.cols)
        
        // Finds the corresponding row and column indices
        let cellX = Int(CGFloat(point.x) / cellWidth)
        let cellY = Int(CGFloat(point.y) / cellHeight)
        
        //
        if cellX < StandardEngine.sharedInstance.cols && cellY < StandardEngine.sharedInstance.rows && cellX >= 0 && cellY >= 0 {
            StandardEngine.sharedInstance.grid[cellY, cellX] = CellState.toggle(StandardEngine.sharedInstance.grid[cellY, cellX]!)
        }
        
        // Updates the grid
        let updatedGrid = CGRect(x: CGFloat(cellX) * cellWidth + gridWidth / 2, y: CGFloat(cellY) * cellHeight + gridWidth / 2, width: cellWidth - gridWidth, height: cellHeight - gridWidth)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        
        self.setNeedsDisplay(updatedGrid)
        
    }
    
}
