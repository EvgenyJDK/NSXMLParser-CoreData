//
//  RSSItem.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 20.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

struct  RSSItem {
    
    var itemId: String = ""
    var title : String = ""
    var link : String = ""
    var description : String = ""
    var rssItemDictionary: [String:String]! = Dictionary()
    var rssItemsArray:[[String:String]]! = Array()
    var rssPubDate : String!
   
    var image: NSData!

    
}