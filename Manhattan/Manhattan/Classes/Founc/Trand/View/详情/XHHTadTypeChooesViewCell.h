//
//  XHHTadTypeChooesViewCell.h
//  FuturePurse
//
//  Created by Apple on 2018/7/27.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHHCoinListModel.h"
@interface XHHTadTypeChooesViewCell : UICollectionViewCell

-(void)reloadCellWithDic:(NSDictionary *)dic;
-(void)reloadCellWithModel:(XHHCoinListModel *)model;

@end
