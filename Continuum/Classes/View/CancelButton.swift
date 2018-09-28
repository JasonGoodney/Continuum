//
//  CancelButton.swift
//  Continuum
//
//  Created by Jason Goodney on 9/27/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol CancelButtonDelegate: class {
    func cancelButtonWillDismiss(viewController: UIViewController)
}

extension CancelButtonDelegate {
    func cancelButtonWillDismiss(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

class CancelButton: UIButton {

    weak var delegate: CancelButtonDelegate?
    
    var parentViewController: UIViewController
    
    var title = "Cancel" {
        didSet {
            self.setTitle(title, for: .normal)
        }
    }
    
    init(frame: CGRect, parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        
        super.init(frame: frame)
        
        setTitle(title, for: .normal)
        addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addCornerRadius(8)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancelButtonTapped() {
        delegate?.cancelButtonWillDismiss(viewController: parentViewController)
    }
    
}
