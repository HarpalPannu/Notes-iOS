//  AudioPlayer.swift
//  Notes
//  Created by Balwinder Singh on 2018-04-01.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit
import AVFoundation
class AudioPlayer: UIViewController {
    var bombSoundEffect: AVAudioPlayer?
    var AudioPath:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AudioPath!)
        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: AudioPath!)
            bombSoundEffect?.play()
        } catch {
           print(error)
        }
        bombSoundEffect?.play()
        bombSoundEffect?.volume = 1.0
        print(bombSoundEffect?.duration as Any)
    }
    
    @IBAction func btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
