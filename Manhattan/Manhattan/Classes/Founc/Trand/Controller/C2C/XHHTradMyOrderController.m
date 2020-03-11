//
//  XHHTradMyOrderController.m
//  FuturePurse
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHTradMyOrderController.h"
#import "XHHTradOrderBuyDetailController.h"
#import "XHHTradOrderSellDetailController.h"
#import "XHHTSBDetailCell.h"
#import "XHHPublicNavView.h"
#import "XHHC2CMyOrderModel.h"
static NSString *cellIndienfiter = @"XHHTSBDetailCell";
@interface XHHTradMyOrderController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView  *tableView;

@property (strong, nonatomic) NSMutableArray      *dataArray;

@property (nonatomic , strong) XHHPublicNavView           *navView;

@end

@implementation XHHTradMyOrderController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCanel) name:@"ORDERCANLE" object:nil];
}
-(void)orderCanel{
    [self.tableView.mj_header beginRefreshing];
}
-(void)zh_setupUI{
    
    
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
    }];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"我的订单" image:@"public_nav_leftBack"];
    }
    return _navView;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 110;
        [_tableView setSeparatorColor:LineCorlor];
        _tableView.backgroundColor = bgColor;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHTSBDetailCell" bundle:nil] forCellReuseIdentifier:cellIndienfiter];
        [self setupRefreshWithView:_tableView refreshHeadAction:@selector(headRefresh) refreshFooterAction:@selector(footRefresh)];
    }
    return _tableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHTSBDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndienfiter];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.buysmbloName = self.buySmbolName;
    cell.tradtype = self.tradType;
    if (self.dataArray.count > indexPath.row)
    {
        cell.orderModel = self.dataArray[indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHC2CMyOrderModel *orderModel = self.dataArray[indexPath.row];
    if (self.tradType == C2CTradTypeBuy)
    {
        XHHTradOrderBuyDetailController *vc = [[XHHTradOrderBuyDetailController alloc] init];
        vc.orderModel = orderModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (self.tradType == C2CTradTypeSell)
    {
        XHHTradOrderSellDetailController *vc = [[XHHTradOrderSellDetailController alloc] init];
        vc.orderModel = orderModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}
-(void)headRefresh{
    [self requestMyOrderList:YES];
}
-(void)footRefresh{
    [self requestMyOrderList:NO];
}
-(void)requestMyOrderList:(BOOL)isRefresh
{
    int page = 0;
    if (isRefresh == NO) {
        page = (int) ceil(self.dataArray.count/10.0f) + 1;
    }
    int type = 0;
    if (self.tradType == C2CTradTypeBuy) {
        type = 1;
    }else
    {
        type = 2;
    }
    
    
    @weakify(self);
    [ChZHomeRequest requestC2CMyOrdersUid:[APPControl sharedAPPControl].user.fid
                                     page:page
                                     type:type
                             successBlock:^(id dataSource)
     {
         @strongify(self);
         if (isRefresh) [self.dataArray removeAllObjects];
         NSArray *tempArray = dataSource;
         if (tempArray) {
             [self.dataArray addObjectsFromArray:tempArray];
         }
         [self.tableView reloadData];
         [self.tableView.mj_header endRefreshing];
         [self.tableView.mj_footer endRefreshing];
     } errorBlock:^(int code, NSString *error)
     {
         @strongify(self);
         ChZ_MBError(error);
         [self.tableView.mj_header endRefreshing];
         [self.tableView.mj_footer endRefreshing];
     }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ORDERCANLE" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
