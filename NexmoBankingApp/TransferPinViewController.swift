import Foundation
import UIKit
import Parse
import NexmoVerify

class TransferPinViewController:UIViewController {
    
    var checkingAmount:Double!
    var savingAmount:Double!
    var transferAmt:Double!
    var requestID:String!
    var transferSource:String!
    var afterTransferTotal:Double!
    
    @IBOutlet weak var pincode: UITextField!
    
    @IBAction func checkPinCode(_ sender: AnyObject) {
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
            PFUser.current()?["checking"] = checkingAmount
            PFUser.current()?["saving"] = savingAmount
            PFUser.current()?.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferVerified", sender: self)
            }
        }
        else if transferSource == "savingToChecking"{
            savingAmount = savingAmount - transferAmt
            checkingAmount =  checkingAmount + transferAmt
            PFUser.current()?["saving"] = savingAmount
            PFUser.current()?.saveInBackground()
            PFUser.current()?["checking"] = checkingAmount
            PFUser.current()?.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferVerified", sender: self)
            }
        }
    }
    
    func verify() {
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.current()?["phoneNumber"] as! String,
            onVerifyInProgress: {
            },
            onUserVerified: {
                self.performTransfer()
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
    
    
}
