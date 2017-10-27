//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class TracksTableViewController: UITableViewController{
    
    public var tracks = [SPTPartialTrack]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
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
            guard let playerViewController = segue.destination as? PlayerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTrack = sender as? TrackTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTrack) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let track = tracks[indexPath.row]
            playerViewController.currentTrack = track
            playerViewController.tracks = tracks
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
}
