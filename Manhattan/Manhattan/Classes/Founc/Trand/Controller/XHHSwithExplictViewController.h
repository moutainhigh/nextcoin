//
//  XHHSwithExplictViewController.h
//  FuturePurse
//
//  Created by Apple on 2018/8/29.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "BaseViewController.h"
@interface XHHSwithExplictViewController : BaseViewController
//交易ID
@property (nonatomic , copy) NSString *symblId;
@property (strong, nonatomic) NSString *buyName;
@property (strong, nonatomic) NSString *sellName;
@end
