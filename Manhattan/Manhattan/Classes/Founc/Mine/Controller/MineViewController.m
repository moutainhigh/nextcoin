//
//  MineViewController.m
//  Manhattan
//
//  Created by Apple on 2018/8/14.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "MineViewController.h"
#import "XHHMineCell.h"
#import "XHHMineTableHeadView.h"
#import "XHHSafeCenterController.h"
#import "ChZAddAlipayAccountController.h"
#import "XHHUserModelCenter.h"
static NSString *cellIdentifier = @"XHHMineCell";
@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView          *tableView;

@property (strong, nonatomic) XHHMineTableHeadView *tableHeadView;

@property (strong, nonatomic) NSArray              *dataArray;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noHiddenNav = YES;
    
    [self zh_setupUI];
    
    [self requestUserMessage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUseSuccess) name:@"UPDATEUSERMESSAGESUCCESS" object:nil];
}
-(void)updateUseSuccess
{
    [self requestUserMessage];
}
-(void)zh_setupUI{
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    
    UIImageView *img = [[UIImageView alloc] init];
    img.image = [UIImage imageNamed:@"mine_home_bgimge"];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(44 + navHeight);
    }];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView setRowHeight:50];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setTableHeaderView:self.tableHeadView];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView setSeparatorColor:[UIColor clearColor]];
        [_tableView setBackgroundColor:[UIColor clearColor]];
    }
    return _tableView;
}
-(XHHMineTableHeadView *)tableHeadView{
    if (!_tableHeadView) {
        _tableHeadView = [[XHHMineTableHeadView alloc] init];
        [_tableHeadView setFrame:CGRectMake(0, 0, ChZ_WIDTH, 106)];
    }
    return _tableHeadView;
}

-(NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[@{@"image":@"mine_home_safe",@"name":@"安全中心",@"controller":@"XHHSafeCenterController"},
                       @{@"image":@"mine_home_wallet",@"name":@"钱包",@"controller":@"XHHWalletController"},
                       @{@"image":@"mine_home_C2Chome",@"name":@"收款账号(C2C)",@"controller":@"ChZReceiptAccountListController"},
//                       @{@"image":@"mine_home_help",@"name":@"帮助中心",@"controller":@"ChZHelpCenterController"},
                       @{@"image":@"mine_home_us",@"name":@"我的邀请",@"controller":@"XHHOneKeyShareViewController"},
                       @{@"image":@"mine_home_set",@"name":@"设置",@"controller":@"XHHSetController"},];
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
    XHHMineCell *cell = [[XHHMineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    NSDictionary *dic = self.dataArray[indexPath.row];
    [cell reloadCellWithDic:dic];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1)
    {
        UIViewController *vc = [[NSClassFromString(self.dataArray[indexPath.row][@"controller"]) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2)
    {
        UIViewController *vc = [NSClassFromString(self.dataArray[indexPath.row][@"controller"]) initWithStoryboard:@"ReceiptAccount"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    else if (indexPath.row == 3)
//    {
//        UIViewController *vc = [NSClassFromString(self.dataArray[indexPath.row][@"controller"]) initWithStoryboard:@"HelpCenter"];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    else
    {
        UIViewController *vc = [NSClassFromString(self.dataArray[indexPath.row][@"controller"]) initWithStoryboard:@"MineStroy"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestUserMessage{
    @weakify(self);
    [XHHSafeCenterRequest requestUserMessageSuccessBlock:^(id dataSource)
    {
        @strongify(self);
        XHHUserModelCenter *model = dataSource;
        self.tableHeadView.userModel = model;
    } errorBlock:^(int code, NSString *error)
    {
        ChZ_DebugLog(@"%@--",error);
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATEUSERMESSAGESUCCESS" object:nil];
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
