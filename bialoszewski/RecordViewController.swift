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
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        saveButton.enabled = false
        
        var emitError: NSError? = nil
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var pathComponents = [paths.lastObject, "file.m4a"]
        var outputFileURL: NSURL = NSURL.fileURLWithPathComponents(pathComponents)
        
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        let recordSetting: NSMutableDictionary = NSMutableDictionary()
        
        recordSetting.setValue(kAudioFormatMPEG4AAC, forKey: AVFormatIDKey)
        recordSetting.setValue(44100.0, forKey:AVSampleRateKey)
        recordSetting.setValue(2, forKey:AVNumberOfChannelsKey)
        
        recorder = AVAudioRecorder(URL: outputFileURL, settings: recordSetting, error: nil)
        recorder.delegate = self;
        recorder.meteringEnabled = true;
        recorder.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
        if player?.playing {
            player.stop()
        }
        
        if !recorder.recording {
            session.setActive(true, error: nil)
        
            recorder.record()
            recordButton.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            session.setActive(false, error: nil)
            recorder.stop()

            recordButton.setTitle(nil, forState: UIControlState.Normal)
            
            playButton.enabled = true
            saveButton.enabled = true
        }
    }
    
    @IBAction func playTapped(sender: UIButton) {
        if !recorder.recording {            
            if player.playing {
                player.stop()
                playButton.setTitle("Play", forState: UIControlState.Normal)
            } else {
                player.prepareToPlay()
                
                playButton.setTitle("Pause", forState: UIControlState.Normal)
                player.delegate = self
                player.play()
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
