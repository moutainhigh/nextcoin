//
//  XTTMyPurseView.m
//  FuturePurse
//
//  Created by muye01 on 2018/7/31.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XTTMyPurseView.h"
#import "XTTMyPurseBottomView.h"
#import "XTVerCodeInput.h"
//#import "XHHPayPwdForgetController.h"
NSString * const XTTMyPurseViewNibName = @"MyPurseView";

@implementation XTTMyPurseView

@end

@interface XTTMyPurseHeaderView()


@end

@implementation XTTMyPurseHeaderView

+(instancetype)loadFromNib{

  
    NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
    XTTMyPurseHeaderView *view =nibs[0];
    view.amountLabel.text = @"";


    return view;
}
- (void)setAmount:(NSString *)amount{
    _amountLabel.text = [NSString stringWithFormat:@"%.4f",amount.floatValue];
}
@end

@interface XTTMyPurseTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *freezeAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *freezeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *balanceAmountLabel;

@property (weak, nonatomic) IBOutlet UILabel *balanceNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet XTTMyPurseBottomView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *backGrdView;

@end

@implementation XTTMyPurseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
    self = nibs[1];
    
    return self;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [_backGrdView addShadow];
    self.backgroundColor = [UIColor clearColor];
    _backGrdView.backgroundColor = [UIColor whiteColor];
    
    @weakify(self);
    _bottomView.didSelectItemBlock = ^(NSInteger index, NSString *title) {
        @strongify(self);
        if (self.didSelectBottomItemBlock) {
            self.didSelectBottomItemBlock(index, title);

        }
    };
}
-(void)setModel:(WalletListModel *)model{
    _model = model;
    _statusLabel.hidden = YES;
    _nameLabel.text = [NSString stringWithFormat:@"%@",model.shortName];
    _freezeAmountLabel.text = [NSString stringWithFormat:@"%.4f",model.frozen.floatValue];
    _balanceAmountLabel.text = [NSString stringWithFormat:@"%.4f",model.total];
    
}
- (void)setBottomTitles:(NSArray *)bottomTitles{
    _bottomTitles = bottomTitles;
    _bottomView.titles = bottomTitles;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@interface XTTMPSDepositRecordTableCell()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *feeLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation XTTMPSDepositRecordTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self = [XTTMPSDepositRecordTableCell loadViewWithNibName:XTTMyPurseViewNibName atIndex:3];
        NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
        self = nibs[3];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)setModel:(RecordModel *)model{
    self.statusLabel.text = model.fstatus_s;
    if (ChZ_StringIsEmpty(model.fcreatetime)) {
        double timeInterval = [model.fcreatetime doubleValue];
        timeInterval = timeInterval/1000;
        NSString *date = [NSString stringWithFormat:@"%.0f",timeInterval];
        NSString *dateString = [ChZUtil chz_getDateAndTimeWithTimeIntervalSince1970:date];
        self.timeLabel.text = dateString;
    }
    
    self.amountLabel.text = [NSString stringWithFormat:@"%.4f",model.famount.floatValue];
    self.feeLabel.text = [NSString stringWithFormat:@"%.4f",model.ffees.floatValue];
    if (ChZ_StringIsEmpty(model.fwithdrawaddress)) {
        self.addressLabel.text = model.fwithdrawaddress;
    }
    if (ChZ_StringIsEmpty(model.frechargeaddress)) {
        self.addressLabel.text = model.frechargeaddress;
    }
}
@end

@interface XTTMPSAddressListTableCell()

@end

@implementation XTTMPSAddressListTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self = [XTTMPSAddressListTableCell loadViewWithNibName:XTTMyPurseViewNibName atIndex:4];
        NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
        self = nibs[4];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


@interface XTTMPSAddAddressTelVerCodeView()
@property (weak, nonatomic) IBOutlet XTVerCodeInput *verCodeView;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UIButton *telCodeBtn;
@end

@implementation XTTMPSAddAddressTelVerCodeView

+(instancetype)loadFromNib{
    
//    XTTMPSAddAddressTelVerCodeView *view = [XTTMPSAddAddressTelVerCodeView loadViewWithNibName:XTTMyPurseViewNibName atIndex:5];
    NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
    XTTMPSAddAddressTelVerCodeView *view = nibs[5];
    return view;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self config];
    
}

