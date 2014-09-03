//
//  PlayerService.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import AVFoundation

class PlayerService {
    
    var player: AVAudioPlayer!
    
    let controller: RecordViewController!
    let handler: ErrorService!
    
    var error: NSError?
    
    init(ctrl: RecordViewController, recorderService: RecorderService) {
        controller = ctrl
        handler = ErrorService(ctrl: controller)
        
        player = AVAudioPlayer(contentsOfURL: recorderService.recorder.url, error: &error)
        errorHandler(error, message: "Odtwarzacz nie może zostać uruchomiony.")
    }
    
    func play() {
        player.prepareToPlay()
        player.delegate = controller
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func errorHandler(error: NSError?, message: String) {
        if (error != nil) {
            handler.error(message)
        }
    }
    
}