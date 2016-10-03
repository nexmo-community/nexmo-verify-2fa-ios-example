import Foundation
import UIKit
import Parse
import VerifyIosSdk

class TransferPinViewController:UIViewController {
    
    var checkingAmount:Double!
    var savingAmount:Double!
    var transferAmt:Double!
    var requestID:String!
    var transferSource:String!
    var afterTransferTotal:Double!
    
    @IBOutlet weak var pincode: UITextField!
    
    @IBAction func checkPinCode(sender: AnyObject) {
        VerifyClient.checkPinCode(pincode.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verify()
    }
    
    func performTransfer() {
        if transferSource == "checkingToSaving" {
            checkingAmount =  checkingAmount - transferAmt
            savingAmount = savingAmount + transferAmt
            PFUser.currentUser()!["checking"] = checkingAmount
            PFUser.currentUser()!["saving"] = savingAmount
            PFUser.currentUser()!.saveInBackground()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("transferVerified", sender: self)
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
                self.performSegueWithIdentifier("transferVerified", sender: self)
            }
        }
    }
    
    func verify() {
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.currentUser()!["phoneNumber"] as! String,
            onVerifyInProgress: {
            },
            onUserVerified: {
                self.performTransfer()
            },
            onError: { verifyError in
                let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Goodbye", style: .Default) {
                    UIAlertAction in
                    VerifyClient.cancelVerification() { error in
                        if let error = error {
                        // something wen't wrong whilst attempting to cancel the current verification request
                            return
                        }
                    }
                    self.performSegueWithIdentifier("logout", sender: self)
                }
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
}
