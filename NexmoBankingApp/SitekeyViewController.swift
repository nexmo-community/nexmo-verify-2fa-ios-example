import Foundation
import UIKit
import Parse

class SitekeyViewController:UIViewController, UITextFieldDelegate {
    
    var sitekey:String!
    let alert = UIAlertView()
    var user_verified : Bool!
    
    @IBAction func signInButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showAccount", sender: self)
    }
    
    @IBAction func incorrectKey(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("wrongUser", sender: self)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("wrongUser", sender: self)
    }
    
    @IBOutlet weak var pictureKey: UILabel!
    @IBOutlet weak var pictureKeyImage: UIImageView!
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let sitekeyImage = PFUser.currentUser()!["sitekey"] as! PFFile
        sitekeyImage.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.pictureKeyImage.image = UIImage(data:imageData)
                }
            }
        }
    }
}