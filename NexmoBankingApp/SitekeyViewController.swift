import Foundation
import UIKit
import Parse

class SitekeyViewController:UIViewController, UITextFieldDelegate {
    
    var sitekey:String!
    let alert = UIAlertView()
    var user_verified : Bool!
    
    @IBAction func signInButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showAccount", sender: self)
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
