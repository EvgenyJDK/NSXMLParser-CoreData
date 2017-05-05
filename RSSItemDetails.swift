//
//  RSSItemDetails.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 25.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

struct RSSItemDetails {
    
    var title : String!
    var description : String!
    var rssPubDate : String!
    var url: String!
    var image: NSData?
    
    
    init (object: NSManagedObject) {
        
        self.title = object.valueForKey("rssTitle") as? String
        self.rssPubDate = object.valueForKey("rssPubDate") as? String
        self.description = (object.valueForKey("rssDescription") as? String)!
        self.url = object.valueForKey("rssURL") as? String
        
        if let imageData = object.valueForKey("rssImage") as? NSData {
            self.image = imageData
        }
   
    }
   
}