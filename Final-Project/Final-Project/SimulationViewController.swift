//
//  SimulationViewController.swift
//  FinalProject
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit

class SimulationViewController: BaseViewController, EngineDelegate {

    fileprivate var inputTextField: UITextField?
    weak var AddAlertSaveAction: UIAlertAction?
    
    // IBOutlets
    @IBOutlet weak var pauseContinue: UIButton!
    @IBOutlet weak var grid: GridView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pauseContinue.isEnabled = StandardEngine.sharedInstance.isPaused
    }
    
    func engineDidUpdate(_ withGrid: GridProtocol) {
        grid.setNeedsDisplay()
    }
    
    // IBActions
    @IBAction func pauseContinueClicked(_ sender: UIButton) {
        
        playAudio()
        StandardEngine.sharedInstance.isPaused = !StandardEngine.sharedInstance.isPaused
        if StandardEngine.sharedInstance.isPaused {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            pauseContinue.isEnabled = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MakeSwitchChanges"), object: nil, userInfo: nil)
        } else {
            StandardEngine.sharedInstance.refreshInterval = TimeInterval(StandardEngine.sharedInstance.refreshRate)
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
            pauseContinue.isEnabled = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MakeSwitchChanges"), object: nil, userInfo: nil)
        }
    }
    
    @IBAction func saveClicked(_ sender: UIBarButtonItem) {
        
        StandardEngine.sharedInstance.refreshTimer?.invalidate()
        let alert = UIAlertController(title: "Save Preferences", message: "Please enter name to save grid", preferredStyle: UIAlertControllerStyle.alert)
        
        // Function to remove the observer
        func removeTextFieldObserver() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alert.textFields![0])
        }
        
        // Handles Cancel - close without saving
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {(action) -> Void in
            removeTextFieldObserver()
            if !StandardEngine.sharedInstance.isPaused {
                StandardEngine.sharedInstance.refreshInterval = TimeInterval(StandardEngine.sharedInstance.refreshRate)
            }
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
        }))
        
        let saveAction = UIAlertAction(title: "Save", style: .destructive, handler: {(action) -> Void in
            if let text = self.inputTextField!.text {
                ConfigurationViewController.sharedTable.designNames.append(text)
                ConfigurationViewController.sharedTable.comments.append("")
                
                if let point = GridView().points {
                    var medium:[[Int]] = []
                    _ = point.map { medium.append([$0.0, $0.1]) }
                    ConfigurationViewController.sharedTable.gridContentCoordinates.append(medium)
                }
                
                let rowItem = ConfigurationViewController.sharedTable.designNames.count - 1
                let itemPath = IndexPath(row:rowItem, section: 0)
                ConfigurationViewController().tableView.insertRows(at: [itemPath], with: .automatic)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "TableViewReloadData"), object: nil, userInfo: nil)
            }
            removeTextFieldObserver()
            if !StandardEngine.sharedInstance.isPaused {
                StandardEngine.sharedInstance.refreshInterval = TimeInterval(StandardEngine.sharedInstance.refreshRate)
            }
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
        })
        
        // Disables Save button unless name is entered
        saveAction.isEnabled = false
        AddAlertSaveAction = saveAction
        alert.addAction(saveAction)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter the name:"
            self.inputTextField = textField
            let sel = #selector(self.nameChange(_:))
            NotificationCenter.default.addObserver(self, selector: sel, name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
        })
    
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func resetClicked(_ sender: UIBarButtonItem) {
    
        playAudio()
        let rows = StandardEngine.sharedInstance.grid.rows
        let cols = StandardEngine.sharedInstance.grid.cols
        StandardEngine.sharedInstance.grid = Grid(rows, cols, cellInitializer: {_ in .Empty})
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        
    }
    
    @IBAction func stepClicked(_ sender: UIButton) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
        playAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
    }
    
    
    // Function that handles save button
    func nameChange(_ notification: Notification) {
        let textField = notification.object as! UITextField
        if let text = textField.text{
            AddAlertSaveAction!.isEnabled = text.characters.count >= 1
        }
    }
    
    
}

