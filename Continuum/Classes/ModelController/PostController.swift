//
//  PostController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class PostController {
    
    // MARK: - Properties
    static let shared = PostController(); private init() {}
    
    var posts: [Post] = []
    
    
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        completion(comment)
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post) -> Void) {
        let post = Post(photo: photo, caption: caption)
        posts.append(post)
        completion(post)
    }
}
