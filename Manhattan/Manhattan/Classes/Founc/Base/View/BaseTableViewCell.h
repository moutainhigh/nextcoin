//
//  BaseTableViewCell.h
//  CoinWallet
//
//  Created by Howe on 2018/5/15.
//  Copyright © 2018年 Howe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger  index;

@property (nonatomic, assign) NSInteger  section;

@property (nonatomic, copy) ChZ_CellSelectedCallBackBlock  block;



@end