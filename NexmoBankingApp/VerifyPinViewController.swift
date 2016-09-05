import Foundation
import UIKit
import Parse
import VerifyIosSdk

class VerifyPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinCode: UITextField!
    var sitekey:String!
    var requestID:String!
    var user_verified:Bool!
    
    @IBAction func verifyButton(sender: AnyObject) {
        if pinCode.text!.isEmpty {
            let alert = UIAlertController(title: "Enter Pin Code", message: "Please check your phone and enter the pin code send via SMS.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Back", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            VerifyClient.checkPinCode(pinCode.text!)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func verifyUser() {
        // Default: smsVerification == false unless SMS Verification was checked. 
        // At which point, the user must be verified.
        print("bool value \(PFUser.currentUser()!["smsVerification"].boolValue == true)")
        print("user_verified? \(user_verified)")
        if (PFUser.currentUser()!["smsVerification"].boolValue == true && user_verified == true) {
            VerifyClient.verifyStandalone(countryCode: "US", phoneNumber: PFUser.currentUser()!["phoneNumber"] as! String,
                onVerifyInProgress: {
                    print("verifystandalone 2factorauth \(PFUser.currentUser()!["phoneNumber"] as! String)")
                },
                onUserVerified: {
                    let alert = UIAlertController(title: "Sucessful Identification", message: "Welcome \(PFUser.currentUser()!.username!)", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .Default) {
                            UIAlertAction in
                                self.performSegueWithIdentifier("pinVerified", sender: self)
                        }
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                },
                onError: { verifyError in
                        let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "Goodbye", style: .Default) {
                            UIAlertAction in
                            VerifyClient.cancelVerification() { error in
                                if let _ = error {
                                    //something went wrong whilst attempting to cancel the current verification request
                                }
                                else {
                                    print("no error ")
                                }
                            }
                            self.performSegueWithIdentifier("logout", sender: self)
                        }
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else {
            VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.currentUser()!["phoneNumber"] as! String,
                onVerifyInProgress: {
                },
                onUserVerified: {
                    self.performSegueWithIdentifier("pinVerified", sender: self)
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
            print(PFUser.currentUser()!["smsVerification"].boolValue)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinCode.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let alert = UIAlertController(  title: "User Phone Verification", message: "Your identity is being verified.", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "Continue", style: .Default) {
            UIAlertAction in
            self.verifyUser()
        }
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}