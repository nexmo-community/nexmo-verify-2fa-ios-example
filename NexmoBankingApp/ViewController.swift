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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onlineID.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
