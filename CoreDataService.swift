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
    
    var rssList = [NSManagedObject]()
    lazy var managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    func saveRSSItems (rssEntities : [[String:String]]) {
        
        let rssCheckList = self.fetchRSSItems()
        print("COREDATA ITEMS = \(rssCheckList.count)")

/* Iteration throw rssEntities from ParseService result and comparing with [NSManagedObject] for duplicate >> then save to CD */
        for rssItem in rssEntities {
            checkForExistInStorage (rssItem, rssCheckList: rssCheckList) { [weak self] itemExist in
                
                if (itemExist) {
                    print("Such Item Already exists")
                } else {

                    let entity = NSEntityDescription.entityForName("RSSItem", inManagedObjectContext: self!.managedContext)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self!.managedContext)
                    
                    item.setValue(rssItem["title"], forKey: "rssTitle")
                    item.setValue(rssItem["link"], forKey: "rssURL")
                    item.setValue(rssItem["description"], forKey: "rssDescription")
                    item.setValue(rssItem["pubDate"], forKey: "rssPubDate")
                    
                    do {
                        try self!.managedContext.save()
                    self?.rssList.append(item)
//                        self!.rssList.insert(item, atIndex: 0)
                        print("saved to CD")
                    }
                    catch {
                        print("Error! Can't save to CD")
                    }
                }
            }
        }
    }
    
    
    
    func checkForExistInStorage (rssItem: [String: String], rssCheckList: [NSManagedObject], callback: (Bool)->()) -> Void {
        
        guard rssCheckList.count != 0 else {
            return callback(false)
        }
        
        for checkItem in rssCheckList {
            if (rssItem["title"] == (checkItem.valueForKey("rssTitle") as? String))  {
                callback(true)
                break
            }
        }
    }
    
    
    
    
    func saveImageToRSSItem (itemIndex: Int, imageURL: String) -> NSManagedObject {
    
        let urlString  = NSURL(string: imageURL)
        let data = NSData(contentsOfURL: urlString!)
        self.rssList[itemIndex].setValue(data, forKey: "rssImage")
        
        do {
            try managedContext.save()
            print("saved Item Image to CD")
        }
        catch {
            print("Error! Can't save to CD")
        }
        return rssList[itemIndex]
    }

    
    
    func fetchRSSItems () -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: "RSSItem")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            rssList = results as! [NSManagedObject]
        }
        catch {
            print("error fetch")
        }
        return rssList
    }

    
    func deleteItem (itemIndex: Int, callback: [NSManagedObject] ->()) {
        
        
        do {
            try managedContext.deleteObject(rssList[itemIndex])
            rssList.removeAtIndex(itemIndex)
            print("deleted from CD")
            callback(rssList)
        }
        catch {
            print("Error! Can't delete from CD")
        }

        

    }
    
}
