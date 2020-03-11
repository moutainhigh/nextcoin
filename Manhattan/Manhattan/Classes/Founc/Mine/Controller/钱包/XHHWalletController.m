//
//  XHHWalletController.m
//  Manhattan
//
//  Created by Apple on 2018/8/16.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHWalletController.h"

#import "XHHPublicNavView.h"

#import "XHHWalletCell.h"

#import "XHHWalletHeadView.h"

#import "ChZScanQRController.h"

#import "XHHWalletAddController.h"

#import "XHHPayRecordController.h"
#import "XHHWalletHideCoinList.h"

static NSString *cellIndeifier = @"XHHWalletCell";
@interface XHHWalletController ()<UITableViewDelegate,UITableViewDataSource,XHHPublicNavViewProtocol>

@property (nonatomic , strong) XHHPublicNavView           *navView;

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) XHHWalletHeadView *headView;

@property (nonatomic , strong) NSArray *dataArray;

@property (nonatomic, strong) NSArray  *dataSource;

@property (nonatomic , strong) NSArray *hideArray;

@property (nonatomic , strong) NSArray *allCoinArray;

@property (nonatomic, strong) NSTimer  *timer;

@end

@implementation XHHWalletController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    
    [self requestHideCoinList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thtountSuccess) name:@"THROUNTCOINSUCCESS" object:nil];
    // Do any additional setup after loading the view.
}
-(void)thtountSuccess{
    [self.tableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.timer == nil)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(_runLoopRequest) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.timer && self.timer.isValid)
    {
        [self.timer invalidate];
    }
    self.timer = nil;
}
-(void)viewDidLayoutSubviews{
    self.headView.frame = CGRectMake(0, 0, ChZ_WIDTH, 174);
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
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-navHeight);
    }];
}

-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"钱包" image:@"public_nav_leftBack"];
//        [_navView setrightButtonTitles:nil images:@[@"mine_wallet_add",@"mine_wallet_sao"]];
        [_navView setrightButtonTitles:nil images:@[@"mine_wallet_add"]];
        _navView.rightOneWithd.constant = 44;
        _navView.rightTwoWithd.constant = 44;
        _navView.delegete = self;
    }
    return _navView;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 96 ;
        [_tableView setSeparatorColor:[UIColor clearColor]];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setTableHeaderView:self.headView];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHWalletCell" bundle:nil] forCellReuseIdentifier:cellIndeifier];
        [self setupRefreshWithView:self.tableView refreshHeadAction:@selector(_setupData) refreshFooterAction:nil];
    }
    return _tableView;
}
-(XHHWalletHeadView *)headView{
    if (!_headView) {
        _headView = [[[NSBundle mainBundle] loadNibNamed:@"XHHWalletHeadView" owner:nil options:nil] lastObject];
    }
    return _headView;
}
-(void)rightButtonActionIndex:(NSInteger)index{
//    if (index == 2)
//    {
//        ChZScanQRController *vc = [ChZScanQRController initWithStoryboard:@"Scan"];;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
        XHHWalletAddController *vc = [[XHHWalletAddController alloc] init];
        vc.walletCoinList = self.allCoinArray;
        @weakify(self);
        vc.callBackBlock = ^(id Obj)
        {
            @strongify(self);
            [self requestHideCoinList];
        };
        [self.navigationController pushViewController:vc animated:YES];
//    }
}
#pragma tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndeifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(self.dataSource.count > indexPath.row)
    {
        WalletListModel *model = self.dataSource[indexPath.row];
        cell.model = model;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletListModel *model = self.dataSource[indexPath.row];
    XHHPayRecordController *vc = [[XHHPayRecordController alloc] init];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)requestHideCoinList{
    @weakify(self);
    [WalletNetWorkControl requestHideCoinListsuccessBlock:^(id dataSource)
     {
         @strongify(self);
         self.hideArray = dataSource;
         [self.tableView.mj_header beginRefreshing];
         
     } errorBlock:^(int code, NSString *error)
     {
         [self.tableView.mj_header beginRefreshing];
         ChZ_DebugLog(@"%@--",error);
     }];
}
- (void)_setupData
{
    ChZ_Weak
    if (self.dataSource == nil) {
        ChZ_MBMsg(nil)
    }
    [WalletNetWorkControl requestWalletListsuccessBlock:^(id dataSource)
     {
         ChZ_Strong
         if (_strongSelf.dataSource == nil)
         {
             ChZ_MBDismss
         }
         if (self.hideArray.count)
         {
             NSMutableArray *emptyArray = [NSMutableArray array];
             for(WalletListModel *model in dataSource)
             {
                 for(int i = 0; i < self.hideArray.count; i ++)
                 {
                     XHHWalletHideCoinList *coinModel = self.hideArray[i];
                     if([model.coinName isEqualToString:coinModel.coin_name])
                     {
                         break;
                     }
                     if(i == self.hideArray.count - 1)
                     {
                         [emptyArray addObject:model];
                     }
                 }
             }
             _strongSelf.dataSource = emptyArray;
         }else
         {
             _strongSelf.dataSource = dataSource;
         }
         _strongSelf.allCoinArray = dataSource;
         [_strongSelf.tableView reloadData];
         [_strongSelf.tableView.mj_header endRefreshing];
     } errorBlock:^(int code, NSString *error)
     {
         ChZ_Strong
         ChZ_MBDismssError(error)
         [_strongSelf.tableView.mj_header endRefreshing];
         if (code == kv_TokenExpired)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [[APPControl sharedAPPControl]toLogin];
             });
         }
     }];
}
- (void)_runLoopRequest
{
    
    
    NSArray *listArray = [APPControl sharedAPPControl].listArray;
    if (listArray == nil || listArray.count == 0) {
        return;
    }
    
    
    NSMutableString *ids = [NSMutableString string];
    for (ChZMarketListModel *model in listArray)
    {
        if (ChZ_StringIsEmpty(model.fid))
        {
            [ids appendString:model.fid];
            [ids appendString:@","];
        }
    }
    
    
    if (ids.length>1) {
        [ids deleteCharactersInRange:NSMakeRange(ids.length -1, 1)];
    }
    
    
    if (ChZ_StringIsEmpty(ids))
    {
        ChZ_Weak
        [ChZHomeRequest requestRealCoin:ids successBlock:^(id dataSource)
         {
             [APPControl sharedAPPControl].walletNewsArray = dataSource;
             ChZ_Strong
             [_strongSelf _handleCoinData:dataSource];
         } errorBlock:^(int code, NSString *error)
         {
             
         }];
    }
}

- (void)_handleCoinData:(NSArray *)array
{
    
    
    double num = 0.0f;
    double cny = [[APPControl sharedAPPControl].cny doubleValue];
    double usdt = 0.0f;
    
    
    for (WalletListModel *model in self.dataSource)
    {
        if ([model.shortName isEqualToString:@"USDT"] && model.total)
        {
            usdt = model.total;;
            continue;
        }
        for (ChZRealCoinInfoModel *coinModel in array)
        {
            if ([model.shortName isEqualToString:coinModel.sellSymbol])
            {
                if ([model.shortName isEqualToString:@"M"])
                {
                    
                }
                double number = model.total;
                double price = [coinModel.p_new doubleValue];
                num += number *price;
                break;
            }
        }
    }
    [self _config:num * cny + usdt * cny];
}

- (void)_config:(double)price
{
    NSString *totalassets = [NSString stringWithFormat:@"%.2f",price];
    self.headView.moneyLable.text = totalassets;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"THROUNTCOINSUCCESS" object:nil];
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
