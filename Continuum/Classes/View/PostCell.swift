//
//  PostCell.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

import UIKit

class PostCell: UITableViewCell {
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Subviews
    lazy var cardView = CardView()
}

// MARK: - Interface
private extension PostCell {
    
    func updateView() {
        addSubview(cardView)
        setupConstraints()
        
        guard let post = post else { return }
        cardView.title = post.caption
        cardView.image = post.photo
        
        let commentsCount = post.comments.count
        if commentsCount == 1 {
            cardView.subtitle = "\(commentsCount) Comment"
        } else {
            cardView.subtitle = "\(commentsCount) Comments"
        }
        
    }
    
    func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        cardView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        cardView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
}

