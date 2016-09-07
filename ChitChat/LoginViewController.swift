//
//  LoginViewController.swift
//  ChitChat
//
//  Created by Deepak on 06/09/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginDidTouch(sender: AnyObject) {
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (user:FIRUser?, error:NSError?) in
            if error != nil{
                print(error?.description)
            }
            else{
                self.performSegueWithIdentifier("LoginToChat", sender: nil)
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let navController = segue.destinationViewController as? UINavigationController,
            let chatController = navController.viewControllers.first as? ChatViewController else { return }

        chatController.senderId = FIRAuth.auth()?.currentUser?.uid
        chatController.senderDisplayName = FIRAuth.auth()?.currentUser?.displayName ?? ""
    }
}