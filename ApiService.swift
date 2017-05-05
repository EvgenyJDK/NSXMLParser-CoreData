//
//  ApiService.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 24.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation


class ApiService {
    
    
    func getImageURL(rssLink: String , callback: (NSString) ->()) -> Void {
        
        print("ITEM LINK = \(rssLink)")
        
        let url = NSURL(string: rssLink)
        let request = NSURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            if let data = data,
                jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                where error == nil {

/* If rssItem has no image,  defaultImage will be loaded */
                guard jsonString.containsString("article-image center\u{22} src=\u{22}") else {
                    print("THERE IS NO ORIGIN IMAGE - default image will be loaded")
                    return callback(GlobalConstants.defaultImageURL)
                }

/* Parsing rssItem url for image url */
                let imageStartSubStr = "article-image center\" src=\""
                let imageEndSubStr = " width="
                let startIndex = jsonString.rangeOfString(imageStartSubStr).location.advancedBy(27)
                let partImageURL : NSString = (jsonString.substringFromIndex(startIndex))
                let endIndex = partImageURL.rangeOfString(imageEndSubStr).location

/* If rssItem has image extension "svg", it is needed to be converted into the "png" (TODO), meanwhile  defaultImage will be loaded */                
                guard !partImageURL.containsString("svg") else {
                    print("SVG IMAGE")
                    return callback(GlobalConstants.defaultImageURL)
                }
                
                let fullImageURL: NSString = GlobalConstants.imageServerURL + partImageURL.substringToIndex(endIndex.advancedBy(-1))
                
                print("FULL IMAGE URL = \(fullImageURL)")
                callback(fullImageURL)

            } else {
                print("error=\(error!.localizedDescription)")
                callback("")
            }
        }
        task.resume()
       
    }
 
}




