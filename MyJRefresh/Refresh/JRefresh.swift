//
//  Refresh.swift
//  zhikewang
//
//  Created by gongdadong on 16/9/25.
//  @escaping 逃逸闭包
//逃逸的闭包常用于异步的操作，这类函数会在异步操作开始之后立刻返回，但是闭包直到异步操作结束后才会被调用。例如这个闭包是异步处理一个网络请求，只有当请求结束后，闭包的生命周期才结束。当闭包作为函数的参数传入时，很有可能这个闭包在函数返回之后才会被执行。
//

import UIKit

private var jHeaderBlock:(()->Void)?
private var jFooterBlock:(()->Void)?
private var header:JRefreshHeader?
private var footer:JRefreshFooter?
private var footerView:UIView?
private var refreshObj = JRefreshObject.header
private var lastRefreshObj = JRefreshObject.header

//MARK: /** Header 相关 */

extension UIScrollView{
    /** 添加下拉刷新 */
    func addRefreshHeaderWithBlock(_ refreshBlock:@escaping ()->Void){
        /** 添加header */
        weak var weakSelf = self
        
        header = JRefreshHeader()
        header?.center = JRefreshHeaderCenter
        
        let headerView = UIView(frame: CGRect(x: JRefreshHeaderX, y: JRefreshHeaderY, width: JRefreshScreenWidth, height: JRefreshHeaderHeight))
        header?.backgroundColor = UIColor.clear
        headerView.addSubview(header!)
        weakSelf?.addSubview(headerView)
        
        /** 设置代理信息 */
        weakSelf?.delegate = weakSelf
        ///** 设置拖拽 */
        weakSelf?.panGestureRecognizer.addTarget(weakSelf, action: #selector(UIScrollView.scrollviewDragging(_:)))
        
        jHeaderBlock = refreshBlock
    }
    
//    /** header 刷新状态 */
//    fileprivate func isHeaderRefreshing() -> Bool{
//
//        return header?.refresgStatus == JRefreshHeaderStatus.refreshing
//    }
    
    /** header 结束刷新 */
    func endHeaderRefreshing(){
        weak var weakSelf = self
        
        if lastRefreshObj == JRefreshObject.header{
            let offset = -weakSelf!.contentInset.top
            weakSelf?.setContentOffset(CGPoint(x:0,y:offset), animated: true)
        }
        header?.setStatus(JRefreshHeaderStatus.normal)
        
        lastRefreshObj = JRefreshObject.header
        
    }
}


//MARK: /** Footer 相关 */

extension UIScrollView{
   /***添加上拉刷新 **/
    func addRefreshFooterWithBlock(_ refreshBlock:@escaping ()->Void){
        /** 添加footer */
        weak var weakSelf = self
        footer = JRefreshFooter()
        footer?.center = JRefreshFooterCenter
        
        footerView = UIView(frame: CGRect(x: JRefreshFooterX, y: weakSelf!.contentSize.height, width: JRefreshScreenWidth, height: JRefreshFooterHeight))
        footerView?.backgroundColor = UIColor.clear
        
        footerView?.addSubview(footer!)
        footerView?.isHidden = true
        weakSelf?.addSubview(footerView!)
        
        /** 设置代理信息**/
        weakSelf?.delegate = weakSelf
        weakSelf?.panGestureRecognizer.addTarget(weakSelf!, action: #selector(UIScrollView.scrollviewDragging(_:)))
        
        jFooterBlock = refreshBlock
    }
    
    /** footer 刷新状态 */
//    fileprivate func isFooterRefreshing() -> Bool{
//        return footer?.refreshStatus == JRefreshFooterStatus.refreshing
//    }
//    
    /** footer 结束刷新 */
    func endFooterRefreshing(){
        weak var weakSelf = self
        
//        guard !weakSelf!.isFooterRefreshing() else {
//            return
//        }
        
        let size = weakSelf!.contentSize
        weakSelf?.contentSize = CGSize(width: size.width, height: size.height - JRefreshFooterHeight)
        
        /** 1、数据没有充满屏幕
         2、数据已经填充满屏幕 **/
        
        if size.height < weakSelf!.bounds.size.height - weakSelf!.contentInset.top - weakSelf!.contentInset.bottom - JRefreshFooterHeight{
             let offset = -weakSelf!.contentInset.top
            weakSelf?.setContentOffset(CGPoint(x:0, y:offset), animated: true)
        }else{
            let offset = weakSelf!.contentSize.height - weakSelf!.bounds.size.height + weakSelf!.contentInset.bottom
            weakSelf?.setContentOffset(CGPoint(x:0, y:offset), animated: true)
        }
        
        footer?.setStatus(JRefreshFooterStatus.normal)
        footerView?.isHidden = true
        lastRefreshObj = JRefreshObject.footer
    }
    
}

extension UIScrollView{
    //MARK: /** 数据加载完毕状态 **/
    func setDataLoadover(){
        weak var weakSelf = self
        let size = weakSelf!.contentSize
        footerView?.isHidden = true
        footerView?.frame = CGRect(x: JRefreshFooterX, y: size.height, width: JRefreshScreenWidth, height: JRefreshFooterHeight)
        
        weakSelf?.contentSize = CGSize(width: size.width, height: size.height + JRefreshFooterHeight)
        footer?.setStatus(JRefreshFooterStatus.loadover)
    }
    
