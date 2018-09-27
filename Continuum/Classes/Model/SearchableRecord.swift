//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(_ searchTerm: String) -> Bool
}
