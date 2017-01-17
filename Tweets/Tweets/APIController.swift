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
    
    func parseTwitterResponse(dic : [[String: AnyObject]]) {
        for any in dic {
            let tweet = any as NSDictionary
            let date = tweet.valueForKey("created_at") as! String
            let tmp = Tweet(name: tweet.valueForKey("user")!.valueForKey("name")! as! String,text: tweet.valueForKey("text")! as! String, date: date)
            self.tweets.append(tmp)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate!.handleTweet(self.tweets)   
        }
    }
    
    func requestTwitterAPI(str: String) {
        self.tweets = []
        let urlStr = "https://api.twitter.com/1.1/search/tweets.json?q=\(str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&lang=fr&count=100"
        let url = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Bearer " + self.token,forHTTPHeaderField: "Authorization")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            if let err = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.handleError(err as NSError)
                }
            }
            else if let d = data {
                do {
                    if let dic: NSDictionary = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let tweets = dic.valueForKey("statuses") as? [[String:AnyObject]] {
                            if tweets.count != 0 {
                                self.parseTwitterResponse(tweets)
                            }
                            else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    let noob : NSError = NSError.init(domain: "Search Not Found", code: 1, userInfo: [:] )
                                    self.delegate?.handleError(noob)
                                }
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                let noob : NSError = NSError.init(domain: "Missing search input", code: 1, userInfo: [:] )
                                self.delegate?.handleError(noob)
                            }
                        }
                        
                    }
                }
                catch (let err) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.handleError(err as NSError)
                    }
                }
            }
        }
        task.resume()
    }
}