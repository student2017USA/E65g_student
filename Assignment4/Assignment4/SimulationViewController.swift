//
//  SimulationViewController.swift
//  assignment4
//
//  Created by Anela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import AVFoundation

class SimulationViewController: UIViewController, EngineDelegateProtocol {

    @IBOutlet weak var grid: GridView!
    
    var player : AVAudioPlayer?
    var timer : Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.sharedInstance.delegate = self
        
    }

    func engineDidUpdate(_ withGrid: GridProtocol) {
        grid.setNeedsDisplay()
    }
    @IBAction func stepClicked(_ sender: UIButton) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "gridModifyNotification"), object: nil, userInfo: nil)
        playAudio()
        
    }
    
    func playAudio() {
        
        
        let url = URL(string: Bundle.main.path(forResource: "button", ofType: "wav")!)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url!)
            guard let player = player else { return }
            player.prepareToPlay()
            //player.delegate = self as? AVAudioPlayerDelegate
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
        
}

