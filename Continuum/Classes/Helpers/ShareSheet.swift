//
//  ShareSheet.swift
//  Timeline
//
//  Created by Jason Goodney on 9/24/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

struct ShareSheet {
    static func present(on vc: UIViewController, with image: UIImage) {
        let items = [image]
        
        let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        vc.present(shareSheet, animated: true)
    }
}
