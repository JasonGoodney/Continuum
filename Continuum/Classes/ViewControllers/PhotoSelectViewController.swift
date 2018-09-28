//
//  PhotoSelectViewController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: class {
    func photoSelectViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    
    weak var photoSelectorDelegate: PhotoSelectorViewControllerDelegate?
    let imagePicker = UIImagePickerController()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        updateView()
        
        cardView.image = nil
        selectPhotoButton.addGestureRecognizer(doubleTapGesture)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cardView.imageView.image = nil
        selectPhotoButton.text = "Tap Tap\nTo Select a Photo"
    }
    
}

// MARK: - UI
extension PhotoSelectorViewController {
    func updateView() {
        view.backgroundColor = .white
        view.addSubviews([cardView, selectPhotoButton])
        setupConstraints()
    }
    
    func setupConstraints() {
        cardView.fillSuperview()
        selectPhotoButton.fillSuperview()
    }
}

// MARK: - User Interaction
extension PhotoSelectorViewController {
    @objc func selectPhotoButtonTapped() {
        imagePicker.allowsEditing = true
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

// MARK: - UIImagePickerControllerDelegate
extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        selectPhotoButton.text = ""
        cardView.imageView.image = image
        dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }
}
