import Foundation
import UIKit
import Parse

class ForgotUsernameViewController:UIViewController {
    
    @IBOutlet weak var accountID: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var emailAddress: UITextField!

    @IBAction func requestUsername(_ sender: AnyObject) {
        checkAccountInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkAccountInfo() {
        if (phoneNumber.text!.isEmpty || accountID.text!.isEmpty || emailAddress.text!.isEmpty) {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter all the required fields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            var query = PFQuery(className: "_User")
            query.whereKey("objectId", equalTo: accountID.text!)
            query.getFirstObjectInBackground {
                (object, error) -> Void in
                if error != nil || object == nil {
                    print("No username found. Please try again.")
                }
                else {
                    let foundUsername = object!.value(forKey: "username")
                    let foundPhone = object!.value(forKey: "phoneNumber")
                    let foundEmail = object!.value(forKey: "email")
                    if (foundPhone as! String == self.phoneNumber.text!) && (foundEmail as! String == self.emailAddress.text!) {
                        let alert = UIAlertController(title: "Found Username", message: "The information you provided was a match. Your Online ID is: \(foundUsername!).", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = UIAlertController(title: "Unsucessful Verification", message: "The information you provided cannot be verified. Please try again.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}
