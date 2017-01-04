#Adding Phone (SMS/TTS) & Biometric Verification to your iOS application

Two Factor Authentication adds an extra layer of security for users that are accessing sensitive information. There are multiple types of 2 Factor Authentication such as:

1) Something you know (username, password)
2) Something you have (your phone/SIM)
3) Something you are (Biometric Fingerprint or Retina Scan).

In this tutorial we’ll cover how you can add all three of these to an iOS application using the [Nexmo Verify SDK] (https://cocoapods.org/pods/NexmoVerify).

##Getting Started

Using the SDK will allow you to add an extra layer of security by ensuring the user is tied to a specific physical device by capturing the Device ID and a SMS/TTS pin code. This reduces spam/fraud to certify the user is logging in from the same device as the previous login attempt.

We will be using a starter app that uses [Back4App](https://www.back4app.com/) backend for the user login (something you know). The Verify SDK will be used for our 2FA solution through SMS and TTS, and Apple’s Touch ID will be used for biometric verification (something you are).

###Get your Back{4}App database set up

Back{4}App is a backend that lets you build and host Parse apps (which is handy since Parse closed down). If you do not have an existing Back{4}App account, sign up and create an application.

You'll then be presented with a page showing you your new application credentials. Take a note of your Application ID and Client Key since we'll need those later. Close the dialog and go to the "Parse Dashboard". In the view that you are then presented with (see below), select the "User" class and add the following columns:
 'checking' (Number)
 'saving' (Number)
 'sitekey' (File - image for users)
 phoneNumber (string)
‘smsVerification’ (Boolean value that will allow users to enable SMS verification on login).

Now that Back{4} apps is setup,  we can look at getting our starter application in place.

###Get the starter app

Let’s get started by getting the starter app from GitHub. In your Terminal, run the following:

```sh
git clone https://github.com/nexmo-community/nexmo-verify-2fa-ios-example.git -b getting-started
cd nexmo-verify-2fa-ios-example
```
The repo has a getting-started (pre-2FA) branch which allow you to follow the tutorial blow and a master branch which contains the final version of this tutorial.
Open the `NexmoBankingApp.xcproj` in XCode. Select "NexmoBankingApp" to open your app settings, and update the project’s "Bundle Identifier" to a valid identifier and app name registered Apple's Developer Portal. Add your Back4App Application ID and Client Key in `AppDelegate.swift`.

```
let configuration = ParseClientConfiguration {
     $0.applicationId = "BACK4APP_APP_ID"
     $0.clientKey = "BACK4APP_CLIENT_KEY"
     $0.server = "https://parseapi.back4app.com"
}
Parse.initializeWithConfiguration(configuration)
```

Once entered, head on over to 'ViewController.swift' and add a dummy user to the database by uncommenting the 'signUpDemoAccount()' function call in the 'viewDidLoad()' method in 'ViewController.swift':

```
override func viewDidLoad() {
  super.viewDidLoad()
  self.onlineID.delegate = self
  signUpDemoAccount() //Uncomment to create dummy user
}
```
Update the PFUser's username, password, email, and phoneNumber fields in the 'signUpDemoAccount()' function.

```
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
    user.signUpInBackgroundWithBlock {
        (success, error) -> Void in
        if !sucess {
           print(error.debugDescription)
        } else {
            print("User signed up.")
        }
    }
}
```
Run the app and the PFUser will be created and will populate the Back4App dashboard. Since we don’t want to create another user when we start the app again, you should comment out the 'signUpDemoAccount()' function call in the 'viewDidLoad()' method after you run the app the first time.


Go ahead and run the app again. You will be able to access the user's account information by entering the credentials of the newly created user.
Ok, now let's beef up the security in the app and add 2FA.

###Setting Up Your Nexmo App

Sign up for a Nexmo account and go to your customer dashboard. Click on the Verify tab and add a new application under 'Your Apps'. Setup your app with a name, idle time of Instant (maximum length of time the user will stay verified - in this case users will expire immediately), and pin code length.

Next, let's add the Nexmo Verify SDK. The Verify SDK can be easily added to your project using Cocoapods. Create a Podfile in your project directory, add the ‘NexmoVerify’ pod inside the file, and install the pod via Terminal. (If the pod cannot be found, run pod update to update Cocoapods.)
```sh
    pod init
    open Podfile
```
```
# Inside Podfile
# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
target 'NexmoBankingApp' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for NexmoBankingApp
  pod ‘NexmoVerify’
end
```
```sh
    pod install
```
Once the pod installation has completed, you are ready to dive into the code! To start working with the Verify SDK, import ‘NexmoVerify’ in your file.

##Diving into Code

Now that we have our dependencies in place and attained the Nexmo app credentials, it's time to add them to your 'AppDelegate' file.

In AppDelegate.swift:
```swift
fileprivate var appID = "YOUR_NEXMO_APP_ID"
fileprivate var sharedSecret = "YOUR_NEXMO_SHARED_SECRET"
```

###Initialize Nexmo Client

Initialize the Nexmo Client inside the ‘didFinishLaunchingWithOptions’ function of the ‘AppDelegate’ file. Make sure not to commit any private keys or application ids (if you are publishing your apps on GitHub).
```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
           let configuration = ParseClientConfiguration {
   	   $0.applicationId = "BACK4APP_APP_ID"
	   $0.clientKey = "BACK4APP_CLIENT_KEY"
	   $0.server = "https://parseapi.back4app.com"
           }
          Parse.initializeWithConfiguration(configuration)
          NexmoClient.start(applicationId: appID, sharedSecretKey: sharedSecret)
          return true
      }
```

###Add biometric verification to the SitekeyViewController

On successful login, by providing Back4Apps with the username and password combination, the second screen takes the user to their sitekey verification where we will be adding biometric Touch ID verification.

Let's handle the user pressing the sign in button and use Apple's LocalAuthentication API to prompt a Touch ID verification. If the device is not compatible with Touch ID (no fingerprint reader), using user skips the biometric verification. Add a segue ('signInStopped'), for if the user is unable to successfully pass the Touch ID verification, which logs the user out and returns them to the login page. Based on if the user’s SMS verification preference setting, the continue workflow function will trigger a verification request after segueing to the pin verification screen (which we create next) or show the user’s account page.
You can see the code already written in the `SiteKeyViewController.swift`:
```swift
@IBAction func signInButton(_ sender: AnyObject) {
    initialWorkFlow()
}
func initialWorkFlow() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.continueWorkflow()
                    }
            else {
                let alert = UIAlertController(title: "Failed Identification", message: "Touch ID Authentication Failed. Sign In process stopped.", preferredStyle: .Alert)
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
func continueWorkflow() {
    if (PFUser.current()?["smsVerification"] as! Bool) {
        self.performSegue(withIdentifier: "verifyPin", sender: self)
    }
    else {
        self.performSegue(withIdentifier: "showAccount", sender: self)
    }
}
```

###Add View Controller for verification & add 2FA logic to the VC

Add a view controller to your project (‘VerifyPinViewController’) and create a view controller in the Storyboard using the Interface Builder.  Next, add a text box outlet along with a button outlet to submit the pin code. Create a segue (‘verifyPin’) that is connected to the 'SitekeyViewController' & the newly created view controller.

Inside the ‘viewDidAppear’ method of the newly added view controller, call the function below.
```swift
   override func viewDidAppear(animated: Bool) {
           super.viewDidAppear(true)
           let alert = UIAlertController(  title: "User Phone Verification", message: "Your identity is being verified.", preferredStyle: .alert)
           let defaultAction = UIAlertAction(title: "Continue", style: .default) {
               UIAlertAction in
               self.verifyUser()
           }
           alert.addAction(defaultAction)
           present(alert, animated: true, completion: nil)
       }
```

Grab the user’s phone number from the Back4Apps database and trigger a verification request using the getVerifiedUser() method.
```swift
   func verifyUser() {
               VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.currentUser()?["phoneNumber"] as! String,
                   onVerifyInProgress: {
                   },
                   onUserVerified: {
                       self.performSegueWithIdentifier("pinVerified", sender: self)
                   },
                   onError: { verifyError in
                       switch (verifyError) {
                           case .invalidPinCode:
                               UIAlertView(title: "Wrong Pin Code", message: "The pin code you entered is invalid.", delegate: nil, cancelButtonTitle: "Try again!").show()
                           case .invalidCodeTooManyTimes:
                               let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .alert)
                               let defaultAction = UIAlertAction(title: "Goodbye", style: .default) {
                                   UIAlertAction in

                                VerifyClient.cancelVerification() { error in
                                    if let error = error {
                                        // something wen't wrong whilst attempting to cancel the current verification request
                                        return
                                    }
                                }
                                self.performSegue(withIdentifier: "logout", sender: self)
                            }
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        default:
                            print(verifyError.rawValue)
                            break
                        }
                })
        }
   }
```

Also, call the ‘checkPinCode’ method provided by the Nexmo client when the button is pressed to verify the pin provided by the user.

```
   @IBAction func verifyButton(sender: AnyObject) {
           if pinCode.text!.isEmpty {
             let alert = UIAlertController(title: "Enter Pin Code", message: "Please check your phone and enter the pin code send via SMS.", preferredStyle: .alert)
             let defaultAction = UIAlertAction(title: "Back", style: .default, handler: nil)
             alert.addAction(defaultAction)
             present(alert, animated: true, completion: nil)
       }
       else {
             VerifyClient.checkPinCode(pinCode.text!)
        }
    }
```
###Add option for SMS verification on login

Next, add the logic that allows the user to enable SMS verification. Add a switch UI element to your ‘StatementViewController.swift’. Also, add a Boolean variable to hold the value of the switch. When the user logs out of the account, the value of the switch is stored in the database. If the switch was toggled on, a SMS verification will be triggered on the next login. After the view appears, check the values for the checking and savings account to validate they are not nil.
```swift
   @IBOutlet weak var switch2FA: UISwitch!
   var switchBoolValue:Bool!
   func logout() {
               if PFUser.currentUser() != nil {
                   let alert = UIAlertController(title: "SMS Verification", message: "Perform SMS verification on login?", preferredStyle: .alert)
                   let defaultAction = UIAlertAction(title: "Continue", style: .default) {
                       UIAlertAction in
                      PFUser.current()?["smsVerification"] = true
                      PFUser.current()?.saveInBackground()
                      self.performSegue(WithIdentifier: "logoutUser", sender: self)
                   }
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               alert.addAction(defaultAction)
               alert.addAction(cancelAction)
               self.present(alert, animated: true, completion: nil)
         }
         else {
              print("SMS FALSE successful logout")
              PFUser.current()?["smsVerification"] = false
              PFUser.current()?.saveInBackground()
              self.performSegue(withIdentifier: "logoutUser", sender: self)
        }
    }

   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if (PFUser.current()?["saving"] == nil || PFUser.current()?["checking"] == nil) {
            PFUser.logOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        else {
            checkingAmount.text = "$\(String(Double(round(100*(PFUser.current()?["checking"] as! Double))/100)))"
            savingAmount.text = "$\(String(Double(round(100*(PFUser.current()?["saving"] as! Double))/100)))"
            switch2FA.addTarget(self, action: #selector(StatementViewController.switchMoved), for: UIControlEvents.valueChanged)
            switchBoolValue = true
        }
    }

    func switchMoved() { // stores value for the switch
        if switch2FA.isOn {
            switchBoolValue = true
            print("switch on")
        }
        else {
            switchBoolValue = false
            print("switch off")
        }
    }
```

###Perform 2FA on verified user on specific action

For more secure transaction, such as a user transferring from one account to another, you can trigger a verification request to confirm the user request action. Using the ‘getVerifiedUser’ method, the user will receive an pin code via SMS. Add a new controller ('TransferPinViewController') with a text field and a button in the storyboard file. Create an IBOutlet for the user supplied pin code (text field) and an IBAction for the Verify button.

Create a function that calls ‘getVerifiedUser’ method to initiate the user verification. This function should be called when the view loads.
```swift
override func viewDidLoad() {
      super.viewDidLoad()
      verify()
}
 func verify() {
    VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: PFUser.current()?["phoneNumber"] as! String,
        onVerifyInProgress: {
        },
        onUserVerified: {
            self.performTransfer()
        },
        onError: { verifyError in
            switch (verifyError) {
                case .invalidPinCode:
                    UIAlertView(title: "Wrong Pin Code", message: "The pin code you entered is invalid.", delegate: nil, cancelButtonTitle: "Try again!").show()
                case .invalidCodeTooManyTimes:
                    let alert = UIAlertController(title: "Unsucessful Identification", message: "Logging out. Goodbye.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Goodbye", style: .default) {
                        UIAlertAction in
                            VerifyClient.cancelVerification() { error in
                               if let error = error {
                                   // something wen't wrong whilst attempting to cancel the current verification request
                                    return
                                }
                            }
                            self.performSegue(withIdentifier: "logout", sender: self)
                     }
                     alert.addAction(defaultAction)
                     self.present(alert, animated: true, completion: nil)
                     default:
                        print(verifyError.rawValue)
                        break
                    }
            })
}
```

As shown above, call the function 'performTransfer' inside the 'onUserVerified' callback method. As we did in the previous verification view controller, call the 'checkPinCode' method inside your IBAction button to check the provided pin from the user.
```Swift
   @IBOutlet weak var pincode: UITextField!
   @IBAction func checkPin(sender: AnyObject) {
           VerifyClient.checkPinCode(pincode.text!)
    }
   func performTransfer() {
           if transferSource == "checkingToSaving" {
               checkingAmount =  checkingAmount - transferAmt
               savingAmount = savingAmount + transferAmt
               PFUser.current()?["checking"] = checkingAmount
               PFUser.current()?["saving"] = savingAmount
               PFUser.current()?.saveInBackground()
               OperationQueue.main.addOperationWithBlock {
                   self.performSegue(withIdentifier: "successfulTransfer", sender: self)
               }
           }
           else if transferSource == "savingToChecking"{
               savingAmount = savingAmount - transferAmt
              checkingAmount =  checkingAmount + transferAmt
               PFUser.current()?["saving"] = savingAmount
               PFUser.current()?.saveInBackground()
               PFUser.current()?["checking"] = checkingAmount
               PFUser.current()?.saveInBackground()
               OperationQueue.main.addOperationWithBlock {
                   self.performSegue(withIdentifier: "successfulTransfer", sender: self)
               }
           }
       }
```

That is all you need to do to enable 2 Factor Authentication in your iOS app using Nexmo’s Verify SDK. Nowadays, enabling 2FA is a must for sensitive information to ensure proper user identification. Through this tutorial, we secured the demo application with all three methods of authentication. Using their username and password combo, we ensured something they know (their login credentials). By implementing Nexmo’s Verify iOS SDK, we ensured we verified something the user has (access to their phone by capturing the user’s device ID & IP address). Adding Apple’s Touch ID ensured something the user is (themselves using biometric verification). The process of adding 2FA is simple using the Verify SDK and Apple’s Local Authentication API but adds an extra layer of security that protects your user’s sensitive information.

 Feel free to send me your thoughts or questions @sidsharma_27
