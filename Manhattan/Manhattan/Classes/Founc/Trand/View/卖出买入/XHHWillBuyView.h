//
//  XHHWillBuyView.h
//  FuturePurse
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHHC2CCnyListModel.h"
@interface XHHWillBuyView : UIView

@property (nonatomic , strong) NSArray *cnyList;
@property (nonatomic , strong) XHHC2CCnyListModel *cnyModel;

@property (weak, nonatomic) IBOutlet UITextField *payTypeTextFeild;
@property (nonatomic , copy) NSString *payTypes;
@property (weak, nonatomic) IBOutlet UITextField *currPrice;
@property (weak, nonatomic) IBOutlet UITextField *buyNumber;
@property (weak, nonatomic) IBOutlet UITextField *minSellNumber;
@property (weak, nonatomic) IBOutlet UITextField *maxSellNumber;

@property (nonatomic , strong) NSString * currPriceString;

@property (weak, nonatomic) IBOutlet UILabel *numType;
@property (weak, nonatomic) IBOutlet UILabel *minType;
@property (weak, nonatomic) IBOutlet UILabel *maxType;
@property (weak, nonatomic) IBOutlet UILabel *willUseMoney;
@property (weak, nonatomic) IBOutlet UILabel *cnyTypLable;

@property (copy, nonatomic) void (^payBlock)(void);

@end
