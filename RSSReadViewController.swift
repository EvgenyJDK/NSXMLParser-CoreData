//
//  ReadViewController.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 05.05.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RSSReadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var rssTableView: UITableView!
    
    let apiService = ApiService ()
    let parseService = ParserService () //xmlserializator, xml data provider
    let coreDataService = CoreDataService () // datastorage datapersistent
    let spinner = ProgressSpin()

    var rssListMOC = [NSManagedObject]()

    
    override func viewDidLoad() {
 
        self.rssTableView.dataSource = self
        self.rssTableView.delegate = self

        getPersistentData()
        prepareScreenUI()
        printTimestamp()
        spinner.showActivityIndicator(self.view)
        setPersistentData()
        
    }

    
    func prepareScreenUI() {
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = GlobalConstants.backgroundColor
  
/* http://stackoverflow.com/questions/30531111/how-do-i-customize-a-uitableview-right-top-and-bottom-border */
        
        rssTableView.backgroundColor = GlobalConstants.backgroundColor
        rssTableView.layer.masksToBounds = true
        rssTableView.layer.borderColor = (GlobalConstants.backgroundColor).CGColor
        rssTableView.layer.borderWidth = 5.0
    }

    
    func printTimestamp() {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .NoStyle)
        currentDateLabel.text = timestamp
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssListMOC.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCellWithIdentifier("RSSCell") as! RSSTableViewCell

//        let bottomBorder = CALayer()
//        bottomBorder.backgroundColor = GlobalConstants.backgroundColor.CGColor
//        bottomBorder.frame = CGRectMake(0, itemCell.frame.size.height - 1, itemCell.frame.size.width, 1)
//        itemCell.layer.addSublayer(bottomBorder)
        
/* http://stackoverflow.com/questions/34454924/set-tableview-cell-corner-radius-swift-2-0 */
        
        itemCell.layer.cornerRadius = 5
        itemCell.layer.borderColor = GlobalConstants.backgroundColor.CGColor
        itemCell.layer.borderWidth = 3 

        itemCell.itemTitle.text = (rssListMOC[indexPath.row].valueForKey("rssTitle")) as? String
        
        let rssDescriptionText = ((rssListMOC[indexPath.row].valueForKey("rssDescription")) as! String)
        if (rssDescriptionText.characters.count > 75) {
            itemCell.itemShortContent.text = rssDescriptionText.substringToIndex(rssDescriptionText.startIndex.advancedBy(70)) + "..."
        }
        else {
            itemCell.itemShortContent.text = rssDescriptionText
        }
        itemCell.itemDateLabel.text = (((rssListMOC[indexPath.row].valueForKey("rssPubDate")) as? String)!)

        return itemCell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let itemURL = rssListMOC[indexPath.row].valueForKey("rssLink") as! String
        
        guard rssListMOC[indexPath.row].valueForKey("rssImage") == nil else {
            self.spinner.hideActivityIndicator()
            return self.performSegueWithIdentifier("showItemDetails", sender: indexPath)
        }
        
        apiService.getImageURL(itemURL) { [weak self] imageURL in
            self?.coreDataService.saveImageToRSSItem(indexPath.row, imageURL: imageURL as String)
            
            dispatch_async(dispatch_get_main_queue()) {
                self?.performSegueWithIdentifier("showItemDetails", sender: indexPath)
            }
        }
        
/* Uncoment to use "delete item" functionality when row selected. Upper block-code with performSegueWithIdentifier have to be commented */

//        coreDataService.deleteItem(indexPath.row){[weak self] rssList in
//            print("AFTER DELETING = \(rssList.count)")
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self?.getPersistentData()
//                self?.rssTableView.reloadData()
//                
//            }
//        }
        
    }
    
    
// MARK: - Navigation. Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let segueItem = RSSItemDetails(object: rssListMOC[sender!.row]) // no good
        let itemDetailsController : ItemDetailsViewController = segue.destinationViewController as! ItemDetailsViewController
        itemDetailsController.rssItemDetails = segueItem
        
    }
    
    
    func getPersistentData() {
        rssListMOC = coreDataService.fetchRSSItems()
        print("getPersistentData = \(rssListMOC.count)")
    }
    
    
    func setPersistentData() {
        
/* If there is no items in CD (1st app launch) >> make rss feed parsing */
//        guard rssListMOC.count == 0 else {
//            parseService.rssFeedService({
//                [weak self] in
//                self?.getPersistentData()
//                dispatch_async(dispatch_get_main_queue()) {
//                    self?.rssTableView.reloadData()
//                    self!.spinner.hideActivityIndicator()
//                }
//                })
//            spinner.hideActivityIndicator()
//            return self.rssTableView.reloadData()
//        }
        
        parseService.rssFeedService() {[weak self] in
            self?.getPersistentData()
            dispatch_async(dispatch_get_main_queue()) {
                self?.rssTableView.reloadData()
                self?.spinner.hideActivityIndicator()
            }
        }
        
    }
    
    
}

    
    
    
    
    
    
    
    
    
