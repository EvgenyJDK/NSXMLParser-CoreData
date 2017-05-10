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
    
    
    var rssListMOC = [NSManagedObject]()
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView: UIView = UIView()

    
    
    
    override func viewDidLoad() {
        
        self.rssTableView.dataSource = self
        self.rssTableView.delegate = self
        
        prepareScreenUI()
        showActivityIndicator()
        getPersistentData()
        
        
        /* If there is no items in CD (1st app launch) >> make rss feed parsing */
        //        guard rssListCont.count == 0 else {
        //            parseService.rssFeedService({
        //                [weak self] in
        //                self?.getPersistentData()
        //                dispatch_async(dispatch_get_main_queue()) {
        //                    self?.rssTableView.reloadData()
        //                    self?.hideActivityIndicator()
        //                }
        //
        //            })
        //            self.hideActivityIndicator()
        //            return self.rssTableView.reloadData()
        //        }
        
        
        //        parseService.rssFeedService(url) {[weak self] text in
        parseService.rssFeedService() {[weak self] in
            self?.getPersistentData()
            dispatch_async(dispatch_get_main_queue()) {
                self?.rssTableView.reloadData()
                self?.hideActivityIndicator()
            }
        }


    }
    
    
    
    func prepareScreenUI() {
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = GlobalConstants.backgroundColor
        
        //        self.rssTableView.separatorColor = UIColor.redColor()
        //        self.rssTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssListMOC.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCellWithIdentifier("RSSCell") as! RSSTableViewCell
        
        
        //        let chevron = UIImage(named: "aftkuaQZ.jpeg")
        //        itemCell.tintColor = UIColor.blueColor()
        //        itemCell.accessoryType = .DisclosureIndicator
        //        itemCell.accessoryType = .Checkmark
        //        itemCell.accessoryView = UIImageView(image: chevron!)
        
        
        
        
        let bottomBorder = CALayer()
        
        bottomBorder.backgroundColor = GlobalConstants.backgroundColor.CGColor
        bottomBorder.frame = CGRectMake(0, itemCell.frame.size.height - 1, itemCell.frame.size.width, 1)
        itemCell.layer.addSublayer(bottomBorder)
        
        
        //        let screenSize = UIScreen.mainScreen().bounds
        //        let separatorHeight = CGFloat(3.0)
        ////        let additionalSeparator = UIView(frame: CGRect(x: 0, y: self.view.size, width: screenSize.width, height: separatorHeight)
        ////        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-separatorHeight, width: screenSize.width, height: separatorHeight))
        //        additionalSeparator.backgroundColor = UIColor.grayColor()
        //        self.addSubview(additionalSeparator)
        
        
        
        
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
        
        
                coreDataService.deleteItem(indexPath.row){[weak self] rssList in
                    print("AFTER DELETING = \(rssList.count)")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.getPersistentData()
                        self?.rssTableView.reloadData()
        
                    }
                }
        
//        let itemURL = rssListCont[indexPath.row].valueForKey("rssLink") as! String
//        
//        guard rssListCont[indexPath.row].valueForKey("rssImage") == nil else {
//            hideActivityIndicator()
//            return self.performSegueWithIdentifier("showItemDetails", sender: indexPath)
//        }
//        
//        apiService.getImageURL(itemURL) { [weak self] imageURL in
//            self?.coreDataService.saveImageToRSSItem(indexPath.row, imageURL: imageURL as String)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                self?.performSegueWithIdentifier("showItemDetails", sender: indexPath)
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
        print("getPersistentData = \(rssListMOC.count)")
        rssListMOC = coreDataService.fetchRSSItems()
        print(rssListMOC.count)
    }

    
    func showActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = UIColor.blackColor()
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            self.activityView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.activityView.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.activityView)
            self.view.addSubview(self.loadingView)
            self.activityView.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.activityView.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    
}

    
    
    
    
    
    
    
    
    
