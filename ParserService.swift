//
//  ParserService.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 21.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit

class  ParserService : NSObject, NSXMLParserDelegate {
    
    var xmlParser: NSXMLParser!
    var rssItemId: String!
    var rssTitle: String!
    var rssLink: String!
    var rssDescription: String!
    var rssPubDate: String!
    var parsedItem:String! = String()
    var itemDictionary: [String: AnyObject]! = Dictionary()
    var rssItemsArray: [[String: String]] = Array()
    
    var rssItem = RSSItem()
    let coreDataService = CoreDataService()
    

    func rssFeedService(callback: () -> Void) {
        
        
        parseFeed(GlobalConstants.rssFeedURL) { () in
            self.coreDataService.saveRSSItems(self.rssItem.rssItemsArray)
            callback()
        }
        
    }

  
//    func rssFeedService(url: String, callback: () -> Void) {
//        
//        parseFeed(url) { () in
//            self.coreDataService.saveRSSItems(self.rssItem.rssItemsArray)
//            callback()
//         }
//        
//    }
    
    
    func parseFeed(url: String, callback: () -> Void) {

        let urlString = NSURL(string: url)
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(rssUrlRequest, queue: queue) {
            (response, data, error) -> Void in
            
            self.xmlParser = NSXMLParser(data: data!)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
            
            callback()
        }
    }

    
// MARK: NSXMLParserDelegate Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "title"{
            rssTitle = String()
            parsedItem = "title"
        }
        if elementName == "link"{
            rssLink = String()
            parsedItem = "link"
        }
        if elementName == "description"{
            rssDescription = String()
            parsedItem = "description"
        }
        if elementName == "pubDate"{
            rssPubDate = String()
            parsedItem = "pubDate"
        }
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if parsedItem == "title"{
            rssTitle = rssTitle + string
            self.rssItem.title = rssTitle + string
        }
        if parsedItem == "link"{
            rssLink = rssLink + string
            self.rssItem.link = rssLink + string
        }
        if parsedItem == "description"{
            rssDescription = rssDescription + string
            self.rssItem.description = rssDescription + string
        }
        if parsedItem == "pubDate"{
            rssPubDate = rssPubDate + string
            self.rssItem.rssPubDate = rssPubDate + string
            
//                        print("RSSPUBDATE = \(rssPubDate)")
////                        let str = "Thu, 20 Apr 2017 11:00:00 PDT"
////                        var dateString = "2014-07-15" // change to your date format yyyy-MM-dd
//                        let dateFormatter = NSDateFormatter()
//                        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
//                        let date = dateFormatter.dateFromString(rssPubDate)
//                        print("DATE = \(date)")
            
            
        }
    }
    
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title"{
            itemDictionary["title"] = rssTitle
            self.rssItem.rssItemDictionary["title"] = rssTitle
        }
        if elementName == "link"{
            itemDictionary["link"] = rssLink
            self.rssItem.rssItemDictionary["link"] = rssLink
        }
        if elementName == "description"{
            itemDictionary["description"] = rssDescription
            self.rssItem.rssItemDictionary["description"] = rssDescription
        }
        if elementName == "pubDate"{
            itemDictionary["pubDate"] = rssPubDate
            self.rssItem.rssItemDictionary["pubDate"] = rssPubDate
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
            let pubDate = dateFormatter.dateFromString(rssPubDate)
            self.rssItem.rssItemDictionary["dateID"] = pubDate
            
            
//            let itemId = formatItemId(self.rssItem.rssItemDictionary["link"]! as! String)
//            self.rssItem.rssItemDictionary["id"] = itemId
            
            self.rssItem.rssItemsArray.append(self.rssItem.rssItemDictionary)
        }
        
    }
    
    
    func parserDidEndDocument(parser: NSXMLParser){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            print("PARSE END = \(self.rssItem.rssItemsArray.count)")

        })
    }
    
    
    
    func formatItemId(rssLink: String) -> String {
        
        let dateStartIndex = rssLink.startIndex.advancedBy(37)
        let date = rssLink.substringFromIndex(dateStartIndex)
        let monthDay = date.substringToIndex(date.endIndex.advancedBy(-5))
        let yearStartIndex = rssLink.startIndex.advancedBy(41)
        var year = rssLink.substringFromIndex(yearStartIndex)
        year.removeAtIndex(year.endIndex.advancedBy(-1))

        let itemIdByDate = year + monthDay
        
/*Fixing not correct ID in rssFeed https://developer.apple.com/news/?id=060142016a */
        if itemIdByDate == "4201606014" {
            return "20160614"
        }
        return itemIdByDate
    }

    
    
}

