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

    
    func saveRSSItems (rssEntities : [[String:String]]) {
        
        let rssCheckList = self.fetchRSSItems()

        
        
//        for title in rssEntities {
//            containSameElements(title, rssCheckList)
//        }
        
        
        print("COREDATA ITEMS TO SAVE = \(rssEntities.count)")
        print("COREDATA ITEMS = \(rssCheckList.count)")

/* Iteration throw rssEntities from ParseService result and comparing with [NSManagedObject] for duplicate >> then save to CD */
        var count = 0
        for rssItem in rssEntities {
//            let itemId = formatItemId(rssItem)
            
            print(count++)
            checkForExistInStorage (rssItem, rssCheckList: rssCheckList) { [weak self] (itemExist, rssItem) in
                
                print(rssItem["title"])
                print(rssItem["id"])
                
                if (itemExist) {
                    print("Such Item Already exists")
                } else {

                    let entity = NSEntityDescription.entityForName("RSSItem", inManagedObjectContext: self!.managedContext)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self!.managedContext)
                    
                    item.setValue(rssItem["id"], forKey: "rssID")
                    item.setValue(rssItem["title"], forKey: "rssTitle")
                    item.setValue(rssItem["link"], forKey: "rssLink")
                    item.setValue(rssItem["description"], forKey: "rssDescription")
                    item.setValue(rssItem["pubDate"], forKey: "rssPubDate")
                    
                    do {
                        try self!.managedContext.save()
                    self?.rssListMOC.append(item)
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
    
    
/* http://stackoverflow.com/questions/39161168/how-to-compare-two-array-of-objects */
    
    func checkForExistInStorage (rssItem: [String: String], rssCheckList: [NSManagedObject], callback: (Bool, [String: String])->()) -> Void {
        
        guard rssCheckList.count != 0 else {
            print(rssItem["title"])
            return callback(false, rssItem)
        }
        
        
        print("rssCheckList.COUNT = \(rssCheckList.count)")
//        var ifExist = false
        var count = 1
        for itemToCompare in rssCheckList {
            print("COUNT = \(count)")
            print("CHECKING = \(rssItem["title"])")
            
            
            if rssItem["title"] == (itemToCompare.valueForKey("rssTitle") as? String) {
                callback(true, rssItem)
                break
            }
            else if rssCheckList.count == count {
                callback(false, rssItem)
            }
            

//            if rssCheckList.count == count {
//                callback(false, rssItem)
//            }
            count += 1
        }
        print("FOR END")

    }
    
    
    
    func containSameElements<T: Comparable>(array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }
        return array1.sort() == array2.sort()
    }
    
    
    
    
    func formatItemId(rssItem: [String: String]) -> String {
    

        let rssItemLink = rssItem["link"]
        
        let dateStartIndex = rssItemLink?.startIndex.advancedBy(37)
        let date = rssItemLink?.substringFromIndex(dateStartIndex!)
//        let dateEndIndex = date?.endIndex.advancedBy(-5)
//        let monthDay = date?.substringToIndex(dateEndIndex!)
        let monthDay = date?.substringToIndex((date?.endIndex.advancedBy(-5))!)
        
        let yearStartIndex = rssItemLink?.startIndex.advancedBy(41)
        var year = rssItemLink?.substringFromIndex(yearStartIndex!)
        year?.removeAtIndex((year?.endIndex.advancedBy(-1))!)
        
//        let endInd = yearString?.endIndex.advancedBy(-1)
//        let yearString = yearString?.substringToIndex(endInd!)
        
        print(year)
        
        let itemIdByDate = year! + monthDay!
        
        print(itemIdByDate)
        
        return itemIdByDate
        
        
//        let itemIdFromLink = substr?.insert("a", atIndex: 0)
        
        
        
//        let imageStartSubStr = "?id="
//        let imageEndSubStr = "a"
//        let startIndex = str?.rangeOfString(imageStartSubStr).location
//        
//        
//       let str1 = str?.substringFromIndex(10)
//        
//        
//        let imageStartSubStr = "article-image center\" src=\""
//        let imageEndSubStr = " width="
//        let startIndex = jsonString.rangeOfString(imageStartSubStr).location.advancedBy(27)
//        let partImageURL : NSString = (jsonString.substringFromIndex(startIndex))
//        let endIndex = partImageURL.rangeOfString(imageEndSubStr).location
        
    }
    
    
    
    
    
    func saveImageToRSSItem (itemIndex: Int, imageURL: String) -> NSManagedObject {
    
        let urlString  = NSURL(string: imageURL)
        let data = NSData(contentsOfURL: urlString!)
        self.rssListMOC[itemIndex].setValue(data, forKey: "rssImage")
        
        do {
            try managedContext.save()
            print("saved Item Image to CD")
        }
        catch {
            print("Error! Can't save to CD")
        }
        return rssListMOC[itemIndex]
    }

    
    
    func fetchRSSItems () -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: "RSSItem")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            rssListMOC = results as! [NSManagedObject]
        }
        catch {
            print("error fetch")
        }
        return rssListMOC
    }

    
    func deleteItem (itemIndex: Int, callback: [NSManagedObject] ->()) {
        
        print(itemIndex)
        
        
//         tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        
       
        
        do {
            try managedContext.deleteObject(rssListMOC[itemIndex])
            rssListMOC.removeAtIndex(itemIndex)
            print("deleted from CD")
            callback(rssListMOC)
        }
        catch {
            print("Error! Can't delete from CD")
        }

       

    }
    
}
