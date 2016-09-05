//
//  VerifyTransferViewController.swift
//  NexmoBankingApp
//
//  Created by Sidharth Sharma on 3/24/16.
//  Copyright © 2016 Sidharth Sharma. All rights reserved.
//

import Foundation
import UIKit
import Parse
import VerifyIosSdk

class VerifyTransferViewController:UIViewController {
    
    var checkingAmount:Double!
    var savingAmount:Double!
    var transferAmt:Double!
    var requestID:String!
    var transferSource:String!
    var afterTransferTotal:Double!
    
    @IBOutlet weak var pincode: UITextField!
    
    @IBAction func checkPin(sender: AnyObject) {
        VerifyClient.checkPinCode(pincode.text!)
    }
    
    func performTransfer() {
        if transferSource == "checkingToSaving" {
            checkingAmount =  checkingAmount - transferAmt
            savingAmount = savingAmount + transferAmt
            PFUser.currentUser()!["checking"] = checkingAmount
            PFUser.currentUser()!["saving"] = savingAmount
            PFUser.currentUser()!.saveInBackground()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("successfulTransfer", sender: self)
            }
        }
        else if transferSource == "savingToChecking"{
            savingAmount = savingAmount - transferAmt
            checkingAmount =  checkingAmount + transferAmt
            PFUser.currentUser()!["saving"] = savingAmount
            PFUser.currentUser()!.saveInBackground()
            PFUser.currentUser()!["checking"] = checkingAmount
            PFUser.currentUser()!.saveInBackground()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("successfulTransfer", sender: self)
            }
        }
    }
    
    func verify() {
        VerifyClient.verifyStandalone(countryCode: "US", phoneNumber: PFUser.currentUser()!["phoneNumber"]! as! String,
            onVerifyInProgress: {
                print("Verification Started")
            },
            onUserVerified: {
                let alert = UIAlertController(title: "Sucessful Identification", message: "Touch ID Authentication Succeeded. Continue with Sign In Process.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Continue", style: .Default) {
                    UIAlertAction in
                    self.performTransfer()
                }
                alert.addAction(defaultAction)

            },
            onError: { verifyError in
                let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Goodbye", style: .Default) {
                    UIAlertAction in
                    VerifyClient.cancelVerification() { error in
                        if let _ = error {
                            return
                        }
                    }
                    self.performSegueWithIdentifier("logout", sender: self)
                }
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verify()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "successfulTransfer") {
            let statementVC = segue.destinationViewController as! StatementViewController
            statementVC.currentUser = PFUser.currentUser()!
        }
    }
}
