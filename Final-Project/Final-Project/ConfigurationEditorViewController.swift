//
//  ConfigurationEditorViewController.swift
//  FinalProject
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit

class ConfigurationEditorViewController: UIViewController {

    // Set up variables
    var name:String?
    var comment:String?
    var commit: ((String) -> Void)?
    var anotherCommit: (([[Int]]) -> Void)?
    var commitForComment: ((String) -> Void)?
    var savedCells: [[Int]] = []

    // IBOutlets
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var gridEditor: GridView!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = name
        commentField.text = comment
        
        // Observer to update embedded grid
        let sel = #selector(ConfigurationEditorViewController.watchForNotifications(_:))
        let center = NotificationCenter.default
        center.addObserver(self, selector: sel, name: NSNotification.Name(rawValue: "UpdateEmbeddedGrid"), object: nil)
    }
    
    // IBActions
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        
        if StandardEngine.sharedInstance.checkChanges {
            
            let alert = UIAlertController(title: "Changes not Saved", message: "Are you sure you want to quit without saving?", preferredStyle: UIAlertControllerStyle.alert)
            //add cancel button action
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: {(action) -> Void in self.navigationController!.popViewController(animated: true)}))
            
            let op = BlockOperation {
                self.present(alert, animated: true, completion: nil)
            }
            OperationQueue.main.addOperation(op)
        } else {
            navigationController!.popViewController(animated: true)
        }
        StandardEngine.sharedInstance.checkChanges = false
    }
    
    
    @IBAction func commentFieldClicked(_ sender: UITextField) {
        StandardEngine.sharedInstance.checkChanges = true
    }

    @IBAction func saveClicked(_ sender: UIBarButtonItem) {
        let filteredArray = StandardEngine.sharedInstance.grid.cells.filter{$0.state.isLiving()}.map{return $0.position}
        
        for cell in filteredArray {
            savedCells.append([cell.row, cell.col])
        }
        
        guard let newText = nameField.text, let commit = commit
            else { return }
        commit(newText)
        
        guard let anothercommit = anotherCommit
            else { return }
        anothercommit(savedCells)
        navigationController!.popViewController(animated: true)
        
        guard let comment = commentField.text, let commitForComment = commitForComment
            else { return }
        commitForComment(comment)
    }
    
    func watchForNotifications(_ notification:Notification){
        gridEditor.setNeedsDisplay()
    }
    
    // Hides keyboard when touched anywhere else on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
