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
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {
    
    var window: UIWindow?
    
    var registrationOptions = [String: AnyObject]()
    var registrationToken: String?
    
    let gcmSenderId = "GCMSENDERID"
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
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Initialise GCM
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderId,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: self.handleGcmToken)
        print("registered for push notifications")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if (VerifyClient.handleNotification(userInfo, performSilentCheck: false )) {
            print("Notification recieved.")
            return
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderId, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: self.handleGcmToken)
    }
    
    func handleGcmToken(token: String!, error: NSError!) {
        if let error = error {
            print("failed to get gcm token with error \(error.localizedDescription)")
        } else {
            print("gcm token:\n\(token)")
            // provide nexmo client with gcm token
            NexmoClient.setGcmToken(token)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) { }
    
    func applicationDidEnterBackground(application: UIApplication) { }
    
    func applicationWillEnterForeground(application: UIApplication) { }
    
    func applicationDidBecomeActive(application: UIApplication) { }
    
    func applicationWillTerminate(application: UIApplication) { }
}