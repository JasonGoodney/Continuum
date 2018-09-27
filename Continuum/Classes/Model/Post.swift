//
//  Post.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

struct PostKey {
    static let PostRecordType = "Post"
    
    static let Timestamp = "timestamp"
    static let Caption = "caption"
    static let PhotoData = "photoData"
}

class Post {
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = []) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.photo = photo
    }
}

extension Post: SearchableRecord {
    func matches(_ searchTerm: String) -> Bool {
//        return comments.contains(where: { $0.matches(searchTerm.lowercased()) })
        return caption.lowercased().contains(searchTerm.lowercased())
    }
}
