//
//  ChZAddAlipayAccountController.m
//  FuturePurse
//
//  Created by Howe on 2018/8/3.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "ChZAddAlipayAccountController.h"
#import "ChZAccountRequest.h"
#import "UIImage+ChZExtension.h"
@interface ChZAddAlipayAccountController ()
@property (weak, nonatomic) IBOutlet UITextField *accountNameField;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UIButton *addImgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *upImgView;
@property (nonatomic, strong) UIImage *qrcodeImage;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;


@end

@implementation ChZAddAlipayAccountController

- (void)viewDidLoad {
//    self.toChZConfigHandle = YES;
    [self.accountField configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:ChZ_Color(75, 75, 128)];
    [self.accountNameField configPlaceholderWithFont:[UIFont systemFontOfSize:16.0] textColor:ChZ_Color(75, 75, 128)];
    [super viewDidLoad];
    
    @weakify(self);
    [[self.accountField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if (x.length > 20)
        {
            self.accountField.text = [x substringToIndex:20];
        }
    }];
}
- (IBAction)backAction:(id)sender
{
    [self pop];
}

- (IBAction)addImgAction:(id)sender
{
    ChZ_Weak
    [self selectImageEdit:YES selectedFinish:^(UIImage *image)
    {
        ChZ_Strong
//        [_strongSelf.addImgBtn setImage:image forState:UIControlStateNormal];
        _strongSelf.upImgView.image = image;
        _strongSelf.qrcodeImage = image;
        _strongSelf.alertLabel.hidden = YES;
    }];
}

- (IBAction)saveAction:(id)sender
{
    NSString *account = self.accountField.text;
    NSString *name = self.accountNameField.text;
    if (!ChZ_StringIsEmpty(account))
    {
        ChZ_MBError(@"请输入账号")
        return;
    }
    if (!ChZ_StringIsEmpty(name)) {
        ChZ_MBError(@"请输入姓名")
        return;
    }
    if (self.qrcodeImage == nil) {
        ChZ_MBError(@"请选择二维码")
        return;
    }
    NSString *imgbase64 = [self.qrcodeImage base64String];
    ChZ_MBMsg(nil)
    ChZ_Weak
    [ChZAccountRequest requestSubmitAlipayPayAccount:account qrcode:imgbase64 name:name successBlock:^(id dataSource) {
        ChZ_Strong
        ChZ_MBDismssSuccess(@"添加成功")
        if (_strongSelf.callBackBlock) {
            _strongSelf.callBackBlock(nil);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_strongSelf pop];
        });
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBDismssError(error)
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
