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
    
    @IBAction func segmentedAccountAction(_ sender: UISegmentedControl) {
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
    
    @IBAction func completeTransfer(_ sender: AnyObject) {
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
            PFUser.current()!["checking"] = checkingAmount
            PFUser.current()!["saving"] = savingAmount
            PFUser.current()!.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferSucessful", sender: self)
            }

        }
            
        else {
            print("ERROR")
            let alert = UIAlertController(title: "Transfer Error", message: "You do not have the requested transfer amount in your Checking Account. Please try again.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func savingToChecking() {
        if savingAmount - transferAmt > 0 {
            savingAmount = savingAmount - transferAmt
            checkingAmount =  checkingAmount + transferAmt
            PFUser.current()!["saving"] = savingAmount
            PFUser.current()!.saveInBackground()
            PFUser.current()!["checking"] = checkingAmount
            PFUser.current()!.saveInBackground()
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "transferSucessful", sender: self)
            }
        }
        else {
            print("ERROR")
            let alert = UIAlertController(title: "Transfer Error", message: "You do not have the requested transfer amount in your Savings Account. Please try again.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current() != nil {
            checkingAmount = PFUser.current()!["checking"] as! Double
            savingAmount = PFUser.current()!["saving"] as! Double
            print("not nill")
        }
    }
        
}
