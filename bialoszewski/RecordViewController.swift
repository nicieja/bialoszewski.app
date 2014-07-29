//
//  RecordViewController.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 20/07/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet var recordButton: UIButton
    @IBOutlet var playButton: UIButton
    @IBOutlet var saveButton: UIButton
    @IBOutlet var timerLabel: UILabel
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var currentTime = Int()
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    let timeFormat: String = "%02d:%02d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        saveButton.enabled = false
        
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        recorder = AVAudioRecorder(URL: setOutputFileURL(), settings: setRecordSettings(), error: nil)
        recorder.delegate = self;
        recorder.meteringEnabled = true;
        recorder.prepareToRecord()
    }
    
    func setOutputFileURL() -> NSURL {
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var pathComponents = [paths.lastObject, "file.m4a"]
        var outputFileURL: NSURL = NSURL.fileURLWithPathComponents(pathComponents)
        return outputFileURL
    }
    
    func setRecordSettings() -> NSMutableDictionary {
        let recordSetting: NSMutableDictionary = NSMutableDictionary()
        
        recordSetting.setValue(kAudioFormatMPEG4AAC, forKey: AVFormatIDKey)
        recordSetting.setValue(44100.0, forKey:AVSampleRateKey)
        recordSetting.setValue(2, forKey:AVNumberOfChannelsKey)
        
        return recordSetting
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer() {
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
        if player?.playing {
            player.stop()
        }
        
        if !recorder.recording {
            session.setActive(true, error: nil)
            recorder.record()
            
            recordButton.setTitle("Stop", forState: UIControlState.Normal)
            timerLabel.text = NSString(format: timeFormat, 0, 0)
            startTimer()
        } else {
            session.setActive(false, error: nil)
            recorder.stop()
            recordButton.setTitle(nil, forState: UIControlState.Normal)
            
            playButton.enabled = true
            saveButton.enabled = true
        }
    }
    
    func updateTimer() {
        if recorder.recording {
            currentTime = Int(recorder.currentTime)
        } else if player.playing {
            currentTime = Int(player.duration - player.currentTime)
        }
        
        if player?.playing == false {
            currentTime = Int(player.duration)
        }
    
        var time = calculateTimeAndMinutes(currentTime)
        var label = NSString(format: timeFormat, time["minutes"]!, time["seconds"]!)
        timerLabel.text = label
    }
    
    func calculateTimeAndMinutes(time: Int) -> Dictionary<String, Int> {
        var minutes: Int = time / 60
        var seconds: Int = time - (minutes * 60)
        
        var timeObject = [
            "minutes": minutes,
            "seconds": seconds
        ]
        
        return timeObject
    }
    
    @IBAction func playTapped(sender: UIButton) {
        if !recorder.recording {
            if player.playing {
                player.stop()
                
                playButton.setTitle("Play", forState: UIControlState.Normal)
            } else {
                player.prepareToPlay()
                player.delegate = self
                player.play()
                
                startTimer()
                
                playButton.setTitle("Pause", forState: UIControlState.Normal)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool) {
        playButton.setTitle("Play", forState: UIControlState.Normal)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully: Bool) {
        player = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
    }

}
