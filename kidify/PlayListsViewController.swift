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
        if let playlistImage = playlist.imageUrl {
            downloadImage(url: playlistImage, cell: cell)
        }
        
        return cell
    }
    
    func downloadImage(url: URL, cell: PlaylistTableViewCell) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                cell.playlistImage.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    private func getSpotifyPlaylists() {
        
        let session = SPTAuth.defaultInstance().session
        
        let playlistRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        SPTRequest.sharedHandler().perform(playlistRequest) { (error, response, data) in
            let list = try! SPTPlaylistList(from: data, with: response)
            guard let playlists = list.items else {
                return
            }
            for playList in playlists  {
                if let playlist = playList as? SPTPartialPlaylist {
                    if let uri = URL(string: playlist.uri.absoluteString){
                        let playlistVO = Playlist(name: playlist.name, uri: uri)
                        if let imageUrl = playlist.smallestImage.imageURL {
                            playlistVO.imageUrl = imageUrl
                        }
                        self.playlists.append(playlistVO)
                    }
                }
            }
            self.tableView.reloadData()
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
            
            albumsControlelr.playlist = playlists[indexPath.row]
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
}
