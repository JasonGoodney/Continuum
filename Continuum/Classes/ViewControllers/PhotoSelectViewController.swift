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
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        selectPhotoButton.setTitle("Select a Photo", for: .normal)
        cardView.image = nil
        
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        let photosAction = UIAlertAction(title: "Photos", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let actions = [photosAction, cameraAction, cancelAction]
        
        Alert.present(on: self, title: "Select a Photo", message: nil, withActions: actions, style: .actionSheet)
    }
}

extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        photoSelectorDelegate?.photoSelectViewControllerSelected(image: image)
        cardView.imageView.image = image
        cardView.backgroundColor = .orange
        cardView.imageView.backgroundColor = .blue
        selectPhotoButton.setTitle("", for: .normal)
        dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss()
    }
}
