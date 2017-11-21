//
//  LoginViewController.swift
//  Native Cusine
//
//  Created by Elvis Tapfumanei on 21/11/2017.
//  Copyright © 2017 Elvis Tapfumanei. All rights reserved.
//

import UIKit
import ProgressHUD
import NotificationBannerSwift
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var loginBtn: CustomizableButton!
    
    @IBOutlet weak var emailTxt: CustomizableTextfield!{
        didSet{
            emailTxt.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTxt: CustomizableTextfield!  {
        didSet{
            passwordTxt.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTxt.enablesReturnKeyAutomatically = true
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    func performAction() {
        
        ProgressHUD.show("Please wait...", interaction: false)
        
        // hide keyboard
        self.view.endEditing(true)
        
        // if textfields are empty
        if emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            let banner = StatusBarNotificationBanner(title: "One or more fields have not been filled. Please try again.", style: .danger)
            banner.show()
            
            
            ProgressHUD.dismiss()
            return
        }
        
        let fieldTextLength1 = emailTxt.text!.count
        let fieldTextLength2 = passwordTxt.text!.count
        if  fieldTextLength1 < 4 || fieldTextLength2  < 4 {
            let banner = StatusBarNotificationBanner(title: "Login failed! Wrong password or username.", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            
            return
        }
        
        //CODE HERE
        FUser.loginUserWith(email: emailTxt.text!.trimmingCharacters(in: CharacterSet.whitespaces), password: passwordTxt.text!, withBlock: { (success) in
            
            if success {
                ProgressHUD.dismiss()
                
                self.emailTxt.text = nil
                self.passwordTxt.text = nil
                self.view.endEditing(false)
                
                //Proceed to Home Screen
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                
                self.present(vc, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        performAction()
    }

    
    @IBAction func forgotBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    // clicked back button
    @IBAction func backBtnClicked(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Functions
    
    // hide keyboard func
    @objc func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func hideForgotDetailButton(isHidden: Bool){
        self.forgotBtn.isHidden = isHidden
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if (textField == emailTxt)
        {
            passwordTxt.becomeFirstResponder()
            return true
        }
            
        else if (textField == passwordTxt)
        {
            passwordTxt.resignFirstResponder()
            performAction()
            
            return true
        }
        return false
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
        hideForgotDetailButton(isHidden: true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue: 80)
        hideForgotDetailButton(isHidden: false)
        
    }
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSetNotAllowed = CharacterSet.punctuationCharacters
        if let _ = string.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive) {
            return false
        } else {
            return true
        }
        
    }
    

}
