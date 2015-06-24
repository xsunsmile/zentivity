//
//  ZendeskClient.swift
//  zentivity
//
//  Created by Hao Sun on 5/20/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import Foundation

class ZendeskClient: NSObject {
    var baseUrlString = "http://volunteer.zd-dev.com"
    var apiString = "api/v1"
    var manager = AFHTTPRequestOperationManager()
    
    class var sharedInstance: ZendeskClient {
        struct Singleton {
            static let instance = ZendeskClient()
        }
        return Singleton.instance
    }
    
    func getWithCompletion(resource: String, params: AnyObject!, completion: (result: AnyObject?, error: NSError?) -> Void) {
        var urlString = String(format: "%@/%@/%@", baseUrlString, apiString, resource)
        println("hitting url \(urlString)")
        manager.GET(urlString, parameters: params, success: { (operation, response) -> Void in
            println("Got response \(response)")
            completion(result: response, error: nil)
        }) { (operation, error) -> Void in
            println("Got error: \(error)")
            completion(result: nil, error: error)
        }
    }
    
    func postWithCompletion(resource: String, params: AnyObject!, completion: (result: AnyObject?, error: NSError?) -> Void) {
        var urlString = String(format: "%@/%@/%@", baseUrlString, apiString, resource)
        println("post to url \(urlString)")
        manager.POST(urlString, parameters: params, success: { (operation, response) -> Void in
            println("Got response \(response)")
            completion(result: response, error: nil)
            }) { (operation, error) -> Void in
                println("Got error: \(error)")
                completion(result: nil, error: error)
        }
    }
}