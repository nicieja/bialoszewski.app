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
    
    let secret: String = ""
    let key: String = ""
    
    let storyboard: UIStoryboard = UIStoryboard()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        let accountManager:DBAccountManager = DBAccountManager(appKey: key, secret: secret)
        DBAccountManager.setSharedManager(accountManager)

        return true
    }
    
    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication source: NSString!, annotation: AnyObject!) -> Bool {
        if let account: DBAccount = DBAccountManager.sharedManager().handleOpenURL(url) {
            return true
        }
        
        return false
    }

}

