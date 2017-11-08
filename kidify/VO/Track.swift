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
    
    init(name: String, uri: URL) {
        self.name = name
        self.uri = uri
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool{
        return lhs.name == rhs.name && lhs.uri == rhs.uri
    }
    
}
