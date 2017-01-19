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
        let BEARER = ((Key.CUSTOMER_KEY + ":" + Key.CUSTOMER_SECRET).data(using: String.Encoding.utf8))!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url = URL(string: "https://api.twitter.com/oauth2/token")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Basic " + BEARER,forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
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
                        self.api = APIController.init(delegate: self.delegate, token: dic.value(forKey: "access_token") as! String)
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
    
    func searchTweets(_ str: String) {
        self.tweets = []
        self.api!.requestTwitterAPI(str)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTweets(textField.text!)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        getAPITwitterToken()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row % 2 == 0 {
         cell.backgroundColor = UIColor.lightGray
        }
        else {
         cell.backgroundColor = UIColor.white
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TableViewCell
        let dateString = tweets[indexPath.row].date
        let len = dateString.characters.count
        cell.dateLabel.text = (dateString as NSString).substring(to: len - 14)
        cell.tweetLabel.text = tweets[indexPath.row].text
        cell.nameLabel.text = tweets[indexPath.row].name
        return cell
    }
    
    func handleTweet(_ tweets: [Tweet]) {
        self.tweets = tweets
        self.tableView.reloadData()
    }
    
    func handleError(_ error: NSError) {
        let alertController = UIAlertController(title: "Error", message:error.localizedDescription , preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

