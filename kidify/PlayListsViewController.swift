//
//  PlayListsViewController.swift
//  kidify
//
//  Created by Grail, Christian on 26.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class PlayListsViewController: UITableViewController {
    
    var playlists = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSpotifyPlaylists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PlaylistTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaylistTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PlaylistTableViewCell.")
        }
        
        let playlist = playlists[indexPath.row]
        cell.label.text = playlist
        
        return cell
    }
    
    private func getSpotifyPlaylists() {
        
        let session = SPTAuth.defaultInstance().session
        
        let playlistRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        
        SPTRequest.sharedHandler().perform(playlistRequest) { [weak self] (error, response, data) in
            let list = try! SPTPlaylistList(from: data, with: response)
            
            for playList in list.items  {
                if let playlist = playList as? SPTPartialPlaylist {
                    self?.playlists.append(playlist.name)
                    
                    let stringFromUrl =  playlist.uri.absoluteString
                    let uri = URL(string: stringFromUrl)
                    
                    SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: session?.accessToken) { (error, snap) in
                        if let s = snap as? SPTPlaylistSnapshot {
                            
                            
                            for track in s.firstTrackPage.items {
                                if let thistrack = track as? SPTPlaylistTrack {
                                    debugPrint(thistrack.album.name)
                                }
                            }
                        }
                    }
                }
            }
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
}
