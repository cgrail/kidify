//
//  ViewController.swift
//  kidify
//
//  Created by Grail, Christian on 26.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit
import WebKit

class LoginController: UIViewController, WebViewControllerDelegate {
    
    @IBOutlet var statusLabel: UILabel!
    
    var authViewController: UIViewController?
    var firstLoad: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        self.statusLabel.text = ""
        self.firstLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        let auth = SPTAuth.defaultInstance()
        // Uncomment to turn off native/SSO/flip-flop login flow
        
        // Check if we have a token at all
        if auth!.session == nil {
            self.statusLabel.text = ""
            return
        }
        // Check if it's still valid
        if auth!.session.isValid() && self.firstLoad {
            // It's still valid, show the player.
            self.showPlayer()
            return
        }
        // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
        self.statusLabel.text = "Token expired."
        if auth!.hasTokenRefreshService {
            self.renewTokenAndShowPlayer()
            return
        }
        // Else, just show login dialog
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getAuthViewController(withURL url: URL) -> UIViewController {
        let webView = WebViewController(url: url)
        webView.delegate = self
        
        return UINavigationController(rootViewController: webView)
    }
    
    @objc func sessionUpdatedNotification(_ notification: Notification) {
        self.statusLabel.text = ""
        let auth = SPTAuth.defaultInstance()
        self.presentedViewController?.dismiss(animated: true, completion: {})
        if auth!.session != nil && auth!.session.isValid() {
            self.statusLabel.text = ""
            self.showPlayer()
        }
        else {
            self.statusLabel.text = "Login failed."
            print("*** Failed to log in")
        }
    }
    
    func showPlayer() {
        self.firstLoad = false
        self.statusLabel.text = "Logged in."
        if let navi = self.navigationController as? NavigationViewController {
            navi.handleNewSession()
        }
        self.performSegue(withIdentifier: "ShowPlaylists", sender: nil)
    }
    
    func openLoginPage() {
        self.statusLabel.text = "Logging in..."
        self.authViewController = self.getAuthViewController(withURL: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
        self.definesPresentationContext = true
        self.present(self.authViewController!, animated: true, completion: {})
    }
    
    func renewTokenAndShowPlayer() {
        self.statusLabel.text = "Refreshing token..."
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
            SPTAuth.defaultInstance().session = session
            if error != nil {
                self.statusLabel.text = "Refreshing token failed."
                return
            }
            self.showPlayer()
        }
    }
    
    func webViewControllerDidFinish(_ controller: WebViewController) {
        self.statusLabel.text = "Authentication aborted"
    }
    
    @IBAction func login(_ sender: Any) {
        self.openLoginPage()
    }
    
}

