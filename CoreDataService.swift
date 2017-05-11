//
//  CoreDataService.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 23.04.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    
  
    var rssListMOC = [NSManagedObject]()
    lazy var managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


    func saveRSSItems (rssEntities : [[String:AnyObject]]) {
        let rssCheckList = self.fetchRSSItems()

        print("ITEMS TO SAVE = \(rssEntities.count)")
        print("ITEMS IN STORAGE = \(rssCheckList.count)")

/* Iteration throw rssEntities from ParseService result and comparing with [NSManagedObject] for duplicate >> then save to CD */

        for rssItem in rssEntities {

            checkForExistInStorage (rssItem, rssCheckList: rssCheckList) { [weak self] (itemExist, rssItem) in

                if (itemExist) {
                    print("Such Item Already exists")
                } else {

                    let entity = NSEntityDescription.entityForName("RSSItem", inManagedObjectContext: self!.managedContext)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self!.managedContext)
                    
                    item.setValue(rssItem["dateID"], forKey: "rssDateID")
                    item.setValue(rssItem["title"], forKey: "rssTitle")
                    item.setValue(rssItem["link"], forKey: "rssLink")
                    item.setValue(rssItem["description"], forKey: "rssDescription")
                    item.setValue(rssItem["pubDate"], forKey: "rssPubDate")
                    
                    do {
                        try self!.managedContext.save()
                    self?.rssListMOC.append(item)
                        print("saved to CD")
                    }
                    catch {
                        print("Error! Can't save to CD")
                    }
                }
            }
        }
    }

    
    func checkForExistInStorage (rssItem: [String: AnyObject], rssCheckList: [NSManagedObject], callback: (Bool, [String: AnyObject])->()) {
        
        guard rssCheckList.count != 0 else {
            return callback(false, rssItem)
        }
        
        for i in 0...rssCheckList.count-1 {
            if rssItem["title"] as? String == (rssCheckList[i].valueForKey("rssTitle") as? String) {
                callback(true, rssItem)
                break
            }
            else if i == rssCheckList.count-1 {
                callback(false, rssItem)
            }
        }
    }
    

    
    func saveImageToRSSItem (itemIndex: Int, imageURL: String) -> NSManagedObject {
    
        let urlString  = NSURL(string: imageURL)
        if let data = NSData(contentsOfURL: urlString!) {
            self.rssListMOC[itemIndex].setValue(data, forKey: "rssImage")
            do {
                try managedContext.save()
                print("saved Item Image to CD")
            }
            catch {
                print("Error! Can't save to CD")
            }
        }
        return rssListMOC[itemIndex]
    }

    
    
    func fetchRSSItems () -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: "RSSItem")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            rssListMOC = results as! [NSManagedObject]
            
/* Sort [NSManagedObject] by rssDateID (similar PubDate) */
            rssListMOC.sortInPlace {
                ($0.0.valueForKey("rssDateID") as? NSDate) > ($0.1.valueForKey("rssDateID") as? NSDate)
            }
        }
        catch {
            print("fetch error")
        }
        return rssListMOC
    }

    
    func deleteItem (itemIndex: Int, callback: [NSManagedObject] ->()) {
        
//        do {
//            try managedContext.deleteObject(rssListMOC[itemIndex])
//            rssListMOC.removeAtIndex(itemIndex)
//            print("deleted from CD")
//            callback(rssListMOC)
//        }
//        catch {
//            print("Error! Can't delete from CD")
//        }
    }
}



extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}
