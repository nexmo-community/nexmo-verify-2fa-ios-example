import Foundation
import UIKit
import Parse
import NexmoVerify

class VerifyPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinCode: UITextField!
    var sitekey:String!
    var requestID:String!

    
    
    @IBAction func verifyButton(_ sender: AnyObject) {
        if pinCode.text!.isEmpty {
            let alert = UIAlertController(title: "Enter Pin Code", message: "Please check your phone and enter the pin code send via SMS.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
        else {
            VerifyClient.checkPinCode(pinCode.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func verifyUser() {
        // Default: smsVerification == false unless SMS Verification was checked. 
        // At which point, the user must be verified.
        
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.current()?["phoneNumber"] as! String,
            onVerifyInProgress: {
            },
            onUserVerified: {
                self.performSegue(withIdentifier: "pinVerified", sender: self)
            },
            onError: { verifyError in
                switch (verifyError) {
                    case .invalidPinCode:
                        UIAlertView(title: "Wrong Pin Code", message: "The pin code you entered is invalid.", delegate: nil, cancelButtonTitle: "Try again!").show()
                    case .invalidCodeTooManyTimes:
                        let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Goodbye", style: .default) {
                            UIAlertAction in
                            
                            VerifyClient.cancelVerification() { error in
                                if let error = error {
                                    // something wen't wrong whilst attempting to cancel the current verification request
                                    return
                                }
                            }
                            self.performSegue(withIdentifier: "logout", sender: self)
                        }
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        print(verifyError.rawValue)
                        break
                }
        })
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinCode.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let alert = UIAlertController(  title: "User Phone Verification", message: "Your identity is being verified.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Continue", style: .default) {
            UIAlertAction in
            self.verifyUser()
        }
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}
