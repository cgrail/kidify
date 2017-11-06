//
//  AlbumsTableViewController.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {

    public var playlist: Playlist?
    private var albums = [Album]()
    private let imageDownloader = ImageDownloader()
    @IBOutlet var navLabel: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        BusyIndicator.customActivityIndicatory(self.view, startAnimate: true)
        
        if let list = playlist {
            navLabel.title = list.name
            list.loadAlbums {
                self.albums = Array(list.albums).sorted(by: {
                    if let albumNo1 = self.extractFirstNumber($0.name),
                        let albumNo2 = self.extractFirstNumber($1.name){
                        return albumNo1 < albumNo2
                    }
                    return $0.name < $1.name
                })
                self.tableView.reloadData()
                if(list.loaded) {
                    BusyIndicator.customActivityIndicatory(self.view, startAnimate: false)
                }
            }
        }
        
    }
    
    private func extractFirstNumber(_ albumTitle: String) -> Int? {
        do {
            let regex = try NSRegularExpression(pattern: "\\d+")
            let results = regex.matches(in: albumTitle,
                                        range: NSRange(albumTitle.startIndex..., in: albumTitle))
            if (results.count >= 1 ) {
                if let result = Int(albumTitle[Range(results[0].range, in: albumTitle)!]) {
                    return result
                }
            }
            return Int.max
        } catch {
            return Int.max
        }
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
        
        if let imageUrl = album.imageUrl {
            self.imageDownloader.downloadImage(imageUrl) { uiImage in
                cell.albumImage.image = uiImage
            }
        }
        
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowTracks":
            guard let trackController = segue.destination as? TracksTableViewController,
                let selectedAlbum = sender as? AlbumTableViewCell,
                let indexPath = tableView.indexPath(for: selectedAlbum) else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            trackController.album = albums[indexPath.row]
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }

}
