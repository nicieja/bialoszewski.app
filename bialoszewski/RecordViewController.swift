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

    @IBOutlet var playButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var reminderToSave: UILabel!
    @IBOutlet var recordButton: RecordIcon!
    
    var dropboxService: DropboxService!
    var recorderService: RecorderService!
    var playerService: PlayerService!
    var handler: ErrorService!
    
    var currentTime: Int!
    let timeFormat: String = "%02d:%02d"
    var timer: NSTimer!
    
    let maxRecordingTime: Int = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        saveButton.enabled = false
        timerLabel.hidden = true
        reminderLabel.hidden = true
        reminderToSave.hidden = true
        
        recorderService = RecorderService(ctrl: self)
        handler = ErrorService(ctrl: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        dropboxService = DropboxService(ctrl: self)
        recordButton.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
        if (playerService?.player.playing != nil) {
            stopPlaying()
        }
        
        if !recorderService.recorder.recording {
            startRecording()
        } else {
            stopRecording()
        }
    }
        
    func startRecording() {
        recorderService.record()
        
        showTimer()
        
        playButton.enabled = false
        saveButton.enabled = false
        
        startTimer()
    }
    
    func stopRecording() {
        recorderService.stop()
        dropboxService.setupFile(recorderService.filename, path: recorderService.outputFileURL.path!)
        
        transitionCrossDissolve({
            self.playButton.enabled = true
            self.saveButton.enabled = true
            }, {})
        
        reminderToSave.hidden = false
        
        transitionCrossDissolve({
            self.reminderToSave.hidden = false
            }, completion: {})
        
        stopTimer()
    }
    
    func updateTimer() {
        if (recorderService.recorder.recording || playerService?.player.playing != nil) {
            if recorderService.recorder.recording {
                currentTime = Int(recorderService.recorder.currentTime)

                recordButton.animateCircleLayer(CGFloat(recorderService.recorder.currentTime))
                
                // too long recordings handler
                if currentTime? > maxRecordingTime {
                    stopRecording()
                }
            } else if (playerService?.player.playing != nil) {
                currentTime = Int(playerService.player.duration - playerService.player.currentTime)
            }
            
            // NOTE: hackish. When the player stops playing and the recorder is not
            //       recording, set currentTime to the recording's duration
            if playerService?.player.playing == false && recorderService.recorder.recording == false {
                currentTime = Int(playerService.player.duration)
            }
        
            if currentTime > 0 {
                var time = calculateTimeAndMinutes(currentTime)
                var label = NSString(format: timeFormat, time["minutes"]!, time["seconds"]!)
                timerLabel.text = label
                
                if currentTime > maxRecordingTime - 30 {
                    self.timerLabel.textColor = UIColor.redColor()
                }
            }
        }
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
                stopPlaying()
            } else {
                startPlaying()
            }
        }
    }
    
    func stopPlaying() {
        playerService.stop()
        saveButton.enabled = true
        stopTimer()
        
        playButton.setTitle("Odtwórz", forState: UIControlState.Normal)
    }
    
    func startPlaying() {
        playerService.play()
        saveButton.enabled = false
        startTimer()
        
        playButton.setTitle("Pauza", forState: UIControlState.Normal)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool) {
        saveButton.enabled = true
        playButton.setTitle("Odtwórz", forState: UIControlState.Normal)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully: Bool) {
        playerService = PlayerService(ctrl: self, recorderService: recorderService)
        
        if currentTime? > maxRecordingTime {
            saveAndResetToDefaults()
        }
    }
    
    @IBAction func saveToDropbox(sender: UIButton) {
        saveAndResetToDefaults()
    }
    
    func saveAndResetToDefaults() {
        dropboxService.save()

        saveButton.enabled = false
        playButton.enabled = false
        reminderToSave.hidden = true
        currentTime = nil
        hideTimer()
        playerService = nil
        
        recorderService = RecorderService(ctrl: self)
    }
    
    func hideTimer() {
        fadeTimer(false)
    }
    
    func showTimer() {
        fadeTimer(true)
    }
    
    func fadeTimer(show: Bool) {
        transitionCrossDissolve({
            
            if show {
                self.timerLabel.text = NSString(format: self.timeFormat, 0, 0)
            }
            
            self.timerLabel.textColor = UIColor.blackColor()
            
            self.reminderLabel.hidden = !show
            self.timerLabel.hidden = !show
        }, completion: {})
    }
    
    func transitionCrossDissolve(animations: () -> (), completion: () -> ()) {
        UIView.transitionWithView(self.view, duration: 0.2, options: .TransitionCrossDissolve, animations: animations, completion: { finished in completion() })
    }
}
