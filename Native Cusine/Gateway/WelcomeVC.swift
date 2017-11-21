//
//  ViewController.swift
//  Native Cusine
//
//  Created by Elvis Tapfumanei on 21/11/2017.
//  Copyright © 2017 Elvis Tapfumanei. All rights reserved.
//

import UIKit
import Firebase

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { auth, user in
            
            if user != nil {
                
                if userDefaults.object(forKey: kCURRENTUSER) != nil {
                    
                    DispatchQueue.main.async {
                        
                        //Proceed to Home Screen
                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
            } else {
                print("User is signed out.")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

