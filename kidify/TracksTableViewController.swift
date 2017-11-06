//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class TracksTableViewController: UITableViewController{
    
    public var album: Album?
    public var tracks = [SPTPartialTrack]()
    @IBOutlet var navLabel: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        if let a = self.album {
            navLabel.title = a.name
            a.loadAlbum{
                self.tracks = a.tracks
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TrackTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TrackTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TrackTableViewCell.")
        }
        
        
        let track = tracks[indexPath.row]
        cell.label.text = track.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowPlayer":
            guard let playerViewController = segue.destination as? PlayerViewController,
                let selectedTrack = sender as? TrackTableViewCell,
                let indexPath = tableView.indexPath(for: selectedTrack) else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let track = tracks[indexPath.row]
            playerViewController.currentTrack = track
            playerViewController.album = album
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
}
