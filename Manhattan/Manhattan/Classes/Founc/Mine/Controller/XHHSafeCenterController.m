//
//  XHHSafeCenterController.m
//  Manhattan
//
//  Created by Apple on 2018/8/16.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHSafeCenterController.h"
#import "XHHPayPwController.h"
#import "XHHLoginPwController.h"
#import "XHHAuthViewController.h"
#import "XHHAuthViewController.h"
#import "XHHSafeCenterModel.h"

#import "XHHMineSetpswViewController.h"
#import "XHHMineUpdatepswViewController.h"
#import "XHHGoogleVerifyCodeStep1Controller.h"
@interface XHHSafeCenterController ()

@property (nonatomic , strong) HCCenterSecuritySettingWrapperModel *settingModel;
@property (weak, nonatomic) IBOutlet UILabel *payWordLable;
@property (weak, nonatomic) IBOutlet UILabel *authLable;
@property (weak, nonatomic) IBOutlet UILabel *gooleAlertLable;

@end

@implementation XHHSafeCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestSecureSettingDetail];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authSuccessNoti) name:@"AuthSuccess" object:nil];
}
-(void)authSuccessNoti{
     [self requestSecureSettingDetail];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)loginPwAction:(id)sender
{
    XHHLoginPwController *vc = [XHHLoginPwController initWithStoryboard:@"MineStroy"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)payPwAction:(id)sender
{
    if (self.settingModel.bindTrade)
    {
        XHHMineUpdatepswViewController *vc = [XHHMineUpdatepswViewController initWithStoryboard:@"MineStroy"];
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        XHHMineSetpswViewController *vc = [XHHMineSetpswViewController initWithStoryboard:@"MineStroy"];
        @weakify(self);
        vc.callBackBlock = ^(id Obj)
        {
            @strongify(self);
            [self requestSecureSettingDetail];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)authAction:(id)sender
{
    if (self.settingModel.fuser.fhasrealvalidate)
    {
        ChZ_MBError(@"您已认证");
        return;
    }else
    {
        if (self.settingModel.fidentity)
        {
            
            if([self.settingModel.fidentity.fstatus isEqualToString:@"2"])
            {
                XHHAuthViewController *vc = [XHHAuthViewController initWithStoryboard:@"LoginStroy"];
                vc.isFromeMine = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else
            {
                ChZ_MBError(@"您的信息正在认证中");
            }
            
        }else
        {
            XHHAuthViewController *vc = [XHHAuthViewController initWithStoryboard:@"LoginStroy"];
            vc.isFromeMine = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}
- (IBAction)gooleAction:(id)sender
{
    if (_settingModel) {
        if (_settingModel.fuser.fgooglebind) {
            ChZ_MBError(@"您已绑定Google验证码")return;
        }
        XHHGoogleVerifyCodeStep1Controller *vc = [XHHGoogleVerifyCodeStep1Controller initWithStoryboard:@"MineStroy"];
        vc.title = @"Google验证码";
        vc.settingModel = self.settingModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)requestSecureSettingDetail
{
    ChZ_MBMsg(nil)
    @weakify(self);
    [XHHSafeCenterRequest requestSecureSettingDetailSuccessBlock:^(id dataSource)
     {
        @strongify(self);
        ChZ_MBDismss
        self.settingModel = dataSource;
    } errorBlock:^(int code, NSString *error)
    {
        ChZ_MBDismss
    }];
}
-(void)setSettingModel:(HCCenterSecuritySettingWrapperModel *)settingModel{
    _settingModel = settingModel;
    
    
    if (settingModel.fuser.fhasrealvalidate)
    {
        self.authLable.text = @"已认证";
    }else
    {
        if (settingModel.fidentity)
        {
            
            if([settingModel.fidentity.fstatus isEqualToString:@"2"])
            {
                self.authLable.text = @"认证失败";
            }else
            {
                self.authLable.text = @"认证中";
            }
        }else
        {
            self.authLable.text = @"未认证";
        }
    }
    if(settingModel.bindTrade)
    {
        self.payWordLable.text = @"已开启";
    }
    if (_settingModel.fuser.fgooglebind)
    {
        self.gooleAlertLable.text = @"已绑定";
        
    }else
    {
        self.gooleAlertLable.text = @"未绑定";
    }
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
