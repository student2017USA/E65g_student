//
//  Brain.swift
//  Assignment3
//
//  Created by Angela Baruth on 17/03/17.
//  Copyright © 2017 Harvard Spring. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // IBOutlet
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // IBAction: Updates the grid to the next step
    @IBAction func nextStep(_ sender: AnyObject) {
        let step = Step()
        gridView.grid = step.step2(gridView.grid, rowSize: gridView.rows, columnSize: gridView.cols)
        gridView.setNeedsDisplay()
    }

}

