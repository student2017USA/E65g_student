//
//  InstrumentationViewController.swift
//  assignment4
//
//  Created by Anela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {

    @IBOutlet weak var numRowsText: UITextField!
    @IBOutlet weak var numColumnsText: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var columnStepper: UIStepper!
    @IBOutlet weak var refreshRateController: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numRowsText.text =  String(Int(StandardEngine.sharedInstance.rows))
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        numRowsText.text = String(Int(rowStepper.value))
        numColumnsText.text = String(Int(columnStepper.value))
        
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        StandardEngine.sharedInstance.refreshInterval = TimeInterval(refreshRateController.value)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        StandardEngine.sharedInstance.refreshInterval = TimeInterval(sender.value)
    }
    
    @IBAction func modifyRows(_ sender: UIStepper) {
        StandardEngine.sharedInstance.rows = Int(sender.value)
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
        
        // Redrawing grid with updated number of rows
        StandardEngine.sharedInstance.grid = Grid(rows: StandardEngine.sharedInstance.rows, cols: StandardEngine.sharedInstance.cols)
    }
    
    @IBAction func modifyColumns(_ sender: UIStepper) {
        StandardEngine.sharedInstance.cols = Int(sender.value)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        // Redrawing grid with updated number of columns
        StandardEngine.sharedInstance.grid = Grid(rows: StandardEngine.sharedInstance.rows, cols: StandardEngine.sharedInstance.cols)
    }
    
    @IBAction func refreshRateSwitch(_ sender: UISwitch) {
        if sender.isOn {
            StandardEngine.sharedInstance.refreshInterval = TimeInterval(refreshRateController.value)
        }
        else {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
        }
    }
}

