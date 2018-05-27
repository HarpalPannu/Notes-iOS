//  RecoderView.swift
//  Notes
//  Created by Mac on 2018-03-31.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit
import AVFoundation

class RecoderView: UIViewController {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var recTimer: UILabel!
    var fileName:String = String()
    var onSave:((_ data:String)->())?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        let fileMgr = FileManager.default
        fileName = String(Int64(Date().timeIntervalSince1970 * 1000)) + ".caf"
        let dirPaths = fileMgr.urls(for: .documentDirectory,in: .userDomainMask)
        print(dirPaths[0])
        let soundFileURL = dirPaths[0].appendingPathComponent(fileName)
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,with:.defaultToSpeaker)
        }catch{
            print("audioSession error: \(error.localizedDescription)")
        }
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,settings: recordSettings as [String : AnyObject])
                audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        audioRecorder?.record()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    override func viewDidAppear(_ animated: Bool) {
        let circleLayer = CAShapeLayer()
        let circleradius = view.center.y - recTimer.frame.origin.y + 15
        print(circleradius)
        let bgCircle = UIBezierPath(arcCenter: view.center, radius: circleradius , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circleLayer.path = bgCircle.cgPath
        circleLayer.strokeColor = UIColor(red:0.34, green:0.12, blue:0.25, alpha:1.0).cgColor
        circleLayer.lineWidth = 20
        circleLayer.fillColor = UIColor(red:0.08, green:0.09, blue:0.13, alpha:1.0).cgColor
        view.layer.insertSublayer(circleLayer, at: 0)
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 0.8
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        circleLayer.add(animation, forKey: "pulsing")
    }
    
    @IBAction func stopRecBtn(_ sender: UIButton) {
        print("Stoped")
        if (audioRecorder?.isRecording)!{
            audioRecorder?.stop()
        }
        onSave?(fileName)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func update() {
        recTimer.text = getCurrentTimeAsString()
    }
    func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = audioRecorder?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}

