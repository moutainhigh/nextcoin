//
//  XHHThrowOutController.m
//  Manhattan
//
//  Created by Apple on 2018/8/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHThrowOutController.h"
#import "XHHPublicNavView.h"
@interface XHHThrowOutController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITextField *moneyTextFeild;

@property (nonatomic , strong) XHHPublicNavView           *navView;
@property (weak, nonatomic) IBOutlet UILabel *canUseMoneyLable;
@property (weak, nonatomic) IBOutlet UILabel *canInputLable;

@property (nonatomic , copy) NSString *cnyId;
@end

@implementation XHHThrowOutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zh_setupUI];
    
//    NSArray *cnyList = [APPControl sharedAPPControl].listArray;
//    for(ChZMarketListModel *model in cnyList)
//    {
//        if ([model.sellShortName isEqualToString:@"MTH-X"])
//        {
//            self.cnyId = model.fid;
//            [self requestMyHaveCny];
//            break;
//        }
//    }
    [self requestMyHaveCny];
    [self.moneyTextFeild configPlaceholderWithFont:[UIFont systemFontOfSize:20.0] textColor:[UIColor colorWithHexString:@"4B4B80"]];
    // Do any additional setup after loading the view.
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
}
-(XHHPublicNavView *)navView
{
    if (!_navView)
    {
        _navView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPublicNavView" owner:nil options:nil] lastObject];
        [_navView setLeftButtonTitle:@"立即投入" image:@"public_nav_leftBack"];
    }
    return _navView;
}
-(void)requestMyHaveCny
{
    @weakify(self);
    [ChZHomeRequest requestCnyHaveNumUid:[APPControl sharedAPPControl].user.fid cnyId:@"55" successBlock:^(NSString *dataSource)
    {
        @strongify(self);
        
        if (ChZ_StringIsEmpty(dataSource)) {
            self.canUseMoneyLable.text = [NSString stringWithFormat:@"%.4f",[dataSource doubleValue]];
            self.canInputLable.text = [NSString stringWithFormat:@"可转入%.4f",[dataSource doubleValue]];
        }else{
            self.canUseMoneyLable.text = @"0.0000";
            self.canInputLable.text = @"可转入0.0000元";
        }
        
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBError(@"查询币种余额失败");
    }];
}
- (IBAction)inputAction:(id)sender
{
    NSString *throwType = self.throwType == XHHThrowTypeUSDT ? @"2":@"1";
    ChZ_MBMsg(nil);
    [XHHMiningRequest requestMiningInputMiningType:throwType
                                               num:self.moneyTextFeild.text
                                           coin_id:@"55"
                                           success:^(id dataSource)
    {
        ChZ_MBDismss
        ChZ_MBSuccess(@"投入成功")
        self.callBackBlock(nil);
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(int code, NSString *error) {
        ChZ_MBDismss
        ChZ_DebugLog(@"%@",error);
    }];
}
- (IBAction)allInput:(id)sender {
    self.moneyTextFeild.text = self.canUseMoneyLable.text;
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
