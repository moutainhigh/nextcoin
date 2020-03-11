//
//  XHHPayRecordController.m
//  Manhattan
//
//  Created by Apple on 2018/8/17.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHPayRecordController.h"
#import "XHHPayRedordCell.h"
#import "XHHPayRecordHeadView.h"
#import "XHHPublicNavView.h"
#import "XHHPayRecordFootView.h"
#import "XHHReablesAreaController.h"
#import "XHHTrunOutController.h"
static NSString *cellIndifier = @"XHHPayRedordCell";
@interface XHHPayRecordController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) XHHPublicNavView           *navView;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray *dataArray;
@property (nonatomic , strong) XHHPayRecordHeadView *headView;
@property (nonatomic , strong) XHHPayRecordFootView *footView;

@end

@implementation XHHPayRecordController
-(void)viewDidLayoutSubviews{
    CGFloat bottomHeigth = ChZ_IsiPhoneX ? 34 : 0;
    self.headView.frame = CGRectMake(0, 0, ChZ_WIDTH, 170);
    self.footView.frame = CGRectMake(0, ChZ_HEIGHT - 50 -bottomHeigth, ChZ_WIDTH, 50);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thtountSuccess) name:@"THROUNTCOINSUCCESS" object:nil];
    // Do any additional setup after loading the view.
}
-(void)thtountSuccess{
    [self.tableView.mj_header beginRefreshing];
}
-(void)zh_setupUI{
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    CGFloat bottomHeigth = ChZ_IsiPhoneX ? 34 : 0;
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-bottomHeigth-50 - 10);
    }];
    
    [self.view addSubview:self.footView];
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 87;
        [_tableView setSeparatorColor:LineCorlor];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 65, 0, 0)];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setTableHeaderView:self.headView];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHPayRedordCell" bundle:nil] forCellReuseIdentifier:cellIndifier];
        [self setupRefreshWithView:_tableView refreshHeadAction:@selector(headRefresh) refreshFooterAction:nil];
    }
    return _tableView;
}
-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:[NSString stringWithFormat:@"%@钱包",self.model.shortName] image:@"public_nav_leftBack"];
    }
    return _navView;
}

-(XHHPayRecordHeadView *)headView{
    if (!_headView) {
        _headView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPayRecordHeadView" owner:nil options:nil] lastObject];
        _headView.model = self.model;
    }
    return _headView;
}
- (XHHPayRecordFootView *)footView{
    if (!_footView) {
        _footView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPayRecordFootView" owner:nil options:nil] lastObject];
        @weakify(self);
        _footView.inBlock = ^{
            @strongify(self);
            XHHReablesAreaController *vc = [[XHHReablesAreaController alloc] init];
            vc.model = self.model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        _footView.outBlock = ^{
            @strongify(self);
            XHHTrunOutController *vc = [[XHHTrunOutController alloc] init];
            vc.model = self.model;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _footView;
}
#pragma tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHPayRedordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndifier];
    if(self.dataArray.count > indexPath.row)
    {
        cell.model = self.dataArray[indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)headRefresh{
    [self _setupData];
}
-(void)getMyRecharge{
    @weakify(self);
    [WalletNetWorkControl requestRecharge:self.model.coinId successBlock:^(id dataSource)
     {
         @strongify(self);
         NSDictionary *data = dataSource;
         NSDictionary *page = [data objectForKey:@"page"];
         if (!page) {
             self.dataArray = nil;
             [self.tableView reloadData];
             return;
         }
         NSArray *listArray = [page objectForKey:@"data"];
         self.dataArray = [RecordModel mj_objectArrayWithKeyValuesArray:listArray];
         [self.tableView reloadData];
         [self.tableView.mj_header endRefreshing];
     } errorBlock:^(int code, NSString *error) {
         @strongify(self);
         ChZ_MBError(error);
         [self.tableView.mj_header endRefreshing];
     }];
}
- (void)_setupData
{
    ChZ_MBMsg(nil)
    ChZ_Weak
    [WalletNetWorkControl requestRechargeList:self.model.coinId successBlock:^(id dataSource)
     {
         ChZ_MBDismss
         ChZ_Strong
         [_strongSelf.tableView.mj_header endRefreshing];
         _strongSelf.dataArray = dataSource;
         [_strongSelf.tableView reloadData];
     } errorBlock:^(int code, NSString *error)
    {
         ChZ_Strong
         [_strongSelf.tableView.mj_header endRefreshing];
         ChZ_MBDismssError(error)
     }];
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
