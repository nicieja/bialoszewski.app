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
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var outputFileURL: NSURL!
    var currentTime = Int()
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    var filesystem: DBFilesystem!
    
    let timeFormat: String = "%02d:%02d"
    
    var fileName: String!
    
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        saveButton.enabled = false
        
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        recorderSetup()
    }
    
    override func viewDidAppear(animated: Bool) {
        if !DBAccountManager.sharedManager().linkedAccount {
            DBAccountManager.sharedManager().linkFromController(self)
        } else {
            setupDropboxFilesystem()
        }
    }
    
    func setupDropboxFilesystem() {
        filesystem = DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount)
        DBFilesystem.setSharedFilesystem(filesystem)
    }
    
    func recorderSetup() {
        setFileName()
        
        recorder = AVAudioRecorder(URL: setOutputFileURL(), settings: setRecordSettings(), error: nil)
        recorder.delegate = self;
        recorder.meteringEnabled = true;
        recorder.prepareToRecord()
    }
    
    func setOutputFileURL() -> NSURL {
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var pathComponents = [paths.lastObject, fileName]
        self.outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
        return outputFileURL
    }
    
    func setFileName() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm:ss"
        
        var timestamp: NSDate = NSDate.date()
        var formattedDateString: String = dateFormatter.stringFromDate(timestamp)
        fileName = formattedDateString + ".m4a"
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
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        timer = nil
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
            stopTimer()
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
        
        // NOTE: hackish. When the player stops playing and the recorder is not
        //       recording, set currentTime to the recording's duration
        if player?.playing == false && recorder?.recording == false {
            currentTime = Int(player.duration)
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
        if !recorder.recording {
            if player.playing {
                player.stop()
                stopTimer()
                
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
    
    @IBAction func saveToDropbox(sender: UIButton) {
        var newPath: DBPath = DBPath.root().childPath(fileName)
        var path: String = outputFileURL.path
        var file: DBFile!
        
        if var info: DBFileInfo = filesystem.fileInfoForPath(newPath, error: nil) {
            file = filesystem.openFile(newPath, error: nil)
        } else {
            file = filesystem.createFile(newPath, error: nil)
        }
        
        file.writeContentsOfFile(path, shouldSteal: false, error: nil)
        
        var alert = UIAlertController(title: "Thanks!", message: "Your recording was saved.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yay!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        saveButton.enabled = false
        playButton.enabled = false
        timerLabel.text = ""
        
        recorderSetup()
    }
    
}