    /** 初始化状态 **/
    func resetDataLoad(){
        footerView?.isHidden = true
        footer?.setStatus(JRefreshFooterStatus.normal)
    }
    
}

//MARK: 滑动监测
extension UIScrollView:UIScrollViewDelegate{
    
    /** 滑动相关 */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        let scrollHeight = scrollView.bounds.size.height
        let inset = scrollView.contentInset
        var currentOffset = offset + scrollHeight - inset.bottom
        let maxinumOffset = scrollView.contentSize.height
        
         /** 数据未充满屏幕的情况 **/
        if maxinumOffset < scrollHeight{
            currentOffset = offset + maxinumOffset - inset.bottom
        }
        
        if offset < -scrollView.contentInset.top{
            /** 下拉刷新 */
            scrollHeader(offset)
            refreshObj = JRefreshObject.header
        }else if currentOffset - maxinumOffset > -scrollView.contentInset.top{
            /** 上拉刷新 */
            guard footer?.refreshStatus != JRefreshFooterStatus.loadover else {
                return
            }
            
            scrollFooter(currentOffset - maxinumOffset)
            refreshObj = JRefreshObject.footer
        }else{
            /**无刷新对象 **/
            refreshObj = JRefreshObject.none
        }
    }
    
    
    fileprivate func scrollHeader(_ offset:CGFloat){
        guard header!.refresgStatus != JRefreshHeaderStatus.refreshing else {
            return
        }
        
        if offset < -JRefreshHeaderHeight - contentInset.top {
            header?.setStatus(JRefreshHeaderStatus.waitRefresh)
        }else{
            header?.setStatus(JRefreshHeaderStatus.normal)
        }
    }
    
    fileprivate func scrollFooter(_ offset:CGFloat){
        weak var weakSelf = self
        guard footer?.refreshStatus != JRefreshFooterStatus.refreshing else {
            return
        }
        
        footerView?.frame = CGRect(x: JRefreshFooterX, y: weakSelf!.contentSize.height, width: JRefreshScreenWidth, height: JRefreshFooterHeight)
        footerView?.isHidden = false
        if offset > JRefreshFooterHeight - weakSelf!.contentInset.top { //
            footer?.setStatus(JRefreshFooterStatus.waitRefresh)
        }else{
            footer?.setStatus(JRefreshFooterStatus.normal)
        }
    }
    
    /** 拖拽相关 */
    func scrollviewDragging(_ pan :UIPanGestureRecognizer){
        if pan.state == .ended{ //拖拽结束
            if refreshObj == JRefreshObject.header{
                draggHeader()
            }else if refreshObj == JRefreshObject.footer{
                draggFooter()
            }
        }
    }
    
    //下拉
    fileprivate func draggHeader(){
        weak var weakSelf = self
      
        let offset = -weakSelf!.contentInset.top - JRefreshHeaderHeight
        
        if header?.refresgStatus == JRefreshHeaderStatus.waitRefresh{
            weakSelf?.setContentOffset(CGPoint(x:0,y:offset), animated: true)
            header?.setStatus(JRefreshHeaderStatus.refreshing)
            jHeaderBlock?()
        }else if header?.refresgStatus == JRefreshHeaderStatus.refreshing{
            weakSelf?.setContentOffset(CGPoint(x:0, y:offset), animated: true)
        }
        
    }
    
    //上拉
    fileprivate func draggFooter(){
        weak var weakSelf = self
        
        if footer?.refreshStatus == JRefreshFooterStatus.waitRefresh{
            /** 设置scroll的contentsize 以及滑动offset **/
            let size = weakSelf!.contentSize
            weakSelf?.contentSize = CGSize(width: size.width, height: size.height + JRefreshFooterHeight)
            footerView?.frame.origin.y = weakSelf!.contentSize.height - JRefreshFooterHeight
            /** 1、数据没有充满屏幕
             2、数据已经填充满屏幕
             **/
            
            if size.height < weakSelf!.bounds.size.height - weakSelf!.contentInset.top - weakSelf!.contentInset.bottom - JRefreshFooterHeight{
                weakSelf?.setContentOffset(CGPoint(x:0, y:-weakSelf!.contentInset.top), animated: true)
            }else{
                let offset = weakSelf!.contentSize.height - weakSelf!.bounds.size.height + weakSelf!.contentInset.bottom
                weakSelf?.setContentOffset(CGPoint(x:0, y:offset), animated: true)
            }
            
        }
           /** 切换状态 **/
        footer?.setStatus(JRefreshFooterStatus.refreshing)
        jFooterBlock?()
    }
}


















