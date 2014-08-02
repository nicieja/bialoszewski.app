//
//  errorService.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import Foundation

class ErrorService {
    
    let controller: RecordViewController!
    
    init(ctrl: RecordViewController) {
        controller = ctrl
    }
    
    func error(message: String) {
        alert("Ups", message: message, ok: "Try again")
    }
    
    func alert(title: String, message: String, ok: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.Default, handler: nil))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
}