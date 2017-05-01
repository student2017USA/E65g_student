//
//  UIViewController+Extension.swift
//  FinalProject
//
//  Created by Angela Baruth on 10/04/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class BaseViewController:  UIViewController {
    
    var player : AVAudioPlayer?
    
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
