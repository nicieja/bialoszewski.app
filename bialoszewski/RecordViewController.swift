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

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    
    var dropboxService: DropboxService!
    var recorderService: RecorderService!
    var playerService: PlayerService!
    var handler: ErrorService!
    
    var currentTime = Int()
    let timeFormat: String = "%02d:%02d"
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        saveButton.enabled = false
        
        recorderService = RecorderService(ctrl: self)
        handler = ErrorService(ctrl: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        dropboxService = DropboxService(ctrl: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
        if playerService?.player.playing {
            playerService.stop()
        }
        
        if !recorderService.recorder.recording {
            recorderService.record()
            
            recordButton.setTitle("Stop", forState: UIControlState.Normal)
            timerLabel.text = NSString(format: timeFormat, 0, 0)
            
            startTimer()
        } else {
            recorderService.stop()
            dropboxService.setupFile(recorderService.filename, path: recorderService.outputFileURL.path)
            
            recordButton.setTitle(nil, forState: UIControlState.Normal)
            playButton.enabled = true
            saveButton.enabled = true
            
            stopTimer()
        }
    }
    
    func updateTimer() {
        if recorderService.recorder.recording {
            currentTime = Int(recorderService.recorder.currentTime)
        } else if playerService?.player.playing {
            currentTime = Int(playerService.player.duration - playerService.player.currentTime)
        }
        
        // NOTE: hackish. When the player stops playing and the recorder is not
        //       recording, set currentTime to the recording's duration
        if playerService?.player.playing == false && recorderService.recorder.recording == false {
            currentTime = Int(playerService.player.duration)
        }
    
        var time = calculateTimeAndMinutes(currentTime)
        var label = NSString(format: timeFormat, time["minutes"]!, time["seconds"]!)
        timerLabel.text = label
    }
    
    func calculateTimeAndMinutes(time: Int) -> [String: Int] {
        var minutes: Int = time / 60
        var seconds: Int = time - (minutes * 60)
        
        var timeObject = [
            "minutes": minutes,
            "seconds": seconds
        ]
        
        return timeObject
    }
    
    @IBAction func playTapped(sender: UIButton) {
        if !recorderService.recorder.recording {
            if playerService.player.playing {
                playerService.stop()
                stopTimer()
                
                playButton.setTitle("Play", forState: UIControlState.Normal)
            } else {
                playerService.play()
                startTimer()
                
                playButton.setTitle("Pause", forState: UIControlState.Normal)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool) {
        playButton.setTitle("Play", forState: UIControlState.Normal)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully: Bool) {
        playerService = PlayerService(ctrl: self, recorderService: recorderService)
    }
    
    @IBAction func saveToDropbox(sender: UIButton) {
        dropboxService.save()
        
        handler.alert("Thanks!", message: "Your recording was saved.", ok: "Yay!")
        
        saveButton.enabled = false
        playButton.enabled = false
        timerLabel.text = ""
        
        recorderService = RecorderService(ctrl: self)

    }
    
}
