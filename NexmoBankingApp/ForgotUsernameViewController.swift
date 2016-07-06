//
//  ForgotUsernameViewController.swift
//  NexmoBankingApp
//
//  Created by Sidharth Sharma on 2/1/16.
//  Copyright © 2016 Sidharth Sharma. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ForgotUsernameViewController:UIViewController {
    
    @IBOutlet weak var accountID: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var emailAddress: UITextField!

    @IBAction func requestUsername(sender: AnyObject) {
        checkAccountInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkAccountInfo() {
        if (phoneNumber.text!.isEmpty || accountID.text!.isEmpty || emailAddress.text!.isEmpty) {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter all the required fields.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Continue", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            var query = PFQuery(className: "_User")
            query.whereKey("objectId", equalTo: accountID.text!)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    print("No username found. Please try again.")
                }
                else {
                    let foundUsername = object!.valueForKey("username")
                    let foundPhone = object!.valueForKey("phoneNumber")
                    let foundEmail = object!.valueForKey("email")
                    if (foundPhone as! String == self.phoneNumber.text!) && (foundEmail as! String == self.emailAddress.text!) {
                        let alert = UIAlertController(title: "Found Username", message: "The information you provided was a match. Your Online ID is: \(foundUsername!).", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .Default, handler: nil)
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = UIAlertController(title: "Unsucessful Verification", message: "The information you provided cannot be verified. Please try again.", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .Default, handler: nil)
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}