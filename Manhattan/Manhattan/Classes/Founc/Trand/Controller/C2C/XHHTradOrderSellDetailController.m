//
//  XHHTradOrderSellDetailController.m
//  FuturePurse
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHTradOrderSellDetailController.h"
#import "XHHOrderDetailHeadView.h"
#import "XHHOrderNumberView.h"
#import "XHHTradPayMessageView.h"

#import "XHHTradWaitPayView.h"

#import "XHHPublicNavView.h"

#import "ChZOrderDetailBottomView.h"
#import "ChZC2CComplaintController.h"
@interface XHHTradOrderSellDetailController ()<XHHPublicNavViewProtocol>

@property (strong, nonatomic) XHHOrderDetailHeadView    *topView;

@property (strong, nonatomic) XHHOrderNumberView        *orderNumberView;

@property (strong, nonatomic) XHHTradPayMessageView     *payMsgView;

@property (strong, nonatomic) XHHTradWaitPayView        *waitPayView;

@property (strong, nonatomic) UIButton                  *bottomButton;

@property (nonatomic , strong) XHHPublicNavView           *navView;

@property (nonatomic, strong) ChZOrderDetailBottomView *bottomView;

@end

@implementation XHHTradOrderSellDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    // Do any additional setup after loading the view.
}
-(void)zh_setupUI{
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(88.0f);
    }];
    
    //背景滚动视图
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(navHeight + 64);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    //内容视图
    UIView *contentView = [[UIView alloc]init];
    [bgScrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(bgScrollView).insets(UIEdgeInsetsZero);
        make.width.equalTo(bgScrollView);
    }];
    CGFloat waitHeight = [self.orderModel.order_status isEqualToString:@"1"] ? 44 : 0;
    [contentView addSubview:self.waitPayView];
    [self.waitPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(contentView);
        make.height.mas_equalTo(waitHeight);
    }];
    
    [contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(self.waitPayView.mas_bottom);
        make.height.mas_equalTo(222);
    }];
    
    [contentView addSubview:self.orderNumberView];
    [self.orderNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(95);
    }];
    
    [contentView addSubview:self.payMsgView];
    [self.payMsgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(self.orderNumberView.mas_bottom);
        make.bottom.equalTo(self.payMsgView.tableView);
    }];
    
    if ([self.orderModel.order_status isEqualToString:@"1"])
    {
        [self.navView setrightButtonTitles:@[@"取消交易"] images:@[@""]];
    }else
    {
        [self.navView setrightButtonTitles:nil images:nil];
    }
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.payMsgView.mas_bottom);
    }];
}
- (void)rightButtonActionIndex:(NSInteger)index{
    [self canlePay];
}
-(void)canlePay{
    [self showTheAlertVCWithStyle:UIAlertControllerStyleAlert title:nil message:@"您确定要取消订单吗?" title1:@"取消" action1:^{
        
    } title2:@"确定" action2:^{
        [self requestCanelOrder];
    } title3:nil action3:nil completion:nil];
}

