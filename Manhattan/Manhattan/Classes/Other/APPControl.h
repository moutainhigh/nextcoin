//
//  APPControl.h
//  Manhattan
//
//  Created by Apple on 2018/9/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "UserModel.h"
#import "AppDelegate.h"
#import "ChZMarketListModel.h"
#import "ChZMarketAreaModel.h"
#import "XHHWalletModel.h"
typedef NS_ENUM(NSInteger,CoinCurrencyType)
{
    CoinCurrencyTypeRMB = 0,
    CoinCurrencyTypeUSD = 1
};
@interface APPControl : NSObject
SingletonH(APPControl)

@property (nonatomic, weak) AppDelegate *appDelegate;

@property (nonatomic, assign) CoinCurrencyType conType;

@property (nonatomic, strong) UserModel  *user;

@property (nonatomic , copy) NSString *token;

@property (nonatomic , copy) NSString *secretKey;

@property (nonatomic, assign) BOOL  isLogin;
//美元人民币比例
@property (nonatomic , copy) NSString *cny;

@property (nonatomic , strong) NSArray *allIconPrice;

@property (nonatomic , strong) NSArray *allCoins;

@property (nonatomic, assign) float  totalassets;

@property (nonatomic, assign) BOOL isSetPayPassword;

@property (nonatomic , strong) WalletListModel *ETHModel;
/**
 市场列表
 */
@property (nonatomic, strong) NSArray<ChZMarketAreaModel *>  *areaArray;

@property (nonatomic, strong) NSArray<ChZMarketListModel *> *listArray ;

/**
 钱包最新行情
 */
@property (nonatomic, strong) NSArray *walletNewsArray;

- (void)requestUSDT:(NSArray *)areaList;

- (void)toLogin;

- (void)toHome;

- (void)checkUpdate;

@end
