//
//  LoginViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 29/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate,GIDSignInDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!{
        didSet{
            signInButton.layer.cornerRadius = 8.0
            signInButton.clipsToBounds = true
        }
    }
    
    @IBAction func SignInAction(_ sender: UIButton) {
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            GIDSignIn.sharedInstance().signOut()
        }
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBOutlet weak var continueSignInButton: UIButton!{
        didSet{
            continueSignInButton.layer.cornerRadius = 8.0
            continueSignInButton.clipsToBounds = true
        }
    }
    @IBAction func countinueSignInAction(_ sender: UIButton) {
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: secondViewController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "615844827053-mvj0quhaojq90ee7g00innj565bf5feg.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            self.continueSignInButton.isHidden = false
            self.continueSignInButton.setTitle("Continue as Current Login",for: .normal)
        }else{
            self.continueSignInButton.isHidden = true
        }

        // Do any additional setup after loading the view.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            //Show an Alert and tell to continue signin
            self.showAlert("Some Error Accured")
            
        } else {
            SIGNEDIN_USER_EMAIL = user.profile.email
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: secondViewController)
            self.present(navigationController, animated: true, completion: nil)
            
            //Here perform the segue to Home Page
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        //Log Out for the timming
        GIDSignIn.sharedInstance().signOut()
    }
    
    func showAlert(_ message: String) -> (){
        let alert = UIAlertController(title: message, message: nil , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { _ in
            GIDSignIn.sharedInstance().signIn()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //do nothing
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
