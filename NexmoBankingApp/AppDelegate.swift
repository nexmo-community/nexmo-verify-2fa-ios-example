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
import NexmoVerify

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
        
    fileprivate var appID = "NEXMO-APP-ID"
    fileprivate var sharedSecret = "NEXMO-SHARED-SECRET"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "BACK4APP_APP_ID"
            $0.clientKey = "BACK4APP_CLIENT_KEY"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        
        NexmoClient.start(applicationId: appID, sharedSecretKey: sharedSecret)
        
        return true
    }
 
    
    func applicationWillResignActive(_ application: UIApplication) { }
    
    func applicationDidEnterBackground(_ application: UIApplication) { }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) { }
    
    func applicationWillTerminate(_ application: UIApplication) { }
}
