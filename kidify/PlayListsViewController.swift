//
//  PlayListsViewController.swift
//  kidify
//
//  Created by Grail, Christian on 26.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import UIKit

class PlayListsViewController: UITableViewController {

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Properties
    
    var playlists = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlaylists()
        
        spotifyManager.authorize()
        
        
        spotifyManager.myProfile { profile in
            debugPrint(profile.name)
        }
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
    
    //MARK: Private Methods
    
    private func loadPlaylists() {

        
        playlists += ["Test1" , "Test 2"]
    }
    
}
