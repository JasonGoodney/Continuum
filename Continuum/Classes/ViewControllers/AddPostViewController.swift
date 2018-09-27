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
    private var imagePicker = UIImagePickerController()
    
    // MARK: - Subviews
    let cardView = CardView()
    
    lazy var selectPhotoButton: UILabel = {
        let button = UILabel()
        button.text = "Tap Tap\nTo Select a Photo"
        button.textColor = .lightGray
        button.font = UIFont.boldSystemFont(ofSize: 20)
        button.numberOfLines = 2
        button.isUserInteractionEnabled = true
        button.textAlignment = .center
        return button
    }()
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 2
        gesture.addTarget(self, action: #selector(selectPhotoButtonTapped))
        return gesture
    }()
    
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
        
        sendTextToolbar.sendTextDelegate = self
        updateView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        hideKeyboardOnSwipeDown()
        
        selectPhotoButton.addGestureRecognizer(doubleTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cardView.imageView.image = nil
        selectPhotoButton.text = "Tap Tap\nTo Select a Photo"
    }
}

// MARK: - UI
private extension AddPostViewController {
    func updateView() {
        view.backgroundColor = .white
        view.addSubviews([cardView, selectPhotoButton, sendTextToolbar, cancelButton])
        setupConstraints()
        
        cancelButton.layer.cornerRadius = 8
        sendTextToolbar.sendButton.layer.cornerRadius = 8
    }
    
    func setupConstraints() {
        let margin: CGFloat = 20
        cardView.anchor(view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, topConstant: 20, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: view.frame.width - (margin * 2))
        selectPhotoButton.anchor(view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, topConstant: 30, leftConstant: margin + 10, bottomConstant: 0, rightConstant: margin + 10, widthConstant: 0, heightConstant: view.frame.width - (margin * 2) - 10)
        
        sendTextToolbar.anchor(nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
        
        cancelButton.anchor(view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, topConstant: 24, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 70, heightConstant: 0)
        
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
    
    @objc func selectPhotoButtonTapped() {
        print("🤶\(#function)")
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        let photoAction = UIAlertAction(title: "Photo", style: .default) { (_) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        Alert.present(on: self, title: "Select a Photo", message: nil, withActions: [photoAction, cameraAction, cancelAction], style: .actionSheet)
    }
    
}

// MARK: - SendTextToolbarDelegate
extension AddPostViewController: SendTextToolbarDelegate {
    @objc func sendTextToolbarSendButtonTapped(_ sendTextToolbar: SendTextToolbar) {
        print("🤶\(#function)")
        guard let photo = cardView.imageView.image else {
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

// MARK: - UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        selectPhotoButton.text = ""
        cardView.imageView.image = image
        dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }
}

extension Alert {
    static func presentNoPhotoAlert(on vc: UIViewController) {
        present(on: vc, title: "No Photo", message: "You must select a photo to add a post.", withActions: [UIAlertAction(title: "OK", style: .cancel)])
    }
    
    static func presentNoCaptionAlert(on vc: UIViewController) {
        present(on: vc, title: "No Caption", message: "You must write a caption to add a post.", withActions: [UIAlertAction(title: "OK", style: .cancel)])
    }
}
