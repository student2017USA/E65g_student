//
//  ConfigurationViewController.swift
//  FinalProject
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit

class ConfigurationViewController: UITableViewController {

    var designNames: [String] = ["Glider"]
    var gridContentCoordinates: [[[Int]]] = [[[8, 11], [9, 9], [9, 11], [10, 10], [10, 11]]]
    var comments: [String] = ["Standard (infinite) glider"]
    
    static var _sharedTable = ConfigurationViewController()
    static var sharedTable: ConfigurationViewController { get { return _sharedTable } }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observer to reload table data
        let sel = #selector(ConfigurationViewController.reloadTableView(_:))
        let center = NotificationCenter.default
        center.addObserver(self, selector: sel, name: NSNotification.Name(rawValue: "TableViewReloadData"), object: nil)
    }
    
    @IBAction func addEntry(_ sender: UIBarButtonItem) {
        ConfigurationViewController.sharedTable.designNames.append("New Name")
        ConfigurationViewController.sharedTable.gridContentCoordinates.append([])
        ConfigurationViewController.sharedTable.comments.append("")
        let rowItem = ConfigurationViewController.sharedTable.designNames.count - 1
        let itemPath = IndexPath(row:rowItem, section: 0)
        self.tableView.insertRows(at: [itemPath], with: .automatic)
        self.tableView.reloadData()
    }
    
    func reloadTableView(_ notification:Notification) {
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigurationViewController.sharedTable.designNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Default")
            else {
                preconditionFailure("missing Default reuse identifier")
        }
        let row = indexPath.row
        guard let nameLabel = cell.textLabel else {
            preconditionFailure("Something is wrong.")
        }
        nameLabel.text = ConfigurationViewController.sharedTable.designNames[row]
        cell.tag = row
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                                               forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ConfigurationViewController.sharedTable.designNames.remove(at: indexPath.row)
            ConfigurationViewController.sharedTable.gridContentCoordinates.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        StandardEngine.sharedInstance.checkChanges = false
        let editingRow = (sender as! UITableViewCell).tag
        let editingString = ConfigurationViewController.sharedTable.designNames[editingRow]
        let editingComment = ConfigurationViewController.sharedTable.comments[editingRow]
        guard let editingVC = segue.destination as? ConfigurationEditorViewController
            else {
                preconditionFailure("Something went wrong")
        }
        editingVC.name = editingString
        editingVC.comment = editingComment
        editingVC.commit = {
            ConfigurationViewController.sharedTable.designNames[editingRow] = $0
            let indexPath = IndexPath(row: editingRow, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        editingVC.anotherCommit = {
            ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow] = $0
        }
        editingVC.commitForComment = {
            ConfigurationViewController.sharedTable.comments[editingRow] = $0
        }
        
        // Set size of grid according to coordinates of pattern
        let size = ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow].flatMap{$0}.max()
        if let finalSize = size {
            StandardEngine.sharedInstance.rows = (finalSize % 10 != 0) ? (finalSize / 10 + 1) * 10 : finalSize
            StandardEngine.sharedInstance.cols = (finalSize % 10 != 0) ? (finalSize / 10 + 1) * 10 : finalSize
        }
        
        let set: [(Int, Int)] = ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow].map { return ($0[0], $0[1]) }
        GridView().points = set
        
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        // Post required notifications
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ModifyRowAndColumnText"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TurnOffSwitch"), object: nil, userInfo: nil)
        
    }
}
