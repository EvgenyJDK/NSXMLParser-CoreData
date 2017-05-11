//
//  RSSTableViewCell.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 19.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class  RSSTableViewCell: UITableViewCell {
   
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemShortContent: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    
    
    func setUI() {
        self.layer.cornerRadius = 5
        self.layer.borderColor = GlobalConstants.backgroundColor.CGColor
        self.layer.borderWidth = 3
    }
    
    
    func setRSSFeedData(moc: NSManagedObject) {
        self.itemTitle.text = (moc.valueForKey("rssTitle")) as? String
        
        let rssDescriptionText = ((moc.valueForKey("rssDescription")) as! String)
        if (rssDescriptionText.characters.count > 75) {
            self.itemShortContent.text = rssDescriptionText.substringToIndex(rssDescriptionText.startIndex.advancedBy(70)) + "..."
        }
        else {
            self.itemShortContent.text = rssDescriptionText
        }
        self.itemDateLabel.text = (((moc.valueForKey("rssPubDate")) as? String)!)
    }
    
}