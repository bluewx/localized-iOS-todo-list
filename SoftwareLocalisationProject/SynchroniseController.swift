//
//  SynchroniseController.swift
//  SoftwareLocalisationProject
//
//  Created by Kyle Williamson on 23/04/2015.
//  Copyright (c) 2015 Kyle Williamson. All rights reserved.
//

import UIKit

protocol SynchroniseControllerProtocol: NSURLConnectionDelegate {
    func didReceiveSync(url : NSString)
}

class SynchroniseController {
    
    var delegate: SynchroniseControllerProtocol?
    lazy var data = NSMutableData()
    
    init() {}
    
    func conn(params: String) {
        var url = NSURL(string: "http://todo.placella.com/")
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        var session = NSURLSession.sharedSession()
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var paramsEncoded = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPBody = paramsEncoded

        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var err: NSError
            
            var syncUrl : NSString? = NSString(data: data, encoding:NSUTF8StringEncoding)?
            
            self.delegate?.didReceiveSync(syncUrl!)
        })
        task.resume()
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
    
    func sendNotification(url: NSString) {
        var localNotification = UILocalNotification()
        localNotification.alertBody = NSLocalizedString("notification_body", comment: "Content of the notification")
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.userInfo = ["url" : url]
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
}