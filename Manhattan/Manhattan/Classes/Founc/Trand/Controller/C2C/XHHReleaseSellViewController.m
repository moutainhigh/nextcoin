//
//  XHHReleaseSellViewController.m
//  Manhattan
//
//  Created by Apple on 2018/9/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHReleaseSellViewController.h"
#import "XHHMineSetpswViewController.h"
#import "XHHWillSellView.h"
#import "XHHPayPwView.h"
@interface XHHReleaseSellViewController ()<YXTextFieldDelegate,XHHPayPwViewProtocol>

@property (strong, nonatomic) XHHWillSellView             *sellView;

@property (strong, nonatomic) XHHPayPwView     *passWordView;//输入交易密码视图

@end

@implementation XHHReleaseSellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.cnyList.count) {
        XHHC2CCnyListModel *model = self.cnyList[0];
        self.cnyId = model.fid;
        self.sellView.maxType.text = model.short_name;
        self.sellView.minType.text = model.short_name;
        self.sellView.numType.text = model.short_name;
        self.sellView.cnyTypLable.text = model.short_name;
        self.sellView.cnyModel = model;
        @weakify(self);
        [ChZHomeRequest requestCoinReleasePriceCoinName:model.short_name successBlock:^(id dataSource)
         {
             @strongify(self);
             if(dataSource)
             {
                 self.sellView.currPriceString = [NSString stringWithFormat:@"%@",[dataSource objectForKey:@"price"]];
                 self.sellView.currPrice.text = [NSString stringWithFormat:@"%@",[dataSource objectForKey:@"price"]];
             }else
             {
                 ChZ_MBError(@"获取币种价格失败");
             }
         } errorBlock:^(NSString *error) {
             ChZ_MBError(@"请求失败");
         }];
    }
    self.sellView.cnyList = self.cnyList;
    
    [self zh_setupUI];
    
    // Do any additional setup after loading the view.
}

-(void)zh_setupUI{
    //背景滚动视图
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 16, 0, 16));
    }];
    
    [bgScrollView addSubview:self.sellView];
    [self.sellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(bgScrollView).insets(UIEdgeInsetsZero);
        make.width.mas_equalTo(ChZ_WIDTH-32);
        make.height.mas_equalTo(540);
    }];
}
-(void)setCnyId:(NSString *)cnyId{
    _cnyId = cnyId;
    [self requestMyHaveCny];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(XHHWillSellView *)sellView{
    if (!_sellView) {
        _sellView = [[[NSBundle mainBundle] loadNibNamed:@"XHHWillSellView" owner:nil options:nil] lastObject];
        @weakify(self);
        _sellView.cnyBlock = ^(NSString *cnyId)
        {
            @strongify(self);
            self.cnyId = cnyId;
        };
        _sellView.payBlock = ^{
            @strongify(self);
            if (self.sellView.currPrice.text.length ==0) {
                ChZ_MBError(@"请输入当前价格");
                return;
            }
            if (self.sellView.buyNumber.text.length ==0) {
                ChZ_MBError(@"请输入出售数量");
                return;
            }
            if (self.sellView.minSellNumber.text.length ==0) {
                ChZ_MBError(@"请输入最小购买数量");
                return;
            }
            if (self.sellView.payTypeTextFeild.text.length ==0) {
                ChZ_MBError(@"请选择收款方式");
                return;
            }
            if([self.sellView.minSellNumber.text floatValue] > [self.sellView.buyNumber.text floatValue])
            {
                ChZ_MBError(@"最小购买数量不得大于出售数量");
                return;
            }
            if ([APPControl sharedAPPControl].isSetPayPassword)
            {
                [self.passWordView showInView:self.view];
                self.passWordView.height = self.view.bounds.size.height;
            }else
            {
                [self showTheAlertVCWithStyle:UIAlertControllerStyleAlert title:nil message:@"您还未设置交易密码，快去设置吧！" title1:@"取消" action1:^{
                    
                } title2:@"马上去" action2:^
                 {
                     XHHMineSetpswViewController *vc = [XHHMineSetpswViewController initWithStoryboard:@"MineStroy"];
                     [[ChZUtil getCurrentVC].navigationController pushViewController:vc animated:YES];
                 } title3:nil action3:nil completion:nil];
            }
            [self.view endEditing:YES];
        };
        
    }
    return _sellView;
}
- (XHHPayPwView *)passWordView{
    if (!_passWordView)
    {
        _passWordView = [[[NSBundle mainBundle] loadNibNamed:@"XHHPayPwView" owner:nil options:nil] lastObject];
        _passWordView.delegate = self;
    }
    return _passWordView;
}
-(void)payViewSure:(NSString *)pwd{
    if (!ChZ_StringIsEmpty(pwd))
    {
        ChZ_MBError(@"请输入密码");
        return;
    }
    [self requestSellWithPassWord:pwd];
}
//发布卖出
-(void)requestSellWithPassWord:(NSString *)passWord
{
    if (!ChZ_StringIsEmpty(passWord))
    {
        ChZ_MBError(@"请输入交易密码")
        return;
    }
    NSString *buyNumber = self.sellView.buyNumber.text;
    NSString *currPrice = self.sellView.currPrice.text;
    NSString *minSellNumber = self.sellView.minSellNumber.text;
    NSString *maxSellNumber = self.sellView.maxSellNumber.text;
    NSString *payType = self.sellView.payTypeTextFeild.text;
    NSString *cymbolName = self.sellView.minType.text;
    ChZ_MBMsg(nil)
    @weakify(self);
    [ChZHomeRequest requestC2CSendSellUid:[APPControl sharedAPPControl].user.fid
                                 passWord:passWord
                                  country:@"China"
                                      num:buyNumber
                                    price:currPrice
                                    cnyId:self.sellView.cnyModel.fid
                                 minValue:minSellNumber
                                 maxValue:maxSellNumber
                                  payType:payType
                               symbolName:cymbolName
                             successBlock:^(id dataSource)
     {
         @strongify(self);
         //        ChZ_MBSuccess(@"发布卖出成功");
         self.sellView.buyNumber.text = nil;
         self.sellView.currPrice.text = nil;
         self.sellView.minSellNumber.text = nil;
         self.sellView.maxSellNumber.text = nil;
         self.sellView.payTypeTextFeild.text = nil;
         ChZ_MBDismss
         if(self.SellSuccessBlock) self.SellSuccessBlock();
     } errorBlock:^(int code, NSString *error) {
         ChZ_MBDismssError(error);
     }];
}
-(void)requestMyHaveCny{
    @weakify(self);
    [ChZHomeRequest requestCnyHaveNumUid:[APPControl sharedAPPControl].user.fid cnyId:self.cnyId successBlock:^(NSString *dataSource) {
        @strongify(self);
        
        if (ChZ_StringIsEmpty(dataSource)) {
            self.sellView.canSellNumber.text = [NSString stringWithFormat:@"%.4f",[dataSource floatValue]];
        }else{
            self.sellView.canSellNumber.text = @"0.0000";
        }
        
    } errorBlock:^(int code, NSString *error) {
        ChZ_MBError(@"查询币种余额失败");
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
