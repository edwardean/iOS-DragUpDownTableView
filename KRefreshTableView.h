//
//  KRefreshTableView.h
//  DragList
//
//  Created by Kevin on 12-12-28.
//  Copyright (c) 2012年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@protocol DataUpdateCallback <NSObject>//定义一个回调，数据更新由调用者提供

@required
- (int) UpdateData: (BOOL) header;

@end

@interface KRefreshTableView : UITableView <EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;//表头刷新
    EGORefreshTableHeaderView *_refreshFooterView;//表尾刷新
    
    
	BOOL _reloading;
}

@property(assign, nonatomic) id<DataUpdateCallback> MyDelegate;//调用者,通过这个调用caller提供的数据更新回调
@property(assign, nonatomic) id Items;//指向调用者的数据，通常是一个NSMutableArray，可以得到一些数据信息

- (void) InitTable: (id) TableItems;//初始化
- (void) MyScrollViewDidScroll:(UIScrollView *)scrollView;
- (void) MyScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void) refreshTableData;

@end
