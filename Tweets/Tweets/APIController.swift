//
//  APIController.swift
//  Tweets
//
//  Created by Lucas BELVALETTE on 10/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class APIController {
    weak var delegate: APITwitterDelegate?
    let token: String
    var tweets: [Tweet] = []
    
    init(delegate: APITwitterDelegate?, token: String) {
        self.delegate = delegate
        self.token = token
    }
    
    func parseTwitterResponse(_ dic : [[String: AnyObject]]) {
        for any in dic {
            let tweet = any as NSDictionary
            let date = tweet.value(forKey: "created_at") as! String
            let tmp = Tweet(name: (tweet.value(forKey: "user")! as AnyObject).value(forKey: "name")! as! String,text: tweet.value(forKey: "text")! as! String, date: date)
            self.tweets.append(tmp)
        }
        DispatchQueue.main.async {
            self.delegate!.handleTweet(self.tweets)   
        }
    }
    
    func requestTwitterAPI(_ str: String) {
        self.tweets = []
        let urlStr = "https://api.twitter.com/1.1/search/tweets.json?q=\(str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&lang=fr&count=100"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + self.token,forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let err = error {
                DispatchQueue.main.async {
                    self.delegate?.handleError(err as NSError)
                }
            }
            else if let d = data {
                do {
                    if let dic: NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if let tweets = dic.value(forKey: "statuses") as? [[String:AnyObject]] {
                            if tweets.count != 0 {
                                self.parseTwitterResponse(tweets)
                            }
                            else {
                                DispatchQueue.main.async {
                                    let noob : NSError = NSError.init(domain: "Search Not Found", code: 1, userInfo: [:] )
                                    self.delegate?.handleError(noob)
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let noob : NSError = NSError.init(domain: "Missing search input", code: 1, userInfo: [:] )
                                self.delegate?.handleError(noob)
                            }
                        }
                        
                    }
                }
                catch (let err) {
                    DispatchQueue.main.async {
                        self.delegate?.handleError(err as NSError)
                    }
                }
            }
        }
        task.resume()
    }
}
