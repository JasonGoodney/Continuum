//
//  PostController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    // MARK: - Properties
    static let shared = PostController(); private init() {}
    
    var posts: [Post] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.PostsChangedNotification, object: nil)
            }
        }
    }
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    let PostsChangedNotification = Notification.Name("PostsChanged")
    let PostCommentsChangedNotification = Notification.Name("PostCommentsChanged")
    
    // MARK: - Methods
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let postReference = CKRecord.Reference(recordID: post.ckRecordId, action: .deleteSelf)
        let comment = Comment(text: text, post: post, postReference: postReference)
        let record = CKRecord(comment: comment)
        
        publicDB.save(record) { (record, error) in
            
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                return
            }
            
            if let _ = record {
                print("saved comment record")
                post.comments.append(comment)
                completion(comment)
            }
        }
        
        
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post) -> Void) {
        let post = Post(photo: photo, caption: caption)
        let record = CKRecord(post: post)
        
        publicDB.save(record) { (record, error) in
            
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                return
            }
            
            if let _ = record {
                print("saved post record")
                self.posts.append(post)
                completion(post)
            }
        }
    }
    
    func fetchPost(completion: @escaping ([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostKey.RecordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
             if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let records = records {
                self.posts = records.compactMap({ Post(record: $0) })
                completion(self.posts)
            }
        }
    }
    
    func fetchCommentsFor(post: Post, completion: @escaping (Bool) -> Void) {
        
        let reference = CKRecord.Reference(recordID: post.ckRecordId, action: .deleteSelf)
        
        let referencePredicate = NSPredicate(format: "postReference == %@", reference)
        let recordIds = post.comments.compactMap({ $0.ckRecordId })
        
        //'recordID' is from Apple's references, recordID not my variables
        let notFetchedPredicte = NSPredicate(format: "NOT(recordID IN %@)", recordIds)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [referencePredicate, notFetchedPredicte])
        
        let query = CKQuery(recordType: CommentKey.RecordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let records = records {
                let comments = records.compactMap { Comment(record: $0) }
                post.comments.append(contentsOf: comments)
                completion(true)
            }
        }
    }
}
