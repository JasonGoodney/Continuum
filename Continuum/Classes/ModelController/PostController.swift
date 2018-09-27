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
    
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
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
}
