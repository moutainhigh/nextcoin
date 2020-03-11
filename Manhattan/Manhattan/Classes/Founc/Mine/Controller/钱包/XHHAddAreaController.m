//
//  XHHAddAreaController.m
//  Manhattan
//
//  Created by Apple on 2018/8/17.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHAddAreaController.h"
#import "XHHPublicNavView.h"
#import "ChZScanQRController.h"
#import "XHHChoosePayTypeController.h"
#import <TYAlertController/TYAlertController.h>
#import "XTTMyPurseView.h"
#import "XHHPTChooseController.h"
#import "XHHMineFrogetPswViewController.h"
#import "XHHMineSetpswViewController.h"
static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}
@interface XHHAddAreaController ()<XHHPublicNavViewProtocol>
@property (weak, nonatomic) IBOutlet UITextField *moneyText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *areaText;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic , strong) XHHPublicNavView           *navView;

@property (nonatomic , strong) NSString *phoneCode;
@property (nonatomic , strong) NSString *tradeCode;
@property (nonatomic , strong) TYAlertController *controller;

@property (nonatomic , copy) NSString *coinId;
@end

@implementation XHHAddAreaController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coinId = nil;
    
    [self zh_setupUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)zh_setupUI{
    CGFloat navHeight = ChZ_IsiPhoneX ? 24 : 0;
    
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(navHeight +64);
    }];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
    }];
    
    [_moneyText configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    [_nameText configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    [_areaText configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
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
-(XHHPublicNavView *)navView{
    if (!_navView) {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"创建新地址" image:@"public_nav_leftBack"];
        [_navView setrightButtonTitles:nil images:@[@"mine_wallet_sao"]];
        _navView.rightOneWithd.constant = 44;
        _navView.delegete = self;
    }
    return _navView;
}
-(void)rightButtonActionIndex:(NSInteger)index{
    ChZScanQRController *vc = [ChZScanQRController initWithStoryboard:@"Scan"];;
    @weakify(self)
    vc.callBackBlock = ^(NSString *obj)
    {
        @strongify(self)
        self.areaText.text = obj;
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)chooseAction:(id)sender {
    XHHPTChooseController *vc = [[XHHPTChooseController alloc] init];
    @weakify(self);
    vc.chooseCnyBlock = ^(XHHC2CCnyListModel *model)
    {
        @strongify(self);
        self.coinId = model.fid;
        [self.chooseButton setTitle:model.short_name forState:UIControlStateNormal];
        self.moneyText.placeholder = @"";
    };
    
    vc.cnyList = nil;
    [[ChZUtil getCurrentVC].navigationController pushViewController:vc animated:YES];
}
- (IBAction)keepAction:(id)sender {
    if (self.coinId == nil) {
        ChZ_MBError(@"请选择币种");
        return;
    }
    if (self.nameText.text.length == 0) {
        ChZ_MBError(@"请输入名称");
        return;
    }
    if (self.areaText.text.length == 0) {
        ChZ_MBError(@"请输入地址");
        return;
    }
    if ([APPControl sharedAPPControl].isSetPayPassword)
    {
        [self showPhoneCodeView];
    }else
    {
        [self showTheAlertVCWithStyle:UIAlertControllerStyleAlert title:nil message:@"您还未设置交易密码，快去设置吧！" title1:@"取消" action1:^{
            
        } title2:@"马上去" action2:^{
            XHHMineSetpswViewController *vc = [XHHMineSetpswViewController initWithStoryboard:@"MineStroy"];
            [self.navigationController pushViewController:vc animated:YES];
        } title3:nil action3:nil completion:nil];
    }
    
}
-(void)showPhoneCodeView{
    [self requestSignMsgCode];
    
    CGFloat bottom = sgm_safeAreaInset(self.view).bottom;
    XTTMPSAddAddressTelVerCodeView *telVerCodeView = [XTTMPSAddAddressTelVerCodeView loadFromNib];
    telVerCodeView.frame = CGRectMake(0, 0, self.view.width, 234 + bottom);
    self.controller = [TYAlertController alertControllerWithAlertView:telVerCodeView preferredStyle:TYAlertControllerStyleActionSheet];
    self.controller.backgoundTapDismissEnable = YES;
    [self presentViewController:self.controller animated:YES completion:nil];
    
    telVerCodeView.verCodeInputBlock = ^(NSString *text) {
        if (text.length == 6)
        {
            self.phoneCode = text;
            [self.controller dismissViewControllerAnimated:YES];
            [self showTradeView];
            
        }
    };
    telVerCodeView.dismissBlock = ^{
        [self.controller dismissViewControllerAnimated:YES];
        
    };
    telVerCodeView.sendTelCodeBlock = ^{
        [self requestSignMsgCode];
        
    };
}
-(void)showTradeView{
    
    CGFloat bottom = sgm_safeAreaInset(self.view).bottom;
    
    XTTMPSTradePwdView *tradePwdView = [XTTMPSTradePwdView loadFromNib];
    tradePwdView.frame = CGRectMake(0, 0, self.view.width, 253 + bottom);
    self.controller = [TYAlertController alertControllerWithAlertView:tradePwdView preferredStyle:TYAlertControllerStyleActionSheet];
    self.controller.backgoundTapDismissEnable = YES;
    [self presentViewController:self.controller animated:YES completion:nil];
    
    tradePwdView.sureBlock = ^(NSString *text)
    {
        UserModel *user = [APPControl sharedAPPControl].user;
        if ([user.fgooglebind isEqualToString:@"1"])
        {
            self.tradeCode = text;
            [self.controller dismissViewControllerAnimated:YES];
            [self showGoogleCodeView];
        }else
        {
            [self.controller dismissViewControllerAnimated:YES];
            [self requestCoinAddressAddPhoneCode:self.phoneCode googleCode:nil address:self.areaText.text tradepwd:text remark:self.nameText.text symbolId: self.coinId];
        }
    };
    tradePwdView.dismissBlock = ^{
        [self.controller dismissViewControllerAnimated:YES];
        
    };
    tradePwdView.forgetTradePwdBlock = ^{
        [self.controller dismissViewControllerAnimated:YES];
        [self forgetTradePwdAction];
    };
    
    
}
-(void)forgetTradePwdAction{
    XHHMineFrogetPswViewController *vc = [XHHMineFrogetPswViewController initWithStoryboard:@"MineStroy"];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)showGoogleCodeView{
    CGFloat bottom = sgm_safeAreaInset(self.view).bottom;
    XTTMPSAddAddressGoogleCodeView *googleCodeView = [XTTMPSAddAddressGoogleCodeView loadFromNib];
    googleCodeView.frame = CGRectMake(0, 0, self.view.width, 170 + bottom);
    self.controller = [TYAlertController alertControllerWithAlertView:googleCodeView preferredStyle:TYAlertControllerStyleActionSheet];
    self.controller.backgoundTapDismissEnable = YES;
    [self presentViewController:self.controller animated:YES completion:nil];
    
    googleCodeView.verCodeInputBlock = ^(NSString *text)
    {
        if (text.length == 6)
        {
            [self.controller dismissViewControllerAnimated:YES];
            [self requestCoinAddressAddPhoneCode:self.phoneCode googleCode:text address:self.areaText.text tradepwd:self.tradeCode remark:self.nameText.text symbolId: self.coinId];
            
        }
    };
    googleCodeView.dismissBlock = ^{
        [self.controller dismissViewControllerAnimated:YES];
        
    };
    
}
-(void)requestSignMsgCode{
    
    [WalletNetWorkControl requestSignMsgCodeSuccessBlock:^(id dataSource)
     {
         
     } errorBlock:^(int code, NSString *error)
     {
         ChZ_MBError(error)
     }];
}
- (void)requestCoinAddressAddPhoneCode:(NSString *)phoneCode
                            googleCode:(NSString *)googleCode
                               address:(NSString *)address
                              tradepwd:(NSString *)tradepwd
                                remark:(NSString *)remark
                              symbolId:(NSString *)symbolId{
    ChZ_MBMsg(nil)
    @weakify(self);
    [WalletNetWorkControl requestCoinAddressAddPhoneCode:phoneCode googleCode:googleCode address:address password:tradepwd remark:remark symbolId:symbolId successBlock:^(id dataSource) {
        @strongify(self);
        ChZ_MBDismss
        ChZ_MBSuccess(@"添加成功")
        if (self.callBackBlock)
        {
            self.callBackBlock(nil);
        }
        [self pop];
        
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismss
        ChZ_MBError(error)
    }];
}
@end
