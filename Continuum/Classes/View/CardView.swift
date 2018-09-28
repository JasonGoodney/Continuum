//
//  CardView.swift
//  CardView
//
//  Created by Jason Goodney on 9/25/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import AVFoundation

protocol CardViewDelegate: class {
    func cardViewWasTapped(_ cardView: CardView)
}

class CardView: UIView {

    // MARK: - Properties
    weak var delegate: CardViewDelegate?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    // MARK: - Subviews
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1)
        label.textAlignment = .left
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    // MARK: - Init
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init?(frame: CGRect, title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        guard let title = title, let subtitle = subtitle, let image = image else {
            return nil
        }
        
        self.init(frame: frame)
        
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        setupConstraints()
        
        addShadow()
        titleLabel.addShadow()
        subtitleLabel.addShadow()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupConstraints() {
        subtitleLabel.anchor(nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 34)
        
        titleLabel.anchor(nil, leading: leadingAnchor, bottom: subtitleLabel.topAnchor, trailing: trailingAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 34)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 12.0
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
    }
    
    func addCornerRadius(_ radius: CGFloat = 20) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

