//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {

    public var albums = [Album]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "AlbumTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AlbumTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AlbumTableViewCell.")
        }
        
        
        let album = albums[indexPath.row]
        cell.label.text = album.name
        
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowTracks":
            guard let trackController = segue.destination as? TracksTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedAlbum = sender as? AlbumTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedAlbum) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let album = albums[indexPath.row]
            trackController.tracks = album.tracks
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }

}
