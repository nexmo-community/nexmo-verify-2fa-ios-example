import Foundation
import UIKit
import Parse

class TransferViewController:UIViewController {
    
    var checkingAmount:Double!
    var savingAmount:Double!
    var transferAmt:Double!
    var currentUser:PFUser!
    var transferSource:String!
    var newBalance:String!
    var afterTransferTotal:Double!
    
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var segmentedAccount: UISegmentedControl!
    
    @IBAction func segmentedAccountAction(sender: UISegmentedControl) {
        switch segmentedAccount.selectedSegmentIndex
        {
        case 0:
            transferToText.text = "Savings Account";
        case 1:
            transferToText.text = "Checkings Account";
        default:
            break; 
        } 
    }
    
    @IBAction func completeTransfer(sender: AnyObject) {
        if (transferAmount.text!.isEmpty == false) {
            transferAmt = Double(transferAmount.text!)
            print("Transfer Amount: \(transferAmt)")
            
            if segmentedAccount.selectedSegmentIndex == 0 {
                checkingToSaving()
            }
            else {
                print("savingtochecking")
                savingToChecking()
            }
        }
    }
    
    @IBOutlet weak var transferToText: UILabel!
    
    func checkingToSaving() {
        print("checkingToSaving")
        if checkingAmount - transferAmt > 0 {
            checkingAmount =  checkingAmount - transferAmt
            savingAmount = savingAmount + transferAmt
            PFUser.currentUser()!["checking"] = checkingAmount
            PFUser.currentUser()!["saving"] = savingAmount
            PFUser.currentUser()!.saveInBackground()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("transferSucessful", sender: self)
            }

        }
            
        else {
            print("ERROR")
            let alert = UIAlertController(title: "Transfer Error", message: "You do not have the requested transfer amount in your Checking Account. Please try again.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Back", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func savingToChecking() {
        if savingAmount - transferAmt > 0 {
            savingAmount = savingAmount - transferAmt
            checkingAmount =  checkingAmount + transferAmt
            PFUser.currentUser()!["saving"] = savingAmount
            PFUser.currentUser()!.saveInBackground()
            PFUser.currentUser()!["checking"] = checkingAmount
            PFUser.currentUser()!.saveInBackground()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("transferSucessful", sender: self)
            }
        }
        else {
            print("ERROR")
            let alert = UIAlertController(title: "Transfer Error", message: "You do not have the requested transfer amount in your Savings Account. Please try again.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Back", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser() != nil {
            checkingAmount = PFUser.currentUser()!["checking"] as! Double
            savingAmount = PFUser.currentUser()!["saving"] as! Double
            print("not nill")
        }
    }
        
}