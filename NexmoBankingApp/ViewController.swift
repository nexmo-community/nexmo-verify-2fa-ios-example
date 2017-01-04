import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var onlineID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signIn(_ sender: AnyObject) {
        

        PFUser.logInWithUsername(inBackground: onlineID.text!, password:password.text!) {
            (user, error) -> Void in
            if user != nil {
                self.performSegue(withIdentifier: "correctLogin", sender: self)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onlineID.delegate = self
    
        /* signUpDemoAccount() //Uncomment to create dummy user */
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func signUpDemoAccount() {
        var user = PFUser()
        user.username = "ENTERUSERNAME"
        user.password = "ENTERPASSWORD"
        user.email = "ENTEREMAILADDRESS@DEMO.NET"
        user["phoneNumber"] = "ENTER-YOUR-PHONE-HERE"
        user["smsVerification"] = false
        user["checkingAccount"] = 5000
        user["savingAccount"] = 10000
        let sitekeyImage = UIImage(named: "nexmo.png")
        let imageData = UIImagePNGRepresentation(sitekeyImage!)
        let imageFile = PFFile(name:"nexmo.png", data:imageData!)
        user["sitekey"] = imageFile
        user.signUpInBackground {
            (sucess, error) in
            if !(sucess) {
                print(error.debugDescription)
            }
            else {
                print("User signed up.")
            }
        }
    }

}
