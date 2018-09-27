//
//  PostDetailViewController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

extension UITableViewCell: ReuseIdentifiable {}

class SubtitleTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        textLabel?.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PostDetailViewController: UIViewController {
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Subviews
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)
        
        return view
    }()
    
    let cardView = CardView()
    var buttonStackView = UIStackView()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        button.setTitle("Comment", for: .normal)
        return button
    }()
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.setTitle("Share", for: .normal)
        return button
    }()
    lazy var followButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        button.setTitle("Follow", for: .normal)
        return button
    }()
    // MARK: - Lifcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupConstraints()
    }
}

// MARK: - UpdateView
private extension PostDetailViewController {
    func updateView() {
        view.backgroundColor = .white
        addSubviews(subviews: [tableView, cardView, buttonStackView])
        setupButtonStack()
        setupConstraints()
        
        if let photo = post?.photo {
            cardView.imageView.image = photo
            reload()
        }
    }
    
    func addSubviews(subviews: [UIView]) {
        subviews.forEach{ view.addSubview($0) }
    }
    
    func setupConstraints() {
        
        let margin: CGFloat = 20
        let cardViewHeight: CGFloat = view.frame.width - (margin * 2)
        
        cardView.anchor(view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, topConstant: 20, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: cardViewHeight)
        
        buttonStackView.anchor(cardView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        tableView.anchor(buttonStackView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0 )
    }
    
    func setupButtonStack() {
        buttonStackView.axis = .horizontal
        [commentButton, shareButton, followButton].forEach{
            buttonStackView.addArrangedSubview($0)
        }
        buttonStackView.distribution = .fillEqually
        
    }
}

// MARK: - User Interaction
private extension PostDetailViewController {
    @objc func commentButtonTapped() {
        print("\(#function)")
        addCommentAlert()
    }
    
    @objc func shareButtonTapped() {
        print("\(#function)")
    }
    
    @objc func followButtonTapped() {
        print("\(#function)")
    }
}

// MARK: - Methods
private extension PostDetailViewController {
    @objc func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func addCommentAlert() {
        let alertController = UIAlertController(title: "New Comment", message: "Add groovy comment", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Say something..."
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let commentText = alertController.textFields?[0].text, !commentText.isEmpty else { return }
            guard let post = self.post else { return }
            PostController.shared.addComment(text: commentText, post: post, completion: { (comment) in
                
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController)
    }
}

// MARK: - UITableViewDataSource
extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseIdentifier, for: indexPath) as? SubtitleTableViewCell else { return UITableViewCell() }
        
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


