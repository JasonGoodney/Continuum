//
//  Extensions.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

// MARK: - UINavigationController
extension UINavigationController {
    func push(_ viewController: UIViewController) {
        self.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        self.popViewController(animated: true)
    }
}

// MARK: - UIViewController
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func present(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboardOnSwipeDown() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}


// MARK: - UIView {
extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach{ addSubview($0) }
    }
    
    func roundCorners() {
        let roundPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundPath.cgPath
        self.layer.mask = maskLayer
    }
}
