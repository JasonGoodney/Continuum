//
//  PostListViewController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import CloudKit

class PostListViewController: UIViewController {
    
    // MARK: - Properties
    var resultsArray: [Post] = []
    var isSearching = false
    
    // MARK: - Subviews
    let searchResultsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        view.separatorColor = .clear
        return view
    }()
    lazy var addPostButton = UIBarButtonItem(
        barButtonSystemItem: .add, target: self, action: #selector(addPostButtonTapped))
    
    // MARK: - Lifcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("error get account status: \(error)")
            }
            
            switch status {
            case .available:
                break
            case .noAccount:
                let okAction = UIAlertAction(title: "Take Me", style: .default) { (_) in
                    self.openSettings()
                }
                let cancelAction = UIAlertAction(title: "Bore Me", style: .cancel, handler: nil)
                Alert.present(on: self, title: "Must be logged into iCloud", message: "We'll take you to the setting.", withActions: [cancelAction, okAction])
            case .couldNotDetermine:
                print("Could not determine account")
            case .restricted:
                print("Account access has been restricted")
            }
        }

        
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        reload()
    }
    
    func openSettings() {
        let settingsCloudKitURL = URL(string: "App-Prefs:root=CASTLE")
        if let url = settingsCloudKitURL, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

// MARK: - UpdateView
private extension PostListViewController {
    func updateView() {
        view.addSubviews([tableView])
        setupConstraints()
        setupNavigationBar()
    }

    
    func setupConstraints() {
        tableView.fillSuperview()
    }
    
    func setupNavigationBar() {
        self.definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = addPostButton
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        let searchResultsCountItem = UIBarButtonItem(customView: searchResultsCountLabel)
        searchResultsCountItem.isEnabled = false
        navigationItem.leftBarButtonItem = searchResultsCountItem
    }
}

// MARK: - Methods
private extension PostListViewController {
    @objc func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - User Interaction
private extension PostListViewController {
    @objc func addPostButtonTapped() {
        let addPostVC = AddPostViewController()
        present(addPostVC)
    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? resultsArray.count : PostController.shared.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell else  {
            fatalError("Could not dequeue cell: \(PostCell.reuseIdentifier)")
        }
        
        let post = resultsArray[indexPath.row]
        cell.post = post
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = PostController.shared.posts[indexPath.row]
        let detailVC = PostDetailViewController()
        detailVC.post = post
        navigationController?.push(detailVC)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width
    }

}

// MARK: - UISearchBarDelegate
extension PostListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resultsArray = PostController.shared.posts
        } else {
            resultsArray = PostController.shared.posts.filter { $0.matches(searchText) }
            
            
        }
        searchResultsCountLabel.text = "Results: \(resultsArray.count)"
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsCountLabel.text = ""
        resultsArray = PostController.shared.posts
    }
}
