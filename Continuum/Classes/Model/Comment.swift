//
//  Comment.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation
import CloudKit

struct CommentKey {
    static let RecordType = "Comment"
    
    static let Timestamp = "timestamp"
    static let Text = "text"
    static let Post = "post"
    static let PostReference = "postReference"
}

class Comment {
    var text: String
    var timestamp: Date
    weak var post: Post?
    var ckRecordId: CKRecord.ID
    var postReference: CKRecord.Reference
    
    init(text: String, post: Post, timestamp: Date = Date(),
         ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString),
         postReference: CKRecord.Reference) {
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.ckRecordId = ckRecordId
        self.postReference = postReference
    }
    
    init?(record: CKRecord) {
        guard let text = record[CommentKey.Text] as? String,
            let timestamp = record[CommentKey.Timestamp] as? Date,
            let postReference = record[CommentKey.PostReference] as? CKRecord.Reference
        else { return nil }
        
//        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.ckRecordId = record.recordID
        self.postReference = postReference
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        let recordId = comment.ckRecordId
        
        
        guard let post = comment.post else {
            fatalError("Comment does not have a Post relationship")
        }
        
        self.init(recordType: CommentKey.RecordType, recordID: recordId)
        self.setValue(comment.text, forKey: CommentKey.Text)
        self.setValue(comment.timestamp, forKey: CommentKey.Timestamp)
        self.setValue(CKRecord.Reference(recordID: post.ckRecordId, action: .deleteSelf), forKey: CommentKey.PostReference)
    }
}

extension Comment: SearchableRecord {
    func matches(_ searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
}
