//
//  XHHRgistViewController.m
//  Manhattan
//
//  Created by Apple on 2018/8/14.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHRgistViewController.h"
#import "XHHAuthViewController.h"

@interface XHHRgistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *invetCode;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@end

@implementation XHHRgistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_phone configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    [_password configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    [_code configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    [_invetCode configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:PlaceholderColor];
    
    @weakify(self);
    [[_phone rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if (x.length> 0 )
        {
            self.clearButton.hidden = NO;
        }
    }];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
}

//  键盘弹出触发该方法
- (void)keyboardDidShow
{
    if (_bgScrollView.contentOffset.y > 0) {
        _navTitle.text = @"注册";
    }
    
}
//  键盘隐藏触发该方法
- (void)keyboardDidHide
{
    _navTitle.text = @"";
}
- (IBAction)clearPhone:(UIButton *)sender {
    _phone.text = @"";
    sender.hidden = YES;
}
- (IBAction)seePassWordAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    _password.secureTextEntry = !sender.selected;
}
- (IBAction)getCodeAction:(UIButton *)sender {
    
    [self requestGetCode];
}
- (IBAction)registAction:(id)sender {
    [self requestRegist];
}
- (IBAction)loginAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)requestGetCode{
    if (!ChZ_StringIsEmpty(self.phone.text))
    {
        ChZ_MBError(@"请输入手机号码");
        return;
    }
    ChZ_MBMsg(nil);
    @weakify(self);
    [XHHLoginRequest requestPhoneMsg:@"86"
                               phone:self.phone.text
                                type:@"112"
                        successBlock:^(id dataSource)
    {
        @strongify(self);
        ChZ_MBDismssSuccess(@"验证码已发送")
        [self.timeButton startWithTime:59
                                 title:@"获取验证码"
                        countDownTitle:@" s" 
                             mainColor:[UIColor colorWithHexString:@"2E7AF1"]
                            countColor:PlaceholderColor];
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismssError(error);
    }];
}
-(void)requestRegist{
    if (!ChZ_StringIsEmpty(self.phone.text))
    {
        ChZ_MBError(@"请输入手机号码");
        return;
    }
    if (!ChZ_StringIsEmpty(self.code.text))
    {
        ChZ_MBError(@"请输入验证码");
        return;
    }
    if (!ChZ_StringIsEmpty(self.password.text))
    {
        ChZ_MBError(@"请输入密码");
        return;
    }
    ChZ_MBMsg(nil)
    @weakify(self);
    [XHHLoginRequest requestRegister:self.phone.text
                             areaNum:@"86"
                            password:self.password.text
                             msgCode:self.code.text
                         introUserId:self.invetCode.text
                        successBlock:^(id dataSource)
    {
        @strongify(self);
        ChZ_MBDismssSuccess(@"注册成功");
        
        [self requestRigistSuccess];
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismssError(error);
    }];
}
-(void)requestRigistSuccess{
    NSString *invCode = self.invetCode.text;
    if (invCode.length == 0)
    {
        invCode = 0;
    }
    [XHHLoginRequest requestRegistSuccessUserName:self.phone.text
                                         passWord:self.password.text
                                          surePsw:self.password.text
                                             type:@"2"
                                            invId:invCode
                                     successBlock:^(id dataSource)
    {
        NSLog(@"成功了调用了这接口----%@",dataSource);
    } errorBlock:^(int code, NSString *error) {
        NSLog(@"失败了调用这个接口----%@",error);
    }];
    
    @weakify(self);
    [XHHLoginRequest requestLogin:self.phone.text
                         password:self.password.text
                             type:@"0"
                     successBlock:^(id dataSource)
     {
         XHHAuthViewController *vc = [XHHAuthViewController initWithStoryboard:@"LoginStroy"];
         [self.navigationController pushViewController:vc animated:YES];
     } errorBlock:^(int code, NSString *error) {
         ChZ_MBDismssError(error);
         @strongify(self);
         [self.navigationController popViewControllerAnimated:YES];
     }];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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
