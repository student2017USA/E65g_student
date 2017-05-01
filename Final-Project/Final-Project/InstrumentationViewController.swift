//
//  InstrumentationViewController.swift
//  FinalProject
//
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Foundation

class IntrumentationViewController: BaseViewController {

    // IBOutlets
    @IBOutlet weak var numRowsText: UITextField!
    @IBOutlet weak var numColumnsText: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var columnStepper: UIStepper!
    @IBOutlet weak var refreshRateController: UISlider!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshSwitch.setOn(false, animated: true)
        
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", refreshRateController.value) + "Hz"
        
        rowStepper.value = Double(StandardEngine.sharedInstance.rows)
        columnStepper.value = Double(StandardEngine.sharedInstance.cols)
        
        numRowsText.text =  String(Int(StandardEngine.sharedInstance.rows))
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        numRowsText.text = String(Int(rowStepper.value))
        numColumnsText.text = String(Int(columnStepper.value))
        
        // Observer to update row and column textfields
        let sel = #selector(IntrumentationViewController.watchForNotifications(_:))
        let center = NotificationCenter.default
        center.addObserver(self, selector: sel, name: NSNotification.Name(rawValue: "ModifyRowAndColumnText"), object: nil)
        
        // Observer to make changes when switch is flipped
        let sel2 = #selector(IntrumentationViewController.makeSwitchChanges(_:))
        center.addObserver(self, selector: sel2, name: NSNotification.Name(rawValue: "MakeSwitchChanges"), object: nil)
        
