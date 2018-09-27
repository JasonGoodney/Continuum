//
//  Alerts.swift
//  Timeline
//
//  Created by Jason Goodney on 9/24/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

struct Alert {
    static func present(on vc: UIViewController, title: String, message: String? = nil,
                        withActions actions: [UIAlertAction]? = nil,
                        style: UIAlertController.Style = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if actions == nil {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        } else {
            actions?.forEach{ alertController.addAction($0) }
        }
    
        DispatchQueue.main.async {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}
