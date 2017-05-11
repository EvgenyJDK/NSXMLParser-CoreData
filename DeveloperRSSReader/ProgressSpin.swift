//
//  ProgressSpin.swift
//  DeveloperRSSReader
//
//  Created by Administrator on 10.05.17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import UIKit

struct ProgressSpin {
    
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView: UIView = UIView()

    
    func showActivityIndicator(view: UIView) -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = view.center
            self.loadingView.backgroundColor = UIColor.blackColor()
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10

            self.activityView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.activityView.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.activityView)
            view.addSubview(self.loadingView)
            self.activityView.startAnimating()
        }
    }
    
    func hideActivityIndicator() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.activityView.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
}