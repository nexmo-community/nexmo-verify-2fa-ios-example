import Foundation
import UIKit
import Parse
import LocalAuthentication
import VerifyIosSdk

class SitekeyViewController:UIViewController, UITextFieldDelegate {
    
    var sitekey:String!
    let alert = UIAlertView()
    var user_verified : Bool!
    
    @IBAction func signInButton(sender: AnyObject) {
        initialWorkFlow()
    }
    
    @IBAction func incorrectKey(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("wrongUser", sender: self)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("wrongUser", sender: self)
    }
    
    @IBOutlet weak var pictureKey: UILabel!
    @IBOutlet weak var pictureKeyImage: UIImageView!
    
    func continueWorkflow() {
        self.performSegueWithIdentifier("verifyPin", sender:self)
    }
    
    func initialWorkFlow() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.continueWorkflow()
                    }
                    else {
                        let alert = UIAlertController(title: "Failed Identification", message: "Touch ID Authentication Failed. Sign In process stopped.", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .Default) {
                            UIAlertAction in
                            PFUser.logOut()
                            self.performSegueWithIdentifier("signInStopped", sender: self)
                        }
                        
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            })
        }
        else {
            print("Touch ID not available")
            self.continueWorkflow()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VerifyClient.getUserStatus(countryCode: "US", number: PFUser.currentUser()!["phoneNumber"] as! String) { status, error in
            if let _ = error {
                // unable to get user status for given device + phone number pair
                return
            }
            else if (status! == "verified") {
                self.user_verified = true
            }
            else {
                self.user_verified = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "verifyPin") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let verifyVC = segue.destinationViewController as! VerifyPinViewController
            verifyVC.user_verified = user_verified
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let sitekeyImage = PFUser.currentUser()!["sitekey"] as! PFFile
        sitekeyImage.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.pictureKeyImage.image = UIImage(data:imageData)
                }
            }
        }
    }
}