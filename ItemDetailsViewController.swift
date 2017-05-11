//
//  TestController.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 04.05.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPubDate: UILabel!
    @IBOutlet weak var itemDescription: UITextView!
    
    var rssItemDetails: RSSItemDetails?
    
    
    override func viewDidLoad() {

        prepareScreenUI()
        setItemDetails()
        setImageToItemDescription()
    }

    
    func prepareScreenUI() {
        
        self.navigationItem.title = "Apple News"
        navigationController?.navigationBar.barTintColor = GlobalConstants.backgroundColor
        self.view.layer.borderWidth = 5
        self.view.layer.borderColor = GlobalConstants.backgroundColor.CGColor
    }
    
    
    
    func setItemDetails() {
        
        itemTitle.text = self.rssItemDetails!.title
        itemPubDate.text = self.rssItemDetails!.rssPubDate
        itemDescription.text = self.rssItemDetails!.description
    }
    
    
    
    func setImageToItemDescription() {
        
        var itemImg = UIImageView()
        if let data = self.rssItemDetails!.image {
            let img = UIImage(data: data)
            itemImg = UIImageView(image: img!)
            itemImg.setRound()
        }
        let path = UIBezierPath(rect: CGRectMake(0, -7, itemImg.frame.width + 10, itemImg.frame.height))
        itemDescription.textContainer.exclusionPaths = [path]
        itemDescription.addSubview(itemImg)
        itemDescription.sizeToFit()
    }
 
}



extension UIImageView {
    
    func setRound() {
        let radius = CGRectGetWidth(self.frame) / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
    }
}
