//
//  ChZRealCoinInfoModel.h
//  FuturePurse
//
//  Created by Howe on 2018/8/8.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "BaseObject.h"

@interface ChZRealCoinInfoModel : BaseObject

@property (nonatomic, copy) NSString * symbol;
@property (nonatomic, copy) NSString * sellSymbol;
@property (nonatomic, copy) NSString * total;//数量
@property (nonatomic, copy) NSString * buySymbol;
@property (nonatomic, copy) NSString * p_open;//开盘价
@property (nonatomic, copy) NSString * p_new;//最新价
@property (nonatomic, copy) NSString * buy;//最低价
@property (nonatomic, copy) NSString * sell;//最高价
@property (nonatomic, copy) NSString * tradeId;//最高价
@property (nonatomic , copy) NSString *chg;//涨幅
@property (nonatomic, copy) NSString * iconURL;

@end
