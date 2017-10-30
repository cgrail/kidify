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
        SPTRequest.sharedHandler().perform(playlistRequest) { (error, response, data) in
            let list = try! SPTPlaylistList(from: data, with: response)
            for playList in list.items  {
                if let playlist = playList as? SPTPartialPlaylist {
                    if let uri = URL(string: playlist.uri.absoluteString){
                        self.loadPlaylist(uri)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func loadPlaylist(_ uri: URL) {
        SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: getAccessToken()) { (error, response) in
            if let playlist = response as? SPTPlaylistSnapshot {
                let playlistVO = Playlist(name: playlist.name)
                self.playlists.append(playlistVO)
                self.handlePlaylist(playlist.firstTrackPage, playList: playlistVO)
            }
        }
    }
    
    func handlePlaylist(_ currentPage: SPTListPage, playList: Playlist) {
        guard let items = currentPage.items else {
            return
        }
        for item in items {
            if let track = item as? SPTPlaylistTrack {
                handleTrack(track: track, playList: playList)
            }
        }
        if(currentPage.hasNextPage) {
            currentPage.requestNextPage(withAccessToken: getAccessToken()) { (error, response) in
                if let page = response as? SPTListPage {
                    self.handlePlaylist(page, playList: playList)
                }
            }
        }
        
    }
    
    func handleTrack(track: SPTPlaylistTrack, playList: Playlist) {
        let albumVo = Album(name: track.album.name)
        if(playList.albums.contains(albumVo)){
            return
        }
        playList.albums.insert(albumVo)
        
        SPTAlbum.album(withURI: track.album.uri, accessToken: getAccessToken(), market: nil)  { (error, albumResponse) in
            guard let album = albumResponse as? SPTAlbum  else {
                return
            }
            guard let trackPage = album.firstTrackPage else {
                return
            }
            guard let albumTracks = trackPage.items else {
                return
            }
            for albumTrack in albumTracks {
                if let track = albumTrack as? SPTPartialTrack {
                    albumVo.tracks.append(track)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func getAccessToken() -> String {
        return SPTAuth.defaultInstance().session.accessToken
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
            albumsControlelr.albums = Array(playlist.albums).sorted(by: { $0.name < $1.name })
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
}
