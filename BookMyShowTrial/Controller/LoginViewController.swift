//
//  LoginViewController.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 29/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

/*
Note: View Hierarchy
 In the view We have 2 buttons 'sign in with G+' and 'Continue with currently signedIN user'
 For the first time of Applaunch only one button is visible, 'sign in with G+'
 For the next time onwards both buttons will be visible, So if user want to sign in with diffrent Account then by clicking on 1st button He/She will be signed out and
 will be asked to signIn with diffrent account
*/
import UIKit
import GoogleSignIn
//GoogleSignIn: For sign in with google

class LoginViewController: UIViewController, GIDSignInUIDelegate,GIDSignInDelegate {

    //MARK: signInButton is the main button for logIN
    @IBOutlet weak var signInButton: GIDSignInButton!{
        didSet{
            signInButton.layer.cornerRadius = 8.0
            signInButton.clipsToBounds = true
        }
    }
    
    //MARK: SignInAction
    @IBAction func SignInAction(_ sender: UIButton) {
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            GIDSignIn.sharedInstance().signOut()
        }
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: continueSignInButton for countinue with current logIn
    @IBOutlet weak var continueSignInButton: UIButton!{
        didSet{
            continueSignInButton.layer.cornerRadius = 8.0
            continueSignInButton.clipsToBounds = true
        }
    }
    
    //MARK: countinueSignInAction
    @IBAction func countinueSignInAction(_ sender: UIButton) {
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: secondViewController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: GoogleSignIn SDK configurations
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = Google_Sign_In_Client_Id
        GIDSignIn.sharedInstance().delegate = self
        
        //Google SDK have GIDSignIn.sharedInstance()?.hasAuthInKeychain() method for any Logged In user
        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false{
            self.continueSignInButton.isHidden = false
            self.continueSignInButton.setTitle("Continue as Current Login",for: .normal)
        }else{
            self.continueSignInButton.isHidden = true
        }
    }
    
    //MARK: GoogleSignIn open url: Dont edit below method
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    //MARK: SignIn main method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            //Show an Alert and tell to continue signin
            self.showAlert("Some Error Accured")
            
        } else {
            //Sign In done successfully, write code below for using loggedIn user's data
            SIGNEDIN_USER_EMAIL = user.profile.email
            //After succesfully logIn the User will be redirected to Home Screen
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: secondViewController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    //MARK: didDisconnectWith
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        //Log Out for the timming
        GIDSignIn.sharedInstance().signOut()
    }
    
    //MARK: showAlert
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
