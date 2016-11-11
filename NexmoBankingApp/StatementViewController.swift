import Foundation
import UIKit
import Parse

class StatementViewController: UIViewController {
    
    @IBAction func billPay(_ sender: AnyObject) { //UI Placeholder
        print("billpay")
        let alert = UIAlertView()
        alert.title = "Incorrect Choice"
        alert.message = "The selection you have selected has not been configured with this demo application."
        alert.addButton(withTitle: "Back")
        alert.show()
    }
    
    @IBAction func deposits(_ sender: AnyObject) { //UI Placeholder
        print("deposits")
        let alert = UIAlertView()
        alert.title = "Incorrect Choice"
        alert.message = "The selection you have selected has not been configured with this demo application."
        alert.addButton(withTitle: "Back")
        alert.show()
    }
    
    @IBOutlet weak var switch2FA: UISwitch!
    var switchBoolValue:Bool!

    @IBAction func logoutUser(_ sender: AnyObject) {
        logout() 
        self.performSegue(withIdentifier: "logoutUser", sender: self)
    }
  
    @IBAction func transfer(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "transferSegue", sender: self)
    }
    
    @IBOutlet weak var checkingAmount: UILabel!
    @IBOutlet weak var savingAmount: UILabel!
    
    func logout() {
        if switchBoolValue == true {
            if PFUser.current() != nil {
                print(PFUser.current()!.value(forKey: "smsVerification") as! Bool)
                print("2fa true && switch on")
                let alert = UIAlertController(title: "SMS Verification", message: "Perform SMS verification on login?", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Continue", style: .default) {
                    UIAlertAction in
                    print("SMS TRUE sucessful logout")
                    PFUser.current()!["smsVerification"] = true
                    PFUser.current()!.saveInBackground()
                    print(PFUser.current()!["smsVerification"] as! Bool)
                    self.performSegue(withIdentifier: "logoutUser", sender: self)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            print("SMS FALSE sucessful logout")
            PFUser.current()!["smsVerification"] = false
            PFUser.current()!.saveInBackground()
            print(PFUser.current()!["smsVerification"] as! Bool)
            self.performSegue(withIdentifier: "logoutUser", sender: self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        checkingAmount.text = "$\(String(Double(round(100*(PFUser.current()!["checking"] as! Double))/100)))"
        savingAmount.text = "$\(String(Double(round(100*(PFUser.current()!["saving"] as! Double))/100)))"
        switch2FA.addTarget(self, action: #selector(StatementViewController.switchMoved), for: UIControlEvents.valueChanged)
        switchBoolValue = true
    }
    
    func switchMoved() {
        if switch2FA.isOn {
            switchBoolValue = true
            print("switch on")
        }
        else {
            switchBoolValue = false
            print("switch off")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
    }
}
