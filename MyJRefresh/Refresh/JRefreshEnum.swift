//
//  JRefreshEnum.swift
//  zhikewang
//
//  Created by gongdadong on 16/9/25.
//  Copyright © 2016年 gongdadong. All rights reserved.
//

/** Header 刷新状态 */
enum JRefreshHeaderStatus {
    case normal,
    waitRefresh,
    refreshing
}
/** Footer 刷新状态 */
enum JRefreshFooterStatus {
    case normal,
    waitRefresh,
    refreshing,
    loadover
}
/** 当前刷新对象 */
enum JRefreshObject {
    case none,
    header,footer
}
