//
//  Playlist.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import Foundation

class Playlist {
    
    public var name: String
    
    public var albums = Set<Album>()
    
    init(name: String) {
        self.name = name
    }
    
}

