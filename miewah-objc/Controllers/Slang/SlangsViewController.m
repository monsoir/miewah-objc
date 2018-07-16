//
//  SlangsViewController.m
//  miewah-objc
//
//  Created by Christopher on 2018/4/25.
//  Copyright © 2018 wenyongyang. All rights reserved.
//

#import "SlangsViewController.h"
#import "ItemTableViewCell.h"
#import "NotificationBanner.h"
#import "ListLoadMoreFooterView.h"
#import "SlangListViewModel.h"
#import "MiewahSlang.h"
#import "SlangDetailViewController.h"
#import "FoundationConstants.h"

#import "UIConstants.h"

#import "UIColor+Hex.h"
#import "UITableView+AutoRefresh.h"

@interface SlangsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) ListLoadMoreFooterView *footer;

@property (nonatomic, strong) SlangListViewModel *vm;

@end

@interface SlangsViewController (loadMoreFooter)<ListLoadMoreFooterViewDelegate>
@end

@implementation SlangsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationBar];
    [self setupSubviews];
    [self linkSignals];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.vm.items.count <= 0) {
        [self.vm readCache];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#if DEBUG
    NSLog(@"%@ deallocs", [self class]);
#endif
}

- (void)linkSignals {
    @weakify(self);
    
    [self.vm.loadedSuccess subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        void (^_)(void) = ^void() {
            self.footer.status = ListLoadMoreFooterViewStatusNotLoading;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        };
        runOnMainThread(_);
    }];
    
    [self.vm.loadedFailure subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        void (^_)(void) = ^void() {
            [self.refreshControl endRefreshing];
            self.footer.status = ListLoadMoreFooterViewStatusNotLoading;
            [NotificationBanner displayABannerWithTitle:@"请求失败" detail:x style:BannerStyleWarning onViewController:nil];
        };
        runOnMainThread(_);
    }];
    
    [self.vm.readCacheCompleted subscribeCompleted:^{
        @strongify(self);
        void(^_)(void) = ^void() {
            [self.tableView reloadData];
            
            [self.tableView refresh];
            [self actionRefresh:nil];
        };
        runOnMainThread(_);
    }];
}

- (void)setupNavigationBar {
}

- (void)setupSubviews {
    self.tableView.rowHeight = [ItemTableViewCell cellHeight];
    self.tableView.backgroundColor = [UIColor colorWithHexString: @"#f6f6f6"];
    [self.tableView registerClass:[ItemTableViewCell class] forCellReuseIdentifier:[NSString stringWithFormat:@"%@-%@", [ItemTableViewCell reuseIdentifier], NSStringFromClass([self class])]];
    self.tableView.showsVerticalScrollIndicator = YES;
    
    // 设置 tableview 的下拉刷新
    self.tableView.refreshControl = self.refreshControl;
    
    // 设置 tableview 最下面的点击加载
    self.tableView.tableFooterView = self.footer;
}

- (void)actionRefresh:(UIRefreshControl *)sender {
    [self.vm reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MiewahSlang *item = (MiewahSlang *)self.vm.items[indexPath.row];
    NSURL *routeURL = [RouteHelper slangDetailRouteURLOfObjectId:item.objectId item:item.item pronunciation:item.pronunciation otherParams:nil];
    [JLRoutes routeURL:routeURL];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.vm.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@-%@", [ItemTableViewCell reuseIdentifier], NSStringFromClass([self class])];
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    MiewahSlang *slang = (MiewahSlang *)self.vm.items[indexPath.row];
    cell.item = slang.item;
    cell.pronunciation = slang.pronunciation;
    cell.meaning = slang.meaning;
    cell.updateAt = [slang normalFormatUpdatedAt];
    return cell;
}

- (MiewahItemType)miewahItemType {
    return MiewahItemTypeSlang;
}

- (UIRefreshControl *)refreshControl {
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (ListLoadMoreFooterView *)footer {
    if (_footer == nil) {
        _footer = [[ListLoadMoreFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
        _footer.delegate = self;
    }
    return _footer;
}

- (SlangListViewModel *)vm {
    if (_vm == nil) {
        _vm = [[SlangListViewModel alloc] init];
    }
    return _vm;
}

@end

@implementation SlangsViewController(loadMoreFooter)
- (void)footerWillLoadMore:(ListLoadMoreFooterView *)footer {
    [self.vm loadData];
}
@end
