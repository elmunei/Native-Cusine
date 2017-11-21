//
//  ResetPasswordViewController.swift
//  Native Cusine
//
//  Created by Elvis Tapfumanei on 21/11/2017.
//  Copyright © 2017 Elvis Tapfumanei. All rights reserved.
//

import UIKit
import ProgressHUD
import NotificationBannerSwift
import Firebase

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resetPwd: CustomizableTextfield!{
        didSet{
            resetPwd.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetPwd.enablesReturnKeyAutomatically = true
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    // hide keyboard func
    @objc func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    

    @IBAction func resetBtn(_ sender: Any) {
        performAction()
    }
    
    func performAction() {
        ProgressHUD.show()
        
        // if fields are empty
        if (resetPwd.text!.isEmpty) {
            
            let banner = StatusBarNotificationBanner(title: "Email address field cannot be empty. Please try again.", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            
            return
        }
        
        // if incorrect email according to regex
        if !validateEmail(resetPwd.text!) {
            // show alert message
            let banner = StatusBarNotificationBanner(title: "Incorrect email format. Please try again.", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            
            return
        }
        
        
        Auth.auth().sendPasswordReset(withEmail: resetPwd.text!.trimmingCharacters(in: CharacterSet.whitespaces)) { (error) in
            
            let databaseReff = Database.database().reference().child("User")
            
            databaseReff.queryOrdered(byChild: "email").queryEqual(toValue: self.resetPwd.text!).observe(.value, with: { snapshot in
                if snapshot.exists(){
                 
                        
                        let alertController = UIAlertController(title: "Success", message: "A reset password link has been sent to \(String(describing: self.resetPwd.text!))", preferredStyle: .alert)
                        
                        let okay = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            self.resetPwd.text = ""
                            ProgressHUD.dismiss()
                            self.view.endEditing(true)
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alertController.addAction(okay)
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                        
                        
                        
                    } else {
                        
                        let banner = StatusBarNotificationBanner(title: error!.localizedDescription, style: .danger)
                        banner.show()
                        
                        ProgressHUD.dismiss()
                    }
           
            })
        
    }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        self.resetPwd.text = ""
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == resetPwd)
        {
            
            resetPwd.resignFirstResponder()
            performAction()
            return true
        }
        
        
        return false
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
        
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue:
            80)
        
        
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
