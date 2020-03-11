//
//  XHHPTChooseController.m
//  Manhattan
//
//  Created by Apple on 2018/8/21.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHPTChooseController.h"
#import "XHHPTChooseCell.h"
#import "XHHPayTypeModel.h"
#import "XHHPublicNavView.h"
#import "XHHC2CCnyListModel.h"
static NSString *cellIdentifier = @"XHHPTChooseCell";
@interface XHHPTChooseController ()<UITableViewDelegate,UITableViewDataSource,XHHPublicNavViewProtocol>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray     *dataArray;

@property (assign, nonatomic) NSInteger   currIndex;

@property (strong, nonatomic) UILabel     *titleLable;

@property (nonatomic , strong) XHHPublicNavView           *navView;


@end

@implementation XHHPTChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currIndex = 0;
    
    [self requestPayType];
    
    [self zh_setupUI];
    // Do any additional setup after loading the view.
}
-(void)zh_setupUI{
    
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    CGFloat bottomHeight = ChZ_IsiPhoneX ? 34 : 0;
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    [self.view addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(16);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.titleLable.mas_bottom).offset(30);
        make.bottom.equalTo(self.view).offset(-bottomHeight);
    }];
    
}
-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"" image:@"public_nav_leftBack"];
        [_navView setrightButtonTitles:@[@"确认"] images:nil];
        _navView.delegete = self;
    }
    return _navView;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 57;
        [_tableView setSeparatorColor:LineCorlor];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHPTChooseCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    }
    return _tableView;
}
-(UILabel *)titleLable{
    if (!_titleLable) {
        _titleLable = [UILabel newSingleFrame:CGRectZero title:@"选择币种" fontS:24.0 color:[UIColor colorWithHexString:@"2E7AF1"]];
    }
    return _titleLable;
}
-(void)rightButtonActionIndex:(NSInteger)index{
    if (self.chooseCnyBlock)
    {
        if (self.cnyList.count)
        {
            _chooseCnyBlock(self.selectedCoinmodel);
        }else
        {
            _chooseCnyBlock(nil);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setCnyList:(NSArray *)cnyList{
    _cnyList = cnyList;
    if (cnyList == nil)
    {
        [self requestPayType];
    }
    [self.tableView reloadData];
}
#pragma tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cnyList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHPTChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.cnyList.count > indexPath.row) {
        XHHC2CCnyListModel *model = self.cnyList[indexPath.row];
        cell.cnyModel = model;
        if([model.short_name isEqualToString:self.selectedCoinmodel.short_name])
        {
            [cell setSelectedCell:YES];
        }else
        {
            [cell setSelectedCell:NO];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XHHC2CCnyListModel *model = self.cnyList[indexPath.row];
    self.selectedCoinmodel = model;
//    _currIndex = indexPath.row;
    [self.tableView reloadData];
}

-(void)requestPayType
{
    @weakify(self);
    [ChZHomeRequest requestC2CcnyListSuccessBlock:^(NSArray *dataSource)
     {
         @strongify(self);
         self.cnyList = dataSource;
         [self.tableView reloadData];
     } errorBlock:^(int code, NSString *error) {
         ChZ_MBError(error);
     }];
}

@end
