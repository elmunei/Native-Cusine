//
//  SignUpViewController.swift
//  Native Cusine
//
//  Created by Elvis Tapfumanei on 21/11/2017.
//  Copyright © 2017 Elvis Tapfumanei. All rights reserved.
//

import UIKit
import MobileCoreServices
import ProgressHUD
import NotificationBannerSwift
import Firebase


class SignUpViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    //MARK: - Outlets
    @IBOutlet weak var usernameTxt: CustomizableTextfield!{
        didSet{
            usernameTxt.delegate = self
        }
    }
    @IBOutlet weak var emailTxt: CustomizableTextfield!{
        didSet{
            emailTxt.delegate = self
        }
    }
    @IBOutlet weak var passwordTxt: CustomizableTextfield!{
        didSet{
            passwordTxt.delegate = self
        }
    }
    @IBOutlet weak var createAccount: CustomizableButton!
    @IBOutlet weak var cancelBtn: UIButton!

    
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTxt.enablesReturnKeyAutomatically = true
        
        // check notifications if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // declare hide kyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    func performAction() {
        
        ProgressHUD.show("please wait...")
        
        // if fields are empty
        if (emailTxt.text!.isEmpty || usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty ) {
            
            let banner = StatusBarNotificationBanner(title: "One or more fields is empty. Please try again.", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            
            return
        }
        
        if (usernameTxt.text!.count < 4) {
            
            // show alert message
            let banner = StatusBarNotificationBanner(title: "Username cannot be less than 4 characters", style: .danger)
            banner.show()
            ProgressHUD.dismiss()
            
            return
            
        }
        
        // if incorrect email according to regex
        if !validateEmail(emailTxt.text!) {
            // show alert message
            let banner = StatusBarNotificationBanner(title: "Incorrect email format. Please try again.", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            
            return
        }
        
        
        if (passwordTxt.text!.count < 8) {
            
            // show alert message
            let banner = StatusBarNotificationBanner(title: "Password cannot be less than 6 characters", style: .danger)
            banner.show()
            ProgressHUD.dismiss()
            
            return
        }
        
        
        //CODE HERE
        
        
        FUser.registerUserWith(email: emailTxt.text!.trimmingCharacters(in: CharacterSet.whitespaces), password: passwordTxt.text!, fullname: "", username: usernameTxt.text!, location: "", avatar: "", withBlock: { (success) in
            
            if success {
                
                ProgressHUD.dismiss()
                
                //post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : FUser.currentId()])
                
                //Proceed to Home Screen
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                
                self.present(vc, animated: true, completion: nil)
            }
        })
        
        
    }
    

    //MARK: Actions
    
    @IBAction func createAccountBtnPressed(_ sender: AnyObject) {
        
        performAction()
    }
    
    
    // clicked back button
    @IBAction func backBtnClicked(_ sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //Textfield Delegates
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == usernameTxt)
        {
            emailTxt.becomeFirstResponder()
            return true
        }
            
        
        else if (textField == emailTxt)
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
        cancelBtn.isHidden = true
        animateView(up: true, moveValue: 70)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        cancelBtn.isHidden = false
        animateView(up: false, moveValue:
            70)
    }
    
    // hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // hide keyboard func
    @objc func hideKeyboard(_ notification:Notification) {
        
        // move down UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.animateView(up: true, moveValue: 0)
        })
    }
    
    // show keyboard func
    @objc func showKeyboard(_ notification:Notification) {
        
        // define keyboard size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
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
    
    // regex restrictions for email textfield
    func validateEmail (_ email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{3}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }

}
