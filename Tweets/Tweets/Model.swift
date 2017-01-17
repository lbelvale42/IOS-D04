//
//  Model.swift
//  Tweets
//
//  Created by Lucas BELVALETTE on 10/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

struct Tweet: CustomStringConvertible {
    let name: String
    let text: String
    let date: String
    
    var description: String {
        return "\(name): \(text)"
    }
}
