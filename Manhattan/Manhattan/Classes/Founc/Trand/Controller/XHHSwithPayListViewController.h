//
//  XHHSwithPayListViewController.h
//  FuturePurse
//
//  Created by Apple on 2018/8/29.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "BaseViewController.h"
@interface XHHSwithPayListViewController : BaseViewController
//交易ID
@property (nonatomic , copy) NSString  *symblId;
@property (nonatomic, strong) NSString *sellName;
@property (nonatomic, strong) NSString *buyName;
@end
