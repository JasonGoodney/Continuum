//
//  LoginPlacerholderViewController.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol LoginPlacerholderViewControllerDelegate: class {
    func loginPlacerholderViewLoginButtonTapped()
}

class LoginPlacerholderViewController: UIViewController {
    
    weak var delegate: LoginPlacerholderViewControllerDelegate?
    
    let buttonTitle =
                    """
                        Oops
                        No iCloud Account found
                        Tap here
                        To go to your iCloud settings
                    """
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.buttonTitle, for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    @objc func loginButtonTapped() {
        print("🤶\(#function)")
        delegate?.loginPlacerholderViewLoginButtonTapped()
    }
}
