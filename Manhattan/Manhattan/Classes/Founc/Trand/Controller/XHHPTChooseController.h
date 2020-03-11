//
//  XHHPTChooseController.h
//  Manhattan
//
//  Created by Apple on 2018/8/21.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "BaseViewController.h"
@class XHHPayTypeModel;
#import "XHHC2CCnyListModel.h"
@interface XHHPTChooseController : BaseViewController

@property (nonatomic , strong) NSArray *cnyList;

@property (nonatomic , copy) NSString *shopId;

@property (nonatomic , strong) void (^choosePayTypeBlock)(XHHPayTypeModel *model);

@property (nonatomic , strong) void (^chooseCnyBlock)(XHHC2CCnyListModel *model);

@property (strong, nonatomic) XHHC2CCnyListModel *selectedCoinmodel;

@end
