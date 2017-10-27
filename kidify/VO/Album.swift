//
//  Album.swift
//  kidify
//
//  Created by Grail, Christian on 27.10.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import Foundation

class Album: Hashable {
    
    public var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var hashValue: Int {
        return name.hashValue &* 16777619
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name
    }
    
}

