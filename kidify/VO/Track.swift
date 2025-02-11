//
//  Track.swift
//  kidify
//
//  Created by Grail, Christian on 08.11.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import Foundation

class Track: NSObject {
    
    public var name: String
    
    public var uri: URL
    
    public var sharingURL: String
    
    public var played = false
    
    init(name: String, uri: URL, sharingURL: String) {
        self.name = name
        self.uri = uri
        self.sharingURL = sharingURL
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool{
        return lhs.name == rhs.name && lhs.uri == rhs.uri
    }
    
}
