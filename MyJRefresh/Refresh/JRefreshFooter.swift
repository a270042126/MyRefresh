//
//  JRefreshFooter.swift
//  zhikewang
//
//  Created by gongdadong on 16/9/25.
//  Copyright © 2016年 gongdadong. All rights reserved.
//

import UIKit

class JRefreshFooter: UIView {

    var refreshStatus:JRefreshFooterStatus?
    
    //private var imageView:UIImageView!
    private var contentLabel:UILabel!
    private var activity:UIActivityIndicatorView!
    
    func setStatus(_ status:JRefreshFooterStatus){
        refreshStatus = status
        switch status {
        case .normal:
            setNomalStatus()
            break
        case .waitRefresh:
            setWaitRefreshStatus()
            break
        case .refreshing:
            setRefreshingStatus()
            break
        case .loadover:
            setLoadoverStatus()
            break
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    private func setUI(){
//        imageView = UIImageView(image:UIImage(named: "lc_refresh_down"))
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(imageView)
        
        contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentLabel)
        
        contentLabel.setContentHuggingPriority(500, for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(1000, for: .horizontal)
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activity)
        
        
        self.addConstraint(NSLayoutConstraint(item: contentLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[contentLabel]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["imageView":imageView,"contentLabel":contentLabel]))
//        self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[activity]-[contentLabel]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["activity":activity,"contentLabel":contentLabel]))
        self.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: contentLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /** 各种状态切换 */
    fileprivate func setNomalStatus() {
        if activity.isAnimating {
            activity.stopAnimating()
        }
        activity.isHidden = true
        contentLabel.text = "上拉加载更多数据"
    }
    
    fileprivate func setWaitRefreshStatus() {
        if activity.isAnimating {
            activity.stopAnimating()
        }
        activity.isHidden = true
        
        contentLabel.text = "松开加载更多数据"
    }
    
    fileprivate func setRefreshingStatus() {
        activity.isHidden = false
        activity.startAnimating()
        
        contentLabel.text = "正在加载更多数据..."
    }
    
    fileprivate func setLoadoverStatus() {
        if activity.isAnimating {
            activity.stopAnimating()
        }
        activity.isHidden = true
        contentLabel.text = "全部加载完毕"
    }

}
