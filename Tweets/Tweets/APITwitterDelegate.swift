//
//  APITwitterDelegate.swift
//  Tweets
//
//  Created by Lucas BELVALETTE on 10/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

protocol APITwitterDelegate: class {
    func handleTweet (_ tweet: [Tweet])
    func handleError(_ error: NSError)
}
