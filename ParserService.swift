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

    
    func parseFeed(url: String, callback: () -> Void) {

        let urlString = NSURL(string: url)
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(rssUrlRequest, queue: queue) {
            (response, data, error) -> Void in
            
            if let dataToParse = data {
                self.xmlParser = NSXMLParser(data: dataToParse)
                self.xmlParser.delegate = self
                self.xmlParser.parse()
            }
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

            self.rssItem.rssItemsArray.append(self.rssItem.rssItemDictionary)
        }
    }
    
    
    func parserDidEndDocument(parser: NSXMLParser){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

        })
    }
}

