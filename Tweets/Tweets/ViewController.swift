//
//  ViewController.swift
//  Tweets
//
//  Created by Lucas BELVALETTE on 10/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, APITwitterDelegate {
    @IBOutlet weak var tableView: UITableView!

    var api: APIController?
    var delegate :APITwitterDelegate?
    var tweets: [Tweet] = []
    
    func getAPITwitterToken () {
        let BEARER = ((Key.CUSTOMER_KEY + ":" + Key.CUSTOMER_SECRET).dataUsingEncoding(NSUTF8StringEncoding))!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let url = NSURL(string: "https://api.twitter.com/oauth2/token")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("Basic " + BEARER,forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "grant_type=client_credentials".dataUsingEncoding(NSUTF8StringEncoding)
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
                        self.api = APIController.init(delegate: self.delegate, token: dic.valueForKey("access_token") as! String)
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
    
    func searchTweets(str: String) {
        self.tweets = []
        self.api!.requestTwitterAPI(str)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTweets(textField.text!)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        getAPITwitterToken()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row % 2 == 0 {
         cell.backgroundColor = UIColor.lightGrayColor()
        }
        else {
         cell.backgroundColor = UIColor.whiteColor()
        }
        
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TableViewCell
        let dateString = tweets[indexPath.row].date
        let len = dateString.characters.count
        cell.dateLabel.text = (dateString as NSString).substringToIndex(len - 14)
        cell.tweetLabel.text = tweets[indexPath.row].text
        cell.nameLabel.text = tweets[indexPath.row].name
        return cell
    }
    
    func handleTweet(tweets: [Tweet]) {
        self.tweets = tweets
        self.tableView.reloadData()
    }
    
    func handleError(error: NSError) {
        let alertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