        // Observer to turn off switch
        let sel3 = #selector(IntrumentationViewController.turnOffSwitch(_:))
        center.addObserver(self, selector: sel3, name: NSNotification.Name(rawValue: "TurnOffSwitch"), object: nil)


        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
    }
    
    // IBActions
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        StandardEngine.sharedInstance.refreshInterval = TimeInterval(sender.value)
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", sender.value) + "Hz"
        StandardEngine.sharedInstance.refreshRate = sender.value
        refreshSwitch.setOn(true, animated: true)
        StandardEngine.sharedInstance.isPaused = false
    }
    
    @IBAction func modifyRows(_ sender: UIStepper) {
        StandardEngine.sharedInstance.rows = Int(sender.value)
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateEmbeddedGrid"), object: nil, userInfo: nil)
    }
    
    @IBAction func modifyColumns(_ sender: UIStepper) {
        StandardEngine.sharedInstance.cols = Int(sender.value)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateEmbeddedGrid"), object: nil, userInfo: nil)
    }
    
    @IBAction func refreshRateSwitch(_ sender: UISwitch) {
        playAudio()
        if sender.isOn {
            StandardEngine.sharedInstance.refreshInterval = TimeInterval(refreshRateController.value)
            StandardEngine.sharedInstance.refreshRate = refreshRateController.value
            StandardEngine.sharedInstance.isPaused = false
        }
        else {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            StandardEngine.sharedInstance.isPaused = true
        }
    }
    
    @IBAction func reloadClicked(_ sender: UIButton) {
        
        // Parse the JSON file and update TV
        ConfigurationViewController.sharedTable.designNames = []
        ConfigurationViewController.sharedTable.gridContentCoordinates = []
        
        // Handles invalid URL
        if let url = urlField.text {
            guard let requestURL: URL = URL(string: url) else {
                let alertController = UIAlertController(title: "URL Alert", message:
                    "Please enter a valid url.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
            //let config = URLSessionConfiguration.default
            let session = URLSession.shared
            //URLSession(configuration: config, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
            
            //let task = session.
            
            let task = session.dataTask(with: requestURL, completionHandler: {
                data, response, error  in
                let httpResponse = response as? HTTPURLResponse
                let statusCode = httpResponse?.statusCode
                if let safeStatusCode = statusCode {
                    if (safeStatusCode == 200) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [AnyObject]
                            for i in 0...json!.count - 1 {
                                let pattern = json![i]
                                let collection = pattern as! Dictionary<String, AnyObject>
                                ConfigurationViewController.sharedTable.designNames.append(collection["title"]! as! String)
                                let arr = collection["contents"].map{return $0 as! [[Int]]}
                                ConfigurationViewController.sharedTable.gridContentCoordinates.append(arr!)
                            }
                            ConfigurationViewController.sharedTable.comments = ConfigurationViewController.sharedTable.designNames.map{ _ in return "" }
                        } catch {
                            print("Error with JSON: \(error)")
                            ConfigurationViewController.sharedTable.designNames = []
                            ConfigurationViewController.sharedTable.gridContentCoordinates = []
                            ConfigurationViewController.sharedTable.comments = []
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "TableViewReloadData"), object: nil, userInfo: nil)
                        }
                        
                        // Shift to main thread
                        let op = BlockOperation {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "TableViewReloadData"), object: nil, userInfo: nil)
                        }
                        OperationQueue.main.addOperation(op)
                        
                    } else {
                        // Handles HTTP errors
                        let op = BlockOperation {
                            let alertController = UIAlertController(title: "Error", message:
                                "HTTP Error \(safeStatusCode): \(HTTPURLResponse.localizedString(forStatusCode: safeStatusCode))           Please enter a valid url", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            ConfigurationViewController.sharedTable.designNames = []
                            ConfigurationViewController.sharedTable.gridContentCoordinates = []
                            ConfigurationViewController.sharedTable.comments = []
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "TableViewReloadData"), object: nil, userInfo: nil)
                        }
                        OperationQueue.main.addOperation(op)
                    }
                } else {
                    //put the pop up window in the main thread for url errors and then pop it up
                    let op = BlockOperation {
                        let alertController = UIAlertController(title: "Error", message:
                            "Please check your url or your Internet connection", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        //clear the embed table view so that the app will not crash
                        ConfigurationViewController.sharedTable.designNames = []
                        ConfigurationViewController.sharedTable.gridContentCoordinates = []
                        ConfigurationViewController.sharedTable.comments = []
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "TableViewReloadData"), object: nil, userInfo: nil)
                    }
                    OperationQueue.main.addOperation(op)
                }
            })
            task.resume()
        }
    }
    
    @IBAction func rowEnter(_ sender: UITextField) {
        if let changeToRow = Int(sender.text!){
            if changeToRow > 0 {
                StandardEngine.sharedInstance.rows = changeToRow
                rowStepper.value = Double(changeToRow)
            }
            else {
                // Handles case when rows entered is less than or equal to 0
                let alertControllerRow = UIAlertController(title: "Row Error", message:
                    "Number of rows cannot be less than 1", preferredStyle: UIAlertControllerStyle.alert)
                alertControllerRow.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(alert: UIAlertAction!) in
                    self.numRowsText.text = String(StandardEngine.sharedInstance.rows)
                }))
                
                self.present(alertControllerRow, animated: true, completion: nil)
            }
        } else {
            // Handles case when rows entered is not a whole number
            let alertControllerRow = UIAlertController(title: "Row Error", message:
                "Number of rows can only be Whole Numbers", preferredStyle: UIAlertControllerStyle.alert)
            alertControllerRow.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(alert: UIAlertAction!) in
                self.numRowsText.text = String(StandardEngine.sharedInstance.rows)
            }))
            
            self.present(alertControllerRow, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func colEnter(_ sender: UITextField) {
        if let changeToCol = Int(sender.text!){
            if changeToCol > 0 {
                StandardEngine.sharedInstance.cols = changeToCol
                columnStepper.value = Double(changeToCol)
            }
            else {
                // Handles case when columns entered is less than or equal to 0
                let alertControllerCol = UIAlertController(title: "Column Error", message:
                    "Number of columns cannot be less than 1", preferredStyle: UIAlertControllerStyle.alert)
                alertControllerCol.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(alert: UIAlertAction!) in
                    self.numColumnsText.text = String(StandardEngine.sharedInstance.cols)
                }))
                
                self.present(alertControllerCol, animated: true, completion: nil)
            }
        }else {
            // Handles case when rows entered is not a whole number
            let alertControllerCol = UIAlertController(title: "Column Error", message:
                "Number of columns can only be Whole Numbers", preferredStyle: UIAlertControllerStyle.alert)
            alertControllerCol.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(alert: UIAlertAction!) in
                self.numColumnsText.text = String(StandardEngine.sharedInstance.cols)
            }))
            
            self.present(alertControllerCol, animated: true, completion: nil)
        }
    }
    
    func watchForNotifications(_ notification:Notification){
        rowStepper.value = Double(StandardEngine.sharedInstance.rows)
        columnStepper.value = Double(StandardEngine.sharedInstance.cols)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
    }
    
    func makeSwitchChanges(_ notification:Notification){
        if refreshSwitch.isOn{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            refreshSwitch.setOn(false, animated: true)
            StandardEngine.sharedInstance.isPaused = true
        }
        else{
            refreshSwitch.setOn(true, animated: true)
            StandardEngine.sharedInstance.isPaused = false
        }
    }
    
    func turnOffSwitch(_ notification:Notification){
        if refreshSwitch.isOn{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            refreshSwitch.setOn(false, animated: true)
            StandardEngine.sharedInstance.isPaused = true
        }
    }
    
    // Hides keyboard when touched outside the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}

