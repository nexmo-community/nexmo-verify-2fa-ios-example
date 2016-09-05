import Foundation
import UIKit
import Parse

class StatementViewController: UIViewController {
    
    @IBAction func billPay(sender: AnyObject) { //UI Placeholder
        print("billpay")
        let alert = UIAlertView()
        alert.title = "Incorrect Choice"
        alert.message = "The selection you have selected has not been configured with this demo application."
        alert.addButtonWithTitle("Back")
        alert.show()
    }
    
    @IBAction func deposits(sender: AnyObject) { //UI Placeholder
        print("deposits")
        let alert = UIAlertView()
        alert.title = "Incorrect Choice"
        alert.message = "The selection you have selected has not been configured with this demo application."
        alert.addButtonWithTitle("Back")
        alert.show()
    }
    
    @IBOutlet weak var switch2FA: UISwitch!
    var switchBoolValue:Bool!

    @IBAction func logoutUser(sender: AnyObject) {
        logout() 
        self.performSegueWithIdentifier("logoutUser", sender: self)
    }
  
    @IBAction func transfer(sender: AnyObject) {
        self.performSegueWithIdentifier("transferSegue", sender: self)
    }
    
    @IBOutlet weak var checkingAmount: UILabel!
    @IBOutlet weak var savingAmount: UILabel!
    
    func logout() {
        if switchBoolValue == true {
            if PFUser.currentUser() != nil {
                print(PFUser.currentUser()!.valueForKey("smsVerification") as! Bool)
                print("2fa true && switch on")
                let alert = UIAlertController(title: "SMS Verification", message: "Perform SMS verification on login?", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Continue", style: .Default) {
                    UIAlertAction in
                    print("SMS TRUE sucessful logout")
                    PFUser.currentUser()!["smsVerification"] = true
                    PFUser.currentUser()!.saveInBackground()
                    print(PFUser.currentUser()!["smsVerification"] as! Bool)
                    self.performSegueWithIdentifier("logoutUser", sender: self)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            print("SMS FALSE sucessful logout")
            PFUser.currentUser()!["smsVerification"] = false
            PFUser.currentUser()!.saveInBackground()
            print(PFUser.currentUser()!["smsVerification"] as! Bool)
            self.performSegueWithIdentifier("logoutUser", sender: self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        checkingAmount.text = "$\(String(Double(round(100*(PFUser.currentUser()!["checking"] as! Double))/100)))"
        savingAmount.text = "$\(String(Double(round(100*(PFUser.currentUser()!["saving"] as! Double))/100)))"
        switch2FA.addTarget(self, action: #selector(StatementViewController.switchMoved), forControlEvents: UIControlEvents.ValueChanged)
        switchBoolValue = true
    }
    
    func switchMoved() {
        if switch2FA.on {
            switchBoolValue = true
            print("switch on")
        }
        else {
            switchBoolValue = false
            print("switch off")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    }
}