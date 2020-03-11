//
//  XHHOrderNumberView.m
//  FuturePurse
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHOrderNumberView.h"

@interface XHHOrderNumberView ()

@property (weak, nonatomic) IBOutlet UILabel *typeLable;

@property (weak, nonatomic) IBOutlet UILabel *orderNmuberLable;


@end

@implementation XHHOrderNumberView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setType:(NSInteger)type{
    if (type == 1) {
        self.typeLable.text = @"买入";
    }else{
        self.typeLable.text = @"卖出";
    }
    
}
-(void)reloadViewWithModel:(XHHC2CMyOrderModel *)model{
    self.orderNmuberLable.text = model.sn;
}
@end
