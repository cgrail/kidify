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
    
    public var uri: URL
    
    public var loaded = false
    
    public var albums = Set<Album>()
    
    init(name: String, uri: URL) {
        self.name = name
        self.uri = uri
    }
    
    public func loadAlbums(completeHandler: @escaping () -> Void) {
        if(loaded) {
            completeHandler()
        }
        
        SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: getAccessToken()) { (error, response) in
            if let playlist = response as? SPTPlaylistSnapshot {
                if let page = playlist.firstTrackPage {
                    self.handlePlaylist(page, completeHandler)
                }
            }
        }
    }
    
    private func handlePlaylist(_ currentPage: SPTListPage, _ completeHandler: @escaping () -> Void) {
        guard let items = currentPage.items else {
            return
        }
        for item in items {
            if let track = item as? SPTPlaylistTrack {
                let albumVo = Album(name: track.album.name, uri: track.album.uri)
                if(albums.contains(albumVo)){
                    return
                }
                albums.insert(albumVo)
            }
        }
        if(currentPage.hasNextPage) {
            debugPrint("Next page")
            currentPage.requestNextPage(withAccessToken: getAccessToken()) { (error, response) in
                debugPrint("Next page")
                if let page = response as? SPTListPage {
                    self.handlePlaylist(page, completeHandler)
                }
            }
        } else {
            completeHandler()
            self.loaded = true
        }
    }
    
    private func getAccessToken() -> String {
        return SPTAuth.defaultInstance().session.accessToken
    }
    
}

