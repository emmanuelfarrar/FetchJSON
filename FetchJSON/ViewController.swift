//
//  ViewController.swift
//  FetchJSON
//
//  Created by Alfred Hanssen on 3/1/16.
//  Copyright © 2016 One Month. All rights reserved.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

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

