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
            PFUser.current()!["checking"] = checkingAmount
            PFUser.current()!["saving"] = savingAmount
            PFUser.current()!.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferVerified", sender: self)
            }
        }
        else if transferSource == "savingToChecking"{
            savingAmount = savingAmount - transferAmt
            checkingAmount =  checkingAmount + transferAmt
            PFUser.current()!["saving"] = savingAmount
            PFUser.current()!.saveInBackground()
            PFUser.current()!["checking"] = checkingAmount
            PFUser.current()!.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferVerified", sender: self)
            }
        }
    }
    
    func verify() {
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.current()!["phoneNumber"] as! String,
            onVerifyInProgress: {
            },
            onUserVerified: {
                self.performTransfer()
            },
            onError: { verifyError in
                let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Goodbye", style: .default, handler: { (action) in
                    //execute some code when this option is selected
                    VerifyClient.cancelVerification() { error in
                        if let error = error {
                            // something wen't wrong whilst attempting to cancel the current verification request
                            return
                        }
                    }
                    self.performSegue(withIdentifier: "logout", sender: self)
                }))
                
                self.present(alert, animated: true, completion: nil)
        })
    }
    
    
}
