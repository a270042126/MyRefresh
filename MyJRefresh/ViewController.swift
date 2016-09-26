//
//  ViewController.swift
//  zhikewang
//
//  Created by gongdadong on 16/9/25.
//  Copyright © 2016年 gongdadong. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var numRows = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        weak var weakSelf = self
        tableView.addRefreshHeaderWithBlock {
            print("header 刷新")
            weakSelf!.perform(#selector(ViewController.headerRefresh), with: nil, afterDelay: 2)
        }
        
        tableView.addRefreshFooterWithBlock {
            print("footer 刷新")
            weakSelf!.perform(#selector(ViewController.footerRefresh), with: nil, afterDelay: 2)
        }
        
        
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 5))
        
        
    }
    
    func headerRefresh() {
        weak var weakSelf = self
        
        weakSelf!.tableView.endHeaderRefreshing()
        
        weakSelf!.numRows = 5
        weakSelf!.tableView.reloadData()
        
        weakSelf!.tableView.resetDataLoad()
    }
    
    func footerRefresh() {
        weak var weakSelf = self
        
        
        weakSelf!.tableView.endFooterRefreshing()
        
        weakSelf!.numRows += 5
        weakSelf!.tableView.reloadData()
        
        if numRows > 200 {
            weakSelf!.tableView.setDataLoadover()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numRows
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "label\((indexPath as NSIndexPath).row)"
        
        return cell
    }
    
    
}


