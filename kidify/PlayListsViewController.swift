//
//  PlayListsViewController.swift
//  kidify
//
//  Created by Grail, Christian on 26.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class PlayListsViewController: UITableViewController {
    
    var playlists = [Playlist]()
    
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
        cell.label.text = playlist.name
        
        return cell
    }
    
    private func getSpotifyPlaylists() {
        
        let session = SPTAuth.defaultInstance().session
        
        let playlistRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        
        SPTRequest.sharedHandler().perform(playlistRequest) { [weak self] (error, response, data) in
            let list = try! SPTPlaylistList(from: data, with: response)
            
            for playList in list.items  {
                if let playlist = playList as? SPTPartialPlaylist {
                    
                    let playlistVO = Playlist(name: playlist.name)
                    
                    self?.playlists.append(playlistVO)
                    
                    let stringFromUrl =  playlist.uri.absoluteString
                    let uri = URL(string: stringFromUrl)
                    
                    SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: session?.accessToken) { (error, snap) in
                        if let s = snap as? SPTPlaylistSnapshot {
                            
                            
                            for track in s.firstTrackPage.items {
                                if let thistrack = track as? SPTPlaylistTrack {
                                    let albumVo = Album(name: thistrack.album.name)
                                    if(playlistVO.albums.contains(albumVo)){
                                        continue
                                    }
                                    playlistVO.albums.insert(albumVo)
                                    
                                    SPTAlbum.album(withURI: thistrack.album.uri, accessToken: session?.accessToken, market: nil)  { (error, albumResponse) in
                                        if let album = albumResponse as? SPTAlbum {
                                            if let trackPage = album.firstTrackPage {
                                                for albumTrack in trackPage.items {
                                                    if let t = albumTrack as? SPTPartialTrack {
                                                        albumVo.tracks.append(t)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
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
        
        switch(segue.identifier ?? "") {
        case "ShowAlbums":
            guard let albumsControlelr = segue.destination as? AlbumsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPlaylist = sender as? PlaylistTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPlaylist) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let playlist = playlists[indexPath.row]
            albumsControlelr.albums = Array(playlist.albums)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
}
