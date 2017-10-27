//
//  NavigationViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit
import AVFoundation

class NavigationViewController: UINavigationController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    var isChangingProgress: Bool = false
    let audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateUI() {
        let auth = SPTAuth.defaultInstance()
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            return
        }
        //        self.spinner.startAnimating()
        //        self.nextButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.nextTrack != nil
        //        self.prevButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.prevTrack != nil
        //        self.trackTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.name
        //        self.artistTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.artistName
        //        self.playbackSourceTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceName
        
    }
    
    func handleNewSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            //SPTAudioStreamingController.sharedInstance().delegate = self
            //SPTAudioStreamingController.sharedInstance().playbackDelegate = self
            //SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: SPTAuth.defaultInstance().session.accessToken!)
        } catch let error {
            self.closeSession()
        }
    }
    
    func closeSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
        } catch let error {
            
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        if isPlaying {
            self.activateAudioSession()
        }
        else {
            self.deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent, withName name: String) {
        print("didReceivePlaybackEvent: \(event) \(name)")
        print("isPlaying=\(SPTAudioStreamingController.sharedInstance().playbackState.isPlaying) isRepeating=\(SPTAudioStreamingController.sharedInstance().playbackState.isRepeating) isShuffling=\(SPTAudioStreamingController.sharedInstance().playbackState.isShuffling) isActiveDevice=\(SPTAudioStreamingController.sharedInstance().playbackState.isActiveDevice) positionMs=\(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        if self.isChangingProgress {
            return
        }
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack {
            let positionDouble = Double(position)
            let durationDouble = Double(currentTrack.duration)
            //self.progressSlider.value = Float(positionDouble / durationDouble)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finishing: \(trackUri)")
    }
    
    func activateAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}
