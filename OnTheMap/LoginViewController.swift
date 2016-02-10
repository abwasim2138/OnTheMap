//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/4/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var login: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        passWord.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        userName.text = ""
        passWord.text = ""
    }
    //MARK: UIACTIONS 
    
    @IBAction func login(sender: UIButton) {
        guard let username = userName.text where username != "", let password = passWord.text where password != "" else {
            alertUser("Missing Username/Password")
            return
        }
        login.setTitle("Loading....", forState: .Normal)
        UIView.animateWithDuration(0.4) { () -> Void in
        self.login.alpha = 0.5
            }
        self.login.alpha = 1.0
        APIClient.login(username, password: password) {JSONResult,error in
            if let results = JSONResult as? NSDictionary {
                if let account = results["account"] {
                    if let account = account["key"] as? String {
                    APIClient.getAccountData(account, completionHandler: { (result, error) -> Void in
                        if let userAccount = result["user"] as? NSDictionary {
                            StudentCollection.studentCollection.myAccount = userAccount
                        }
                    })
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                     self.login.setTitle("Login", forState: .Normal)
                     self.performSegueWithIdentifier("login", sender: self)
                    })
                    }
                }else{
                    self.alertUser("INVALID USERNAME AND/OR PASSWORD")
                    self.login.setTitle("Login", forState: .Normal)
                }
            }else{
                self.alertUser(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    //MARK: METHODS
    
    func alertUser(title: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okayAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }



}