-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"发布" image:@"public_nav_leftBack"];
        _navView.delegete = self;
    }
    return _navView;
}
-(XHHOrderDetailHeadView *)topView{
    if (!_topView) {
        _topView = [[[NSBundle mainBundle] loadNibNamed:@"XHHOrderDetailHeadView" owner:nil options:nil] lastObject];
        _topView.type = C2CTradTypeSell;
        [_topView reloadCellWithSellModel:self.orderModel];
    }
    return _topView;
}
-(XHHOrderNumberView *)orderNumberView{
    if (!_orderNumberView) {
        _orderNumberView = [[[NSBundle mainBundle] loadNibNamed:@"XHHOrderNumberView" owner:nil options:nil] lastObject];
        [_orderNumberView setType:2];
        [_orderNumberView reloadViewWithModel:self.orderModel];
    }
    return _orderNumberView;
}
-(XHHTradPayMessageView *)payMsgView{
    if (!_payMsgView) {
        _payMsgView = [[[NSBundle mainBundle] loadNibNamed:@"XHHTradPayMessageView" owner:nil options:nil] lastObject];
        _payMsgView.orderModel = self.orderModel;
    }
    return _payMsgView;
}
-(XHHTradWaitPayView *)waitPayView{
    if (!_waitPayView) {
        _waitPayView = [[[NSBundle mainBundle] loadNibNamed:@"XHHTradWaitPayView" owner:nil options:nil] lastObject];
    }
    return _waitPayView;
}
- (ChZOrderDetailBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView =  [ChZOrderDetailBottomView nibLoadSelf];
        _bottomView.type = C2CTradTypeSell;
        _bottomView.orderModel = self.orderModel;
        @weakify(self);
        _bottomView.block = ^(BOOL isHandle)
        {
            @strongify(self);
            [self handleBottomEvent:isHandle];
        };
    }
    return _bottomView;
}
- (void)handleBottomEvent:(BOOL)isHandle
{
    NSInteger payType = [self.orderModel.order_status integerValue];
    switch (payType)
    {
        case 1:
        {//未付款
            
        }
            break;
        case 2:
        {//等待卖方确认
            if (isHandle == NO)
            {
                ChZC2CComplaintController *vc = [ChZC2CComplaintController initWithStoryboard:@"c2c"];
                vc.orderId = self.orderModel.fid;
                @weakify(self);
                vc.callBackBlock = ^(id Obj) {
                    @strongify(self);
                    self.orderModel.order_status = @"4";
                    [self.topView reloadCellWithSellModel:self.orderModel];
                    self.bottomView.type = C2CTradTypeSell;
                    self.bottomView.orderModel = self.orderModel;
                };
                [self.navigationController pushViewController:vc animated:YES];
            }else
            {
                if (isHandle) {
                    [self showTheAlertVCWithStyle:UIAlertControllerStyleAlert title:nil message:@"是否确定已收到对方的打款?" title1:@"取消" action1:^{
                        
                    } title2:@"确定" action2:^{
                        [self requestGetMoney];
                    } title3:nil action3:nil completion:nil];
                }
            }
        }
            break;
        case 3:
        {//已完成
            
        }
            break;
        case 4:
        {//申诉中
            
        }
            break;
        case 9:
        {//已取消
            
        }
            break;
            
        default:
            break;
    }
    
    
}
-(UIButton *)bottomButton{
    if (!_bottomButton) {
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomButton setTitle:@"我已收到款" forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        [_bottomButton setBackgroundColor:[UIColor colorWithHexString:@"2395FF"]];
        [_bottomButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        @weakify(self);
        [[_bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self showTheAlertVCWithStyle:UIAlertControllerStyleAlert title:nil message:@"是否确定已收到对方的打款?" title1:@"取消" action1:^{
                
            } title2:@"确定" action2:^{
                [self requestGetMoney];
            } title3:nil action3:nil completion:nil];
        }];
    }
    return _bottomButton;
}
-(void)requestGetMoney{
    ChZ_MBMsg(nil);
    @weakify(self);
    [ChZHomeRequest requestC2CSignHadGetMoneyUid:[APPControl sharedAPPControl].user.fid orderId:self.orderModel.fid successBlock:^(id dataSource) {
        @strongify(self);
        ChZ_MBDismss;
        ChZ_MBSuccess(@"操作成功");
        self.orderModel.order_status = @"3";
        [self.topView reloadCellWithSellModel:self.orderModel];
        self.bottomButton.hidden = YES;
        [self.navView setrightButtonTitles:nil images:nil];
        self.bottomView.orderModel = self.orderModel;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ORDERCANLE" object:nil];
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismss;
        ChZ_MBSuccess(error);
    }];
}
-(void)requestCanelOrder{
    ChZ_MBMsg(nil);
    @weakify(self);
    [ChZHomeRequest requestC2CCanelOrderUid:[APPControl sharedAPPControl].user.fid orderId:self.orderModel.fid successBlock:^(id dataSource) {
        @strongify(self);
        ChZ_MBDismss;
        ChZ_MBSuccess(@"取消成功");
        self.waitPayView.hidden = YES;
        [self.waitPayView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        self.orderModel.order_status = @"9";
        [self.topView reloadCellWithSellModel:self.orderModel];
        [self.navView setrightButtonTitles:nil images:nil];
        self.bottomView.orderModel = self.orderModel;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ORDERCANLE" object:nil];
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismss;
        ChZ_MBSuccess(error);
    }];
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
