//
//  APIClient.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/6/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

class APIClient {
    
    private static var session = NSURLSession.sharedSession()
    
    //MARK: - UDACITY
    static func login (username: String, password: String, completionHandler: (result: AnyObject!, error: NSError?)-> Void)-> NSURLSessionDataTask {
        
        let urlString = "https://www.udacity.com/api/session"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField:  "Content-Type")
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                return completionHandler(result: nil, error: error)
            }
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
            parseJSONData(newData!, completionHandler: completionHandler)
            
        }
      task.resume()
        
        return task
    }
    
    static func getAccountData (account: String, completionHandler:(result: AnyObject!, error: NSError?)->Void)->NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(account)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { 
                return
            }
            if let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) {
            parseJSONData(newData, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    static func logout(completionHandler: (result: AnyObject!, error: NSError?)-> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var cookieToken: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                cookieToken = cookie
            }
        }
        if let cookie = cookieToken {
        request.setValue(cookie.value, forHTTPHeaderField: "XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                return print("ERROR")
            }
            if let newData = data?.subdataWithRange(NSMakeRange(5, (data?.length)! - 5)) {
                parseJSONData(newData, completionHandler: completionHandler)
            }
        
        }
        task.resume()
        
    }
    
    static func parseJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?)-> Void){
        var parsedResult: AnyObject!
        do {
           parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: "\(data)"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONData", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }
    
    //MARK: - PARSE
    
    static func getRequestedData (completionHandler: (success: Bool!, error: NSError?)->Void)->NSURLSessionDataTask {
     
        let params = ["limit": 100,"order":"-updatedAt"] //CITE CODE REVIEW SUGGESTION
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation\(escapedParameters(params))")!)
        request.addValue(Constants.parseAppID, forHTTPHeaderField: Constants.appIDHeader)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return completionHandler(success: false,error: error)
            }
            
            //CITE: TMDBClient
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(success: false, error: nil)
            }
            
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                guard let array = dictionary["results"] as? [[String: AnyObject]] else {
                    return
                }
                completionHandler(success: true,error: nil)
                StudentCollection.studentCollection.getInfo(array)
            }catch{
                print("ERROR IN GETTING JSON OBJECT")
            }
        }
        task.resume()
        return task
    }
    
    static func postInfo (student: StudentInformation, completionHandler: (result: AnyObject!, error: NSError?)-> Void)->NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string:"https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.parseAppID, forHTTPHeaderField: Constants.appIDHeader)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
    
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                return completionHandler(result: nil, error: nil)
            }
            if error != nil {
                return completionHandler(result: nil, error: error!)
            }
            APIClient.parseJSONData(data!, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    
    //CITE: THEMOVIEDB TUTORIAL
    static func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    

    
}