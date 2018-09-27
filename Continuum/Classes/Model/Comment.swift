//
//  Comment.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation

class Comment {
    var text: String
    var timestamp: Date
    weak var post: Post?
    
    init(text: String, post: Post, timestamp: Date = Date()) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
}

extension Comment: SearchableRecord {
    func matches(_ searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
}
