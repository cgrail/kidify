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
    
    public var imageUrl: URL?
    
    public var loaded = false
    
    public var albums = Set<Album>()
    
    init(name: String, uri: URL) {
        self.name = name
        self.uri = uri
    }
    
    public func loadAlbums(completeHandler: @escaping () -> Void) {
        if(loaded) {
            completeHandler()
            return
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
                guard let album = track.album,
                    let albumUri = album.uri else {
                    continue
                }
                let albumVo = Album(name: album.name, uri: albumUri)
                if let image = album.largestCover {
                    albumVo.imageUrl = image.imageURL
                }
                if(albums.contains(albumVo)){
                    continue
                }
                albums.insert(albumVo)
            }
        }
        if(currentPage.hasNextPage) {
            currentPage.requestNextPage(withAccessToken: getAccessToken()) { (error, response) in
                if let page = response as? SPTListPage {
                    self.handlePlaylist(page, completeHandler)
                }
            }
        } else {
            self.loaded = true
        }
        completeHandler()
    }
    
    private func getAccessToken() -> String {
        return SPTAuth.defaultInstance().session.accessToken
    }
    
}

