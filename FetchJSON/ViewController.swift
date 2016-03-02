//
//  ViewController.swift
//  FetchJSON
//
//  Created by Alfred Hanssen on 3/1/16.
//  Copyright © 2016 One Month. All rights reserved.
//

import UIKit

typealias ResponseClosure = (responseObject: AnyObject?, error: NSError?) -> Void

class ViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.fetchStaffPicks { (responseObject, error) -> Void in
            
            if let responseObject = responseObject
            {
                print(responseObject)
            }
            else if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                assertionFailure("Execution should never reach this point - responseObject and error are mutually exclusive.")
            }
        }
    }
    
    // MARK: Private API
    
    private func fetchStaffPicks(completion: ResponseClosure)
    {
        let URL = NSURL(string: "https://api.vimeo.com/channels/staffpicks/videos")!
        
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        request.addValue("Bearer eeb3566316fc39f535a4276a63d90649", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // Check for an upfront error
                if let error = error
                {
                    completion(responseObject: nil, error: error)
                    
                    return
                }
                
                // Attempt to parse the response data into a JSON object
                var responseObject: AnyObject? = nil
                if let data = data
                {
                    do
                    {
                        responseObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    }
                    catch let error as NSError
                    {
                        completion(responseObject: nil, error: error)
                        
                        return
                    }
                }

                if let response = response as? NSHTTPURLResponse where response.statusCode >= 200 && response.statusCode < 300
                {
                    completion(responseObject: responseObject, error: nil)
                }
                else
                {
                    let error = NSError(domain: "MyCustomDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response."])
                    completion(responseObject: nil, error: error)
                }
            })
        })
        
        task.resume()
    }
}

