//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate  {

    @IBOutlet var artist: UILabel!
    @IBOutlet var trackTitle: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    public var currentTrack: SPTPartialTrack?
    
    public var tracks = [SPTPartialTrack]()
    
    var isChangingProgress: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        //SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
        
        
        if let track = currentTrack {
            playTrack(track: track)
        }
    }
    
    func updateUI() {
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            return
        }
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack{
            self.artist.text = currentTrack.artistName
            self.trackTitle.text = currentTrack.name
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        if self.isChangingProgress {
            return
        }
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack {
            let positionDouble = Double(position)
            let durationDouble = Double(currentTrack.duration)
            self.progressSlider.value = Float(positionDouble / durationDouble)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        var reachedLastSong = false
        for track in tracks {
            if(reachedLastSong) {
                playTrack(track: track)
                return
            }
            if(track.uri.absoluteString == trackUri) {
                reachedLastSong = true
            }
        }
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
    }
    
    private func getNavigationViewController() -> NavigationViewController {
        return self.navigationController as! NavigationViewController
    }
    
    private func playTrack(track:SPTPartialTrack) {
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(track.uri.absoluteString, startingWith: 0, startingWithPosition: 0) { error in
            if (error != nil) {
                debugPrint("Playback error" + String(describing: error))
            }
        }
    }

    @IBAction func jumpToPosition(_ sender: UISlider) {
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack {
            let position = sender.value * Float(currentTrack.duration)
            SPTAudioStreamingController.sharedInstance().seek(to: Double(position), callback: nil)
        }
    }

}
