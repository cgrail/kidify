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
    
    public var uri: URL
    
    public var imageUrl: URL?
    
    public var loaded = false
    
    public var tracks = [Track]()
    
    public var currentlyPlayed : Track?
    
    public var partlyFinished = false
    
    init(name: String, uri: URL) {
        self.name = name
        self.uri = uri
    }
    
    public func loadAlbum(_ completeHandler: @escaping () -> Void) {
        if (loaded) {
            completeHandler()
            return
        }
        SPTAlbum.album(withURI: uri, accessToken: getAccessToken(), market: nil)  { (error, albumResponse) in
            guard let album = albumResponse as? SPTAlbum,
                let trackPage = album.firstTrackPage,
                let albumTracks = trackPage.items else {
                return
            }
            for albumTrack in albumTracks {
                if let track = albumTrack as? SPTPartialTrack {
                    let trackVo = Track(name: track.name, uri: track.uri)
                    self.tracks.append(trackVo)
                }
            }
            self.loaded = true
            completeHandler()
        }
    }
    
    private func getAccessToken() -> String {
        return SPTAuth.defaultInstance().session.accessToken
    }
    
    var hashValue: Int {
        return name.hashValue &* 16777619
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name
    }
    
}

