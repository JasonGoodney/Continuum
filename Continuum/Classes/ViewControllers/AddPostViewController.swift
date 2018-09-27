//
//  AddPostViewController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {

    // MARK: - Propeties
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - Subviews
    let photoSelectVC = PhotoSelectorViewController()
    
    
    lazy var sendTextToolbar: SendTextToolbar = {
        let toolbar = SendTextToolbar()
        toolbar.textFieldPlaceholder = "Caption..."
        toolbar.buttonTitle = "Share"
        return toolbar
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoSelectVC.photoSelectorDelegate = self
        sendTextToolbar.sendTextDelegate = self
        
        updateView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        hideKeyboardOnSwipeDown()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
}

// MARK: - UI
private extension AddPostViewController {
    func updateView() {
        view.backgroundColor = .white
        photoSelectVC.view.backgroundColor = .orange
        add(photoSelectVC)
        view.addSubviews([sendTextToolbar, cancelButton])
        
        setupConstraints()
        
        cancelButton.layer.cornerRadius = 8
        sendTextToolbar.sendButton.layer.cornerRadius = 8
    }
    
    func setupConstraints() {
        let margin: CGFloat = 20

        photoSelectVC.view.anchor(view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, topConstant: 22, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: view.frame.width - (margin * 2))
        
        sendTextToolbar.anchor(nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
        
        cancelButton.anchor(view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, topConstant: 22, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 70, heightConstant: 0)
        
    }

}

// MARK: - User Interaction
extension AddPostViewController {
    @objc func cancelButtonTapped() {
        dismiss()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardFrame.height
        }
        
        if view.frame.origin.y == 0 {
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
            
            UIView.animate(withDuration: animationDuration as! TimeInterval) {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.view.window?.frame.height)! - self.keyboardHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - SendTextToolbarDelegate
extension AddPostViewController: SendTextToolbarDelegate {
    @objc func sendTextToolbarSendButtonTapped(_ sendTextToolbar: SendTextToolbar) {
        print("🤶\(#function)")
        guard let photo = photoSelectVC.cardView.imageView.image else {
            Alert.presentNoPhotoAlert(on: self)
            return }
        guard let caption = sendTextToolbar.textField.text, !caption.isEmpty else {
            Alert.presentNoCaptionAlert(on: self)
            return
        }
        
        PostController.shared.createPostWith(photo: photo, caption: caption) { (post) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        sendTextToolbar.textField.text = ""
        
    }
}

extension AddPostViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectViewControllerSelected(image: UIImage) {
        photoSelectVC.cardView.imageView.image = image
    }
}