-(void)config
{
    UserModel *user = [APPControl sharedAPPControl].user;
    NSString *securityPhone= [NSString phoneString:user.ftelephone];
    _telLabel.text = [NSString stringWithFormat:@"验证码已发送至+86 %@",securityPhone];
    [_telCodeBtn  startWithTime:59 title:@"没收到验证码？重新发送" countDownTitle:@"s重新发送" mainColor:[UIColor whiteColor] countColor:[UIColor whiteColor]];

    _verCodeView.inputType = 6;
    _verCodeView.keyboardType = UIKeyboardTypeNumberPad;
    [_verCodeView  setupSubviews];
    @weakify(self);
    _verCodeView.verCodeBlock = ^(NSString *text) {
        NSLog(@"您输入的验证码是%@",text);
        @strongify(self);
        if (self.verCodeInputBlock) {
            self.verCodeInputBlock(text);
            
        }
    };
}
- (IBAction)dismissAction:(id)sender
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

-(void)dismiss{
    
}
- (IBAction)sendTelCodeAction:(id)sender
{
    [_telCodeBtn  startWithTime:59 title:@"没收到验证码？重新发送" countDownTitle:@"s重新发送" mainColor:[UIColor whiteColor] countColor:[UIColor whiteColor]];
    if (self.sendTelCodeBlock) {
        self.sendTelCodeBlock();
    }
    
}
@end

@interface XTTMPSTradePwdView()

@property (weak, nonatomic) IBOutlet UITextField *tradePwdTxt;


@end


@implementation XTTMPSTradePwdView

+(instancetype)loadFromNib{
    
//    XTTMPSTradePwdView *view = [XTTMPSTradePwdView loadViewWithNibName:XTTMyPurseViewNibName atIndex:6];
    NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
    XTTMPSTradePwdView *view = nibs[6];
    return view;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    _tradePwdTxt.secureTextEntry = YES;
}
- (IBAction)didClickCancelButton:(id)sender {
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
- (IBAction)didClickForgetTradePwdButton:(id)sender {
    if (self.forgetTradePwdBlock) {
        self.forgetTradePwdBlock();
        return;
    }
  
//        XHHPayPwdForgetController *vc = [XHHPayPwdForgetController initWithStoryboard:@"Mine"];
//        vc.title = @"设置支付密码";
//    if (self.viewController.navigationController != nil) {
//        [self.viewController.navigationController pushViewController:vc animated:YES];
//    }else{
//        [self.viewController.presentingViewController.navigationController pushViewController:vc animated:YES];
//    }
 
}
- (IBAction)didClickSureButton:(id)sender {
    if (self.sureBlock) {
        self.sureBlock(_tradePwdTxt.text);
    }
}

@end


@interface XTTMPSAddAddressGoogleCodeView()
@property (weak, nonatomic) IBOutlet XTVerCodeInput *verCodeView;
@end

@implementation XTTMPSAddAddressGoogleCodeView

+(instancetype)loadFromNib{
    
//    XTTMPSAddAddressGoogleCodeView *view = [XTTMPSAddAddressGoogleCodeView loadViewWithNibName:XTTMyPurseViewNibName atIndex:7];
    NSArray *nibs = [[UINib nibWithNibName:XTTMyPurseViewNibName bundle:nil] instantiateWithOwner:nil options:nil];
    XTTMPSAddAddressGoogleCodeView *view = nibs[7];
    return view;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self config];
    
}

-(void)config{
    _verCodeView.inputType = 6;
    _verCodeView.keyboardType = UIKeyboardTypeNumberPad;
    [_verCodeView  setupSubviews];
    @weakify(self);
    _verCodeView.verCodeBlock = ^(NSString *text) {
        NSLog(@"您输入的验证码是%@",text);
        @strongify(self);
        if (self.verCodeInputBlock) {
            self.verCodeInputBlock(text);
            
        }
    };
}
- (IBAction)dismissAction:(id)sender {
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

-(void)dismiss{
    
}

@end
