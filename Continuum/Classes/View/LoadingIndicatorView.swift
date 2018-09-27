//
//  LoadingIndicatorView.swift
//  Continuum
//
//  Created by Jason Goodney on 9/27/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol LoadingIndicatorViewDelegate: class {
    func loadingIndicatorViewIsShown()
}

class LoadingIndicatorView: UIView {
    
    weak var delegate: LoadingIndicatorViewDelegate?

    let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 20
    
        addShadow()
        
        addSubview(loadingLabel)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
