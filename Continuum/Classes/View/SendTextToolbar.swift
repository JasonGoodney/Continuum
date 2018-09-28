//
//  SendTextToolbar.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol SendTextToolbarDelegate: class {
    func sendTextToolbarSendButtonTapped(_ sendTextToolbar: SendTextToolbar)
}

class SendTextToolbar: UIView {

    // MARK: - Properties
    weak var sendTextDelegate: SendTextToolbarDelegate?
    var textFieldPlaceholder: String? {
        didSet {
            self.textField.placeholder = textFieldPlaceholder
        }
    }
    var buttonTitle: String? {
        didSet {
            self.sendButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    // MARK: - Subviews
    lazy var textField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.006150111932, green: 0.5565116393, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var textFieldItem = UIBarButtonItem(customView: self.textField)
    lazy var sendButtonItem = UIBarButtonItem(customView: self.sendButton)
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews([textField, sendButton])
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        textField.anchorCenterYToSuperview()
        textField.anchor(nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 44)
        
        sendButton.anchorCenterYToSuperview()
        sendButton.anchor(nil, leading: nil, bottom: nil, trailing: trailingAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 60, heightConstant: 30)
        
    }
}

// MARK: - User Interaction
extension SendTextToolbar {
    @objc func sendButtonTapped() {
        sendTextDelegate?.sendTextToolbarSendButtonTapped(self)
    }
}
