//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate  {

    @IBOutlet var cover: UIImageView!
    @IBOutlet var artist: UILabel!
    @IBOutlet var trackTitle: UILabel!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var navLabel: UINavigationItem!
    
    public var album: Album?
    
    var isChangingProgress: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        
        if let track = album?.currentlyPlayed {
            var currentlyPlayingSelectedTrack = false
            if let metadata = SPTAudioStreamingController.sharedInstance().metadata,
                let currentTrack = metadata.currentTrack {
                if (currentTrack.uri == track.uri.absoluteString) {
                    currentlyPlayingSelectedTrack = true
                }
            }
            if (!currentlyPlayingSelectedTrack) {
                playTrack(track: track)
            } else {
                self.updateUI()
            }
            if let album = album {
                self.navLabel.title = album.name
            }
        }
    }
    
    func updateUI() {
        updateControlButtons()
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            return
        }
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack,
            let album = album{
            self.artist.text = currentTrack.artistName
            let currentTrackNo = album.tracks.index(of: album.currentlyPlayed!)! + 1
            self.trackTitle.text = String(format: "%@ (%d/%d)", currentTrack.name, currentTrackNo, album.tracks.count)
            updateCover(currentTrack)
        }
    }
    
    func updateCover(_ currentTrack: SPTPlaybackTrack) {
        let auth = SPTAuth.defaultInstance()!
        SPTTrack.track(withURI: URL(string: currentTrack.uri)!, accessToken: auth.session.accessToken, market: nil) { error, result in
            
            if let track = result as? SPTTrack {
                guard let album = track.album,
                    let largestCover = album.largestCover
                else {
                    self.cover.image = nil
                    return
                }
                let imageURL = largestCover.imageURL
                if imageURL == nil {
                    print("Album \(track.album) doesn't have any images!")
                    self.cover.image = nil
                    return
                }
                DispatchQueue.global().async {
                    do {
                        let imageData = try Data(contentsOf: imageURL!, options: [])
                        let image = UIImage(data: imageData)
                        // …and back to the main queue to display the image.
                        DispatchQueue.main.async {
                            self.cover.image = image
                            if image == nil {
                                print("Couldn't load cover image with error: \(String(describing: error))")
                                return
                            }
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        self.updateControlButtons()
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
        if let currentTrack = album?.currentlyPlayed {
            currentTrack.played = true
            self.album?.partlyFinished = true
        }
        self.playNext("")
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
        self.updateControlButtons()
    }
    
    private func getNavigationViewController() -> NavigationViewController {
        return self.navigationController as! NavigationViewController
    }
    
    private func playTrack(track:Track) {
        album?.currentlyPlayed = track
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(track.uri.absoluteString, startingWith: 0, startingWithPosition: 0) { error in
            if (error != nil) {
                debugPrint("Playback error" + String(describing: error))
            }
        }
    }
    
    
    @IBAction func play(_ sender: Any) {
        self.setPlayStatus(playing: true)
    }
    @IBAction func pause(_ sender: Any) {
        self.setPlayStatus(playing: false)
    }
    
    private func setPlayStatus(playing: Bool) {
        if let player = SPTAudioStreamingController.sharedInstance() {
            player.setIsPlaying(playing, callback: nil)
            self.updateControlButtons(playing)
        }
    }
    
    private func updateControlButtons() {
        if let player = SPTAudioStreamingController.sharedInstance() {
            self.updateControlButtons(player.playbackState.isPlaying)
        }
    }
    
    private let activeColor = UIColor.white
    private let disabledColor = UIColor.darkGray
    
    private func updateControlButtons(_ playing: Bool) {
        playButton.isHidden = playing
        pauseButton.isHidden = !playing
        
        if let album = album,
            let index = album.tracks.index(of: album.currentlyPlayed!){
            prevButton.titleLabel?.textColor = index == 0 ? disabledColor : activeColor
            nextButton.titleLabel?.textColor = (index+1) == album.tracks.count ? disabledColor : activeColor
        }
    }
    
    @IBAction func playPrevious(_ sender: Any) {
        if let album = album,
            let index = album.tracks.index(of: album.currentlyPlayed!) {
            self.playTrackByIndex(index - 1)
        }
    }
    @IBAction func playNext(_ sender: Any) {
        if let album = album,
            let index = album.tracks.index(of: album.currentlyPlayed!) {
            self.playTrackByIndex(index + 1)
        }
    }
    
    private func playTrackByIndex(_ index: Int) {
        guard let album = album else {
            return
        }
        var newIndex = index
        if (newIndex < 0) {
            newIndex = 0
        }
        if ((newIndex+1) > album.tracks.count) {
            newIndex = album.tracks.count - 1
        }
        self.playTrack(track: album.tracks[newIndex])
    }
    
    @IBAction func jumpToPosition(_ sender: UISlider) {
        if let currentTrack = SPTAudioStreamingController.sharedInstance().metadata.currentTrack {
            let position = sender.value * Float(currentTrack.duration)
            SPTAudioStreamingController.sharedInstance().seek(to: Double(position), callback: nil)
        }
    }

}
