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
    let searchController = UISearchController(searchResultsController: nil)
    let loginPlacerholderVC = LoginPlacerholderViewController()
    
    let loadingIndicatorView = LoadingIndicatorView()
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(performFullSync), for: .valueChanged)
        return control
    }()
    
    let searchResultsCountLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        view.separatorColor = .clear
        // FIXME: - the refresh control is pushing the tableview top edge inset down
//        view.refreshControl = self.refreshControl
        return view
    }()
    lazy var addPostButton = UIBarButtonItem(
        barButtonSystemItem: .add, target: self, action: #selector(addPostButtonTapped))
    
    // MARK: - Lifcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginPlacerholderVC.delegate = self
        
        updateView()
        
        performFullSync()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: PostController.shared.PostsChangedNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAccountStatus()
        
        resultsArray = PostController.shared.posts
        reload()
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
        tableView.anchor(view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func setupNavigationBar() {
        title = "Continuum"
        self.definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = addPostButton
        
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        let searchResultsCountItem = UIBarButtonItem(customView: searchResultsCountLabel)
        navigationItem.leftBarButtonItem = searchResultsCountItem
    }
}

// MARK: - Private Methods
private extension PostListViewController {
    @objc func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func performFullSync() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.center = self.view.center
        self.refreshControl.beginRefreshing()
        
        PostController.shared.fetchPost { (posts) in
            guard let posts = posts else { return }
            PostController.shared.posts = posts
            self.resultsArray = PostController.shared.posts
            
            DispatchQueue.main.async {
                
                self.loadingIndicatorView.removeFromSuperview()
                self.tableView.reloadData()
                self.refreshControl.beginRefreshing()
                if UIApplication.shared.isNetworkActivityIndicatorVisible {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            }

        }
    }
    
    func checkAccountStatus() {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("error get account status: \(error)")
            }
            
            switch status {
            case .available:
                if self.children.contains(self.loginPlacerholderVC) {
                    self.loginPlacerholderVC.remove()
                }
                break
            case .noAccount:
                let okAction = UIAlertAction(title: "Take Me", style: .default) { (_) in
                    self.openSettings()
                }
                let cancelAction = UIAlertAction(title: "Bore Me", style: .cancel, handler: nil)
                Alert.present(on: self, title: "Must be logged into iCloud", message: "We'll take you to the setting.", withActions: [cancelAction, okAction])
                self.add(self.loginPlacerholderVC)
            case .couldNotDetermine:
                print("Could not determine account")
            case .restricted:
                print("Account access has been restricted")
            }
        }
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
        let posts = isSearching ? resultsArray : PostController.shared.posts
        let post = posts[indexPath.row]
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
        present(detailVC)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width
    }
}

// MARK: - UIScrollViewDelegate
extension PostListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
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
        searchResultsCountLabel.text = "Results: \(PostController.shared.posts.count)"
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsCountLabel.text = ""
        isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsCountLabel.text = ""
        resultsArray = PostController.shared.posts
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}

// MARK: - LoginPlacerholderViewControllerDelegate
extension PostListViewController: LoginPlacerholderViewControllerDelegate {
    func loginPlacerholderViewLoginButtonTapped() {
        print("🤶\(#function)")
        openSettings()
    }
}
