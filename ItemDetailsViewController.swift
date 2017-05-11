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
   
        
    }

    
    func prepareScreenUI() {
        
        self.navigationItem.title = "Apple News"
        navigationController?.navigationBar.barTintColor = GlobalConstants.backgroundColor
        
        self.view.layer.borderWidth = 5
        self.view.layer.borderColor = GlobalConstants.backgroundColor.CGColor
        
        
//        itemScrollView.backgroundColor = GlobalConstants.backgroundColor
//        itemScrollView.layer.masksToBounds = true
//        itemScrollView.layer.borderColor = (GlobalConstants.backgroundColor).CGColor
//        itemScrollView.layer.borderWidth = 5.0
        
//        CGRect frame = itemDescription.frame;
//        frame.size.height = _textView.contentSize.height;
//        _textView.frame = frame;
        
        
        itemTitle.text = self.rssItemDetails!.title
        itemPubDate.text = self.rssItemDetails!.rssPubDate
        itemDescription.text = self.rssItemDetails!.description

        settingImageToItemDescription()
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
//        let contentSize = self.itemDescription.sizeThatFits(self.itemDescription.bounds.size)
//        var frame = self.itemDescription.frame
//        frame.size.height = contentSize.height
//        self.itemDescription.frame = frame
//        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.itemDescription, attribute: .Height, relatedBy: .Equal, toItem: self.itemDescription, attribute: .Width, multiplier: self.itemDescription.bounds.height/self.itemDescription.bounds.width, constant: 1)
        self.itemDescription.addConstraint(aspectRatioTextViewConstraint)
        
    }
    
    
    
    
    
    
    func settingImageToItemDescription() {
        
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
