//
//  XHHSalesEntrustView.h
//  FuturePurse
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChZMarketListModel.h"
@interface XHHSalesEntrustView : UIView
@property (nonatomic, strong) ChZMarketListModel  *model;
@property (weak, nonatomic) IBOutlet UITextField *priceTextFeild;//价格
@property (weak, nonatomic) IBOutlet UITextField *muchTextFeild;//数量
@property (weak, nonatomic) IBOutlet UILabel *typeLable;
@property (weak, nonatomic) IBOutlet UILabel *numTypeLable;
@property (assign, nonatomic) double progressVlalue;

@property (nonatomic , copy) void (^buySellBlock)(BOOL isSell);
@property (nonatomic , copy) NSString *sellMoney;
@property (nonatomic , copy) NSString *buyMoney;

@end
