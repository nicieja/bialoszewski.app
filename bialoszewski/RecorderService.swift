//
//  RecorderService.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import Foundation
import AVFoundation

class RecorderService {
    
    var recorder: AVAudioRecorder!
    let session: AVAudioSession = AVAudioSession.sharedInstance()

    var settings: NSMutableDictionary = NSMutableDictionary()
    var filename: String!
    var outputFileURL: NSURL!
    
    let controller: RecordViewController!
    let handler: ErrorService!
    
    let dateFormat: String =  "yyyy-MM-dd 'at' HH:mm:ss"
    var error: NSError?
    
    init(ctrl: RecordViewController) {
        controller = ctrl
        
        setFileName()
        setOutputFileURL()
        setRecordSettings()
        
        initializeSession()
        
        recorder = AVAudioRecorder(URL: outputFileURL, settings: settings, error: &error)
        errorHandler(error, message: "The recorder could not be initialized.")
        
        recorder.delegate = controller;
        recorder.meteringEnabled = true;
        recorder.prepareToRecord()
    }
    
    func initializeSession() {
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        errorHandler(error, message: "The session could not be initialized.")
    }
    
    func setOutputFileURL() {
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var pathComponents = [paths.lastObject, filename]
        
        outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
    }
    
    func setFileName() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        var timestamp: NSDate = NSDate.date()
        var formattedDateString: String = dateFormatter.stringFromDate(timestamp)
        filename = formattedDateString + ".m4a"
    }
    
    func setRecordSettings() {
        settings.setValue(kAudioFormatMPEG4AAC, forKey: AVFormatIDKey)
        settings.setValue(44100.0, forKey: AVSampleRateKey)
        settings.setValue(2, forKey: AVNumberOfChannelsKey)
    }
    
    func record() {
        session.setActive(true, error: &error)
        errorHandler(error, message: "The recording session could not be modified.")
        
        recorder.record()
    }
    
    func stop() {
        session.setActive(false, error: &error)
        errorHandler(error, message: "The recording session could not be modified.")

        recorder.stop()
    }
    
    func errorHandler(error: NSError?, message: String) {
        if error {
            handler.error(message)
        }
    }
    
}