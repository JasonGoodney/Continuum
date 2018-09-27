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
        super.init(frame: frame)
        
        backgroundColor = .blue//UIColor.black.withAlphaComponent(0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
