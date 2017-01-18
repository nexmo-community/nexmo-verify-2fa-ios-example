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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
