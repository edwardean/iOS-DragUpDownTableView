//
//  KRefreshTableView.m
//  DragList
//
//  Created by Kevin on 12-12-28.
//  Copyright (c) 2012年 Kevin. All rights reserved.
//

#import "KRefreshTableView.h"

@implementation KRefreshTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)dealloc
{    
    [super dealloc];
}

#pragma mark -- 处理下拉，上拉效果  －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//将footer放到table的最后面
- (void) PutFooterAtEnd
{
    CGRect footerFrame = _refreshFooterView.frame;
    CGRect r = CGRectMake(footerFrame.origin.x, self.contentSize.height, self.frame.size.width, footerFrame.size.height);
    
    if (r.origin.y < self.frame.size.height) {
        r.origin.y = self.frame.size.height;
    }
    _refreshFooterView.frame = r;
}

- (void) ShowHeaderAndFooter
{
    if (_refreshHeaderView == nil) {
		_refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height) IsHeader: YES] autorelease];
		_refreshHeaderView.delegate = self;//设置代理
		[self addSubview:_refreshHeaderView];//将刷新控件当作UITableView的子控件
	}
    [_refreshHeaderView refreshLastUpdatedDate];
    
    if (_refreshFooterView == nil) {
		_refreshFooterView = [[[EGORefreshTableHeaderView alloc] initWithFrame:
                              CGRectMake(0, -1000, self.frame.size.width, self.bounds.size.height) IsHeader: NO] autorelease];
		_refreshFooterView.delegate = self;
        [self addSubview:_refreshFooterView];//将刷新控件当作UITableView的子控件
        
        [self PutFooterAtEnd];//调整footer的位置
	}
    [_refreshFooterView refreshLastUpdatedDate];
    
}

- (void) refreshTableData
{
    [self reloadData];
    [self PutFooterAtEnd];
}

//header下拉处理线程结束会调用这个函数
- (void) FinishedLoadMoreHeaderData: (NSNumber*) num
{
    //重新装载数据
    [self reloadData];
    
    [self PutFooterAtEnd];
    
    [_refreshHeaderView refreshLastUpdatedDate];//修改最后更新时间
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    _reloading = NO;
}

//footer上拉处理线程结束会调用这个函数
- (void) FinishedLoadMoreFooterData: (NSNumber*) num
{
    [self reloadData];//重新装载数据
    
    [self PutFooterAtEnd];//将footer放到table的最后    
    [_refreshFooterView refreshLastUpdatedDate];
    
    _reloading = NO;
    [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    
}


//模拟一些数据，用户将header往下拉
- (void) GetMoreHeaderData
{
    @autoreleasepool {
        [self.MyDelegate UpdateData:YES];//调用caller的数据更新回调，这样caller就可以设定需要更新的数据
        
        //更新数据完毕，在主线程里面更新ui
        [self performSelectorOnMainThread:@selector(FinishedLoadMoreHeaderData:) withObject:nil waitUntilDone:YES];
    }
}

//用户将footer往上拉的时候，放一些模拟数据
- (void) GetMoreFooterData
{
    @autoreleasepool {
        int ret = [self.MyDelegate UpdateData:NO];//获取增加的行数
        NSNumber* number = [NSNumber numberWithInt:ret];        
        [self performSelectorOnMainThread:@selector(FinishedLoadMoreFooterData:) withObject:number waitUntilDone:YES];
    }
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //	NSLog(@"header: %@, footer: %@, view: %@", _refreshHeaderView, _refreshFooterView, view);
    
    if (view == _refreshFooterView) {
        NSLog(@"It's footer");
        
        _reloading = YES;//打开刷新标记，防止多个刷新任务同时刷新
        
        //启动一个线程来获取更新数据
        [NSThread detachNewThreadSelector:@selector(GetMoreFooterData) toTarget:self withObject:nil];
    }
    
    if (view == _refreshHeaderView) {
        NSLog(@"It's header");
        
        _reloading = YES;
        
        [NSThread detachNewThreadSelector:@selector(GetMoreHeaderData) toTarget:self withObject:nil];
    }
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // 当前是否有刷新任务在运行，
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // 返回当前时间，这个时间会显示在更新时间
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

//下面2个函数会被caller调用（caller的滚动响应函数里面调用）
//滚动响应，当用户在滚动视图中拉动的时候就会被触发（这里是指table中拉动）
- (void) MyScrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    
    //    NSLog(@"scrollViewDidScroll\n");
}

//告诉代理，滚动视图中的拖拉动作结束了
- (void) MyScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void) InitTable: (id) TableItems
{
    _reloading = NO;
    [self setItems:TableItems];
    
    [self ShowHeaderAndFooter];//创建表头表尾刷新控件
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
