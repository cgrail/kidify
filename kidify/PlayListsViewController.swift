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
    let imageDownloader = ImageDownloader()
    
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
        var numOfSections: Int = 0
        if playlists.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Please add some playlists"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
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
        if let playlistImage = playlist.imageUrl {
            self.imageDownloader.downloadImage(playlistImage) { uiImage in
                cell.playlistImage.image = uiImage
            }
        }
        
        return cell
    }

    
    private func getSpotifyPlaylists() {
        
        BusyIndicator.customActivityIndicatory(self.view, startAnimate: true)
        
        let session = SPTAuth.defaultInstance().session
        
        let playlistRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        SPTRequest.sharedHandler().perform(playlistRequest) { (error, response, data) in
            let list = try! SPTPlaylistList(from: data, with: response)
            guard let playlists = list.items else {
                return
            }
            for playList in playlists  {
                if let playlist = playList as? SPTPartialPlaylist,
                    let uri = URL(string: playlist.uri.absoluteString){
                    let playlistVO = Playlist(name: playlist.name, uri: uri)
                    if let smallestImage = playlist.smallestImage,
                       let imageUrl = smallestImage.imageURL {
                        playlistVO.imageUrl = imageUrl
                    }
                    self.playlists.append(playlistVO)
                }
            }
            self.tableView.reloadData()
            BusyIndicator.customActivityIndicatory(self.view, startAnimate: false)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowAlbums":
            guard let albumsControlelr = segue.destination as? AlbumsTableViewController,
                let selectedPlaylist = sender as? PlaylistTableViewCell,
                let indexPath = tableView.indexPath(for: selectedPlaylist) else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            albumsControlelr.playlist = playlists[indexPath.row]
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
}
