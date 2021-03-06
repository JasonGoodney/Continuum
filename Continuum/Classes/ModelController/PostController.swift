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
    static let shared = PostController();
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
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
    let SubscribeToNewPostNotification = Notification.Name("SubscribeToNewPost")
    
    
    // MARK: - Save
    
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
                post.comments.insert(comment, at: 0)
                completion(comment)
            }
        }
    }
    
    // MARK: - Create
    
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
                self.posts.insert(post, at: 0)
                completion(post)
            }
        }
    }
    
    // MARK: - Fetch
    
    func fetchPost(completion: @escaping ([Post]?) -> Void) {

        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostKey.RecordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
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
        
        let notFetchedPredicte = NSPredicate(format: "NOT(recordID IN %@)", recordIds)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [referencePredicate, notFetchedPredicte])
        
        let query = CKQuery(recordType: CommentKey.RecordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
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
    
    // MARK: - Subscriptions
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        
        let predicate = NSPredicate(value: true)
    
        let subscription = CKQuerySubscription(recordType: PostKey.RecordType, predicate: predicate, subscriptionID: "AllPosts", options: [.firesOnRecordCreation])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "New Post"
        notificationInfo.alertBody = "There has been a new event posted"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("🔊Error in function: \(#function)\n\(error)\n\(error.localizedDescription)")
                completion?(false, error)
                return
            }
            
            guard let subscriptionId = subscription?.subscriptionID else { completion?(false, error); return }
            
            print(subscriptionId)
            completion?(true, nil)
        }
    }
    
    func addSubscriptionTo(commentsWithPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        let recordID = post.ckRecordId
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        
        let subscription = CKQuerySubscription(recordType: CommentKey.RecordType, predicate: predicate, subscriptionID: post.ckRecordId.recordName, options: [.firesOnRecordCreation])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "New Follower"
        notificationInfo.alertBody = "😍😍😍"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                completion?(false, error)
                return
            }
            
            guard let subscriptionId = subscription?.subscriptionID else { completion?(false, error); return }
            
            print(subscription?.notificationInfo?.title)
            completion?(true, nil)
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        
        let subscriptionId = post.ckRecordId.recordName
        
        publicDB.delete(withSubscriptionID: subscriptionId) { (_, error) in
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                completion?(false, error)
                return
            }
            
            completion?(true, nil)
        }
    }
    
    func checkSubscription(to post: Post, completion: ((Bool) -> Void)?) {
        
        let subscriptionId = post.ckRecordId.recordName
        
        publicDB.fetch(withSubscriptionID: subscriptionId) { (subscription, error) in
            
            if let error = error {
                print("🔊Error in function: \(#function) \(error) \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            if let _  = subscription {
                completion?(true)
            }
        }
    }
    
    func toggleSubscription(to post: Post, completion: ((Bool) -> Void)?) {
        
        checkSubscription(to: post) { (success) in
            if success {
                print("Removes subscription")
                self.removeSubscriptionTo(commentsForPost: post, completion: nil)
                completion?(true)
                return
            } else {
                print("Adds subscription")
                self.addSubscriptionTo(commentsWithPost: post, completion: nil)
                completion?(false)
                return
            }
            
        }
    }
    
    // MARK: - Ckeck Account Status
    func checkAccountStatus(completion: @escaping (CKAccountStatus?) -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("error get account status: \(error)")
                completion(nil)
                return
            }
            
            completion(status)
        }
    }
}
