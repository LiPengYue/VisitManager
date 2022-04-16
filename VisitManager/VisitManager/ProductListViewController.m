//
//  ProductViewController.m
//  VisitManager
//
//  Created by 李鹏跃 on 2022/4/16.
//

#import "ProductListViewController.h"
#import "VisityBrowsingHistoryManager.h"
@interface ProductListViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    CGFloat y = self.navigationController.navigationBar.frame.size.height;
    self.tableView.frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y);
    // 创建并设置浏览历史最大长度
    [VisityBrowsingHistoryManager createWithCacheMaxCount:5];
    NSTimeInterval currentTime = [[NSDate date]timeIntervalSince1970];
    [VisityBrowsingHistoryManager checkNodeIsQualifiedWithBlock:^BOOL(VisityBrowsingHistoryNode * _Nonnull node) {
        // 如果超过10秒则超时
        return currentTime - node.timeInterval < 20;
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cellID"];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    NSString *key = @(indexPath.row).stringValue;
    BOOL isVisited = [VisityBrowsingHistoryManager checkNodeIsQualifiedWithKey:key?:@""];
    NSString *cellTitle = key;
    if (isVisited) {
        VisityBrowsingHistoryNode *node = [[VisityBrowsingHistoryManager manager] getNodeWithKey:key];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"dd日mm分ss秒";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:node.timeInterval];
        NSString *dateStr = [formatter stringFromDate:date];
        cell.textLabel.textColor = UIColor.redColor;
        cellTitle = [NSString stringWithFormat:@"%@ -> 加入时间:%@",key,dateStr];
    }else{
        cell.textLabel.textColor = UIColor.blackColor;
        cellTitle = key;
    }
    cell.textLabel.text = cellTitle;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = @(indexPath.row).stringValue;
    [[VisityBrowsingHistoryManager manager] visitWithKey:key?:@""];
    [self.tableView reloadData];
}
@end
