//
//  AppDelegate.swift
//  kidify
//
//  Created by Grail, Christian on 26.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {
    
    var window: UIWindow?
    var session: SPTSession?
    var player: SPTAudioStreamingController?
    let kClientId = "22e68ee4229647f6bbd29ae1628d14e7"
    let kCallbackURL = "kidify://returnAfterLogin"
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SPTAuth.defaultInstance().clientID = kClientId
        SPTAuth.defaultInstance().redirectURL = URL(string:kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Ask SPTAuth if the URL given is a Spotify authentication callback
        
        print("The URL: \(url)")
        if SPTAuth.defaultInstance().canHandle(url) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { error, session in
                // This is the callback that'll be triggered when auth is completed (or fails).
                if error != nil {
                    print("*** Auth error: \(error)")
                    return
                }
                else {
                    SPTAuth.defaultInstance().session = session
                }
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "sessionUpdated"), object: self)
            }
        }
        return false
    }
}
