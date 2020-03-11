//
//  XHHMiningAreaController.m
//  Manhattan
//
//  Created by Apple on 2018/8/17.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHMiningAreaController.h"
#import "XHHPublicNavView.h"
#import "XHHMiningAreaCell.h"
#import "XHHThrowOutController.h"
#import "XHHMiningAreaModle.h"
#import "XHHThrowOutController.h"
static NSString *cellIndifier = @"XHHMiningAreaCell";


@interface XHHMiningAreaController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (nonatomic , strong) XHHPublicNavView           *navView;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) XHHMiningAreaModle *model;
@end

@implementation XHHMiningAreaController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    
    [self requestMiningArea];
}

-(void)zh_setupUI{
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    CGFloat bottomHeight = ChZ_IsiPhoneX ? 34 : 0;
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-bottomHeight);
    }];
}
-(XHHPublicNavView *)navView
{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"开矿区" image:@"public_nav_leftBack"];
    }
    return _navView;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 211 ;
        [_tableView setSeparatorColor:[UIColor clearColor]];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setTableHeaderView:self.headView];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHMiningAreaCell" bundle:nil] forCellReuseIdentifier:cellIndifier];
    }
    return _tableView;
}
-(void)setModel:(XHHMiningAreaModle *)model
{
    _model = model;
    [self.tableView reloadData];
}
#pragma tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHMiningAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.index = indexPath.row;
    cell.model = self.model;
    @weakify(self);
    cell.block = ^(NSInteger index, id obj, int type)
    {
        @strongify(self);
        XHHThrowOutController *vc = [[XHHThrowOutController alloc] init];
        @weakify(self);
        vc.callBackBlock = ^(id Obj)
        {
            @strongify(self);
            [self requestMiningArea];
        };
        if (index == 0)//MHT
        {
            vc.throwType = XHHThrowTypeMHTX;
        }
        if (index == 1)//USDT
        {
            vc.throwType = XHHThrowTypeUSDT;
        }
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.oneKeyBlock = ^(NSInteger index, XHHMiningAreaModle *model)
    {
        @strongify(self);
        XHHMiningOnekeyType oneKeyStaue;
        NSString *miningType;
        if (index == 0)//MHT
        {
            miningType = @"mhtx";
            if ([model.is_onekey_mhtx integerValue] == 0)
            {
                oneKeyStaue = XHHMiningOnekeyTypeInput;
            }else
            {
                oneKeyStaue = XHHMiningOnekeyTypeCanle;
            }
        }else//USDT
        {
            miningType = @"usdt";
            if ([model.is_onekey_usdt integerValue] == 0)
            {
                oneKeyStaue = XHHMiningOnekeyTypeInput;
            }else
            {
                oneKeyStaue = XHHMiningOnekeyTypeCanle;
            }
        }
        [self requestOneKeyInput:miningType status:oneKeyStaue];
    };
    return cell;
}
-(void)requestOneKeyInput:(NSString *)type status:(XHHMiningOnekeyType)status
{
    ChZ_MBMsg(nil)
    @weakify(self);
    [XHHMiningRequest requestMiningOneKeyInputType:type status:status success:^(id dataSource)
    {
        @strongify(self)
        ChZ_MBDismss;
        [self requestMiningArea];
    } error:^(int code, NSString *error)
    {
        ChZ_MBDismss
        ChZ_DebugLog(@"%@",error);
    }];
}

-(void)requestMiningArea{
    @weakify(self);
    [XHHMiningRequest requestMiningAreaListSuccess:^(id dataSource)
    {
        @strongify(self);
        self.model = dataSource;
    } error:^(int code, NSString *error)
    {
        ChZ_MBError(error);
    }];
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
