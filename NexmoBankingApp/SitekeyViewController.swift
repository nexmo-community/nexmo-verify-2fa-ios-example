import Foundation
import UIKit
import Parse
import LocalAuthentication
import VerifyIosSdk

class SitekeyViewController:UIViewController, UITextFieldDelegate {
    
    var sitekey:String!
    let alert = UIAlertView()

    
    @IBAction func signInButton(_ sender: AnyObject) {
        initialWorkFlow()
    }
    
    @IBAction func incorrectKey(_ sender: AnyObject) {
        PFUser.logOut()
        self.performSegue(withIdentifier: "wrongUser", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        PFUser.logOut()
        self.performSegue(withIdentifier: "wrongUser", sender: self)
    }
    
    @IBOutlet weak var pictureKey: UILabel!
    @IBOutlet weak var pictureKeyImage: UIImageView!
    
    func continueWorkflow() {
        if (PFUser.current()!["smsVerification"] as! Bool) {
            self.performSegue(withIdentifier: "verifyPin", sender:self)
        }
        else {
            self.performSegue(withIdentifier: "showAccount", sender:self)
        }
    }
    
    func initialWorkFlow() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.continueWorkflow()
                    }
                    else {
                        let alert = UIAlertController(title: "Failed Identification", message: "Touch ID Authentication Failed. Sign In process stopped.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Continue", style: .default) {
                            UIAlertAction in
                            PFUser.logOut()
                            self.performSegue(withIdentifier: "signInStopped", sender: self)
                        }
                        
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
            })
        }
        else {
            print("Touch ID not available")
            self.continueWorkflow()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let sitekeyImage = PFUser.current()!["sitekey"] as! PFFile
        sitekeyImage.getDataInBackground {
            (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.pictureKeyImage.image = UIImage(data:imageData)
                }
            }
        }
    }
}
