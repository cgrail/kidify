//
//  NavigationViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit
import AVFoundation

class NavigationViewController: UINavigationController{

    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func handleNewSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: SPTAuth.defaultInstance().session.accessToken!)
        } catch let error {
            print("didReceiveError: \(error.localizedDescription)")
        }
    }
    
}
