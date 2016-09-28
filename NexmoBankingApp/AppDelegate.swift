//
//  AppDelegate.swift
//  NexmoBankingApp
//
//  THIS IS YOUR STARTING POINT! :-)
//
//  If you have any questions please feel free to ask me directly via e-mail. 
//  sidharth.sharma@nexmo.com
//
//  Created by Sidharth Sharma on 5/22/16.
//  Copyright © 2016 Sidharth Sharma. All rights reserved.
//

import UIKit
import Parse
import VerifyIosSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
        
    private var appID = "APP_ID"
    private var sharedSecret = "SHARED_SECRET"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "BACK4APP_APP_ID"
            $0.clientKey = "BACK4APP_CLIENT_KEY"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initializeWithConfiguration(configuration)
        
        
        NexmoClient.start(applicationId: appID, sharedSecretKey: sharedSecret)
        
        return true
    }
 
    
    func applicationWillResignActive(application: UIApplication) { }
    
    func applicationDidEnterBackground(application: UIApplication) { }
    
    func applicationWillEnterForeground(application: UIApplication) { }
    
    func applicationDidBecomeActive(application: UIApplication) { }
    
    func applicationWillTerminate(application: UIApplication) { }
}
