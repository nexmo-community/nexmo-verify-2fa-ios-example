import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var onlineID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signIn(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(onlineID.text!, password:password.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("correctLogin", sender: self)
            }
        }
    }
    
    func signUpDemoAccount() {
        var user = PFUser()
        user.username = "ENTERUSERNAME"
        user.password = "ENTERPASSWORD"
        user.email = "ENTEREMAILADDRESS@DEMO.NET"
        user["phoneNumber"] = "ENTER-YOUR-PHONE-HERE"
        user["smsVerification"] = false
        user["checking"] = 5000
        user["saving"] = 10000
        let sitekeyImage = UIImage(named: "nexmo.png")
        let imageData = UIImagePNGRepresentation(sitekeyImage!)
        let imageFile = PFFile(name:"nexmo.png", data:imageData!)
        user["sitekey"] = imageFile
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorstring = error.userInfo["error"] as? NSString
                print(errorstring)
            } else {
                print("User signed up.")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.onlineID.delegate = self
        //signUpDemoAccount() //Uncomment to create dummy user
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
