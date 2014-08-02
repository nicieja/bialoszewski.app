//
//  AppDelegate.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 20/07/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    let info: NSDictionary = NSBundle.mainBundle().infoDictionary
    
    let storyboard: UIStoryboard = UIStoryboard()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        let secret: String = info.objectForKey("Dropbox App Secret") as String
        let key: String = info.objectForKey("Dropbox App Key") as String

        let accountManager:DBAccountManager = DBAccountManager(appKey: key, secret: secret)
        DBAccountManager.setSharedManager(accountManager)

        return true
    }
    
    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication source: NSString!, annotation: AnyObject!) -> Bool {
        if let account: DBAccount = DBAccountManager.sharedManager().handleOpenURL(url) {
            let filesystem: DBFilesystem = DBFilesystem(account: account)
            DBFilesystem.setSharedFilesystem(filesystem)
            return true
        }
        
        return false
    }

}

