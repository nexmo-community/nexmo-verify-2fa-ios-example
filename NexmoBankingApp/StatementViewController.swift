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
        PFUser.logOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkingAmount.text = "$\(String(Double(round(100*(PFUser.current()!["checking"] as! Double))/100)))"
        savingAmount.text = "$\(String(Double(round(100*(PFUser.current()!["saving"] as! Double))/100)))"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
    }
}
