//
//  XHHShareView.m
//  Manhattan
//
//  Created by Apple on 2018/8/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHShareView.h"
@interface XHHShareView ()

@property (weak, nonatomic) IBOutlet UIButton *grayButton;

@property (nonatomic , strong) NSString *shareUrl;

@end


@implementation XHHShareView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.shareUrl = [NSString stringWithFormat:@"%@&intro=%@",RequestURL(kURL_mine_shareAddress),[APPControl sharedAPPControl].user.fid];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)showInView:(UIView *)view{
    [view addSubview:self];
    self.frame = CGRectMake(0, ChZ_HEIGHT, ChZ_WIDTH, ChZ_HEIGHT);
    [UIView animateWithDuration:0.5 animations:^{
        self.y = 0;
    } completion:^(BOOL finished) {
        self.grayButton.hidden = NO;
    }];
}
-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        self.y = ChZ_HEIGHT;
        self.grayButton.hidden = YES;
    } completion:^(BOOL finished) {
        self.alpha = 1;
        [self removeFromSuperview];
    }];
}
- (IBAction)hiddleAction:(UIButton *)sender {
    [self dismiss];
    self.grayButton.hidden = YES;
}
- (IBAction)weixinAction:(id)sender {
    [self copyShareUrl];
}
- (IBAction)GAction:(id)sender {
    [self copyShareUrl];
}
- (IBAction)FAction:(id)sender {
    [self copyShareUrl];
}
- (IBAction)bridAction:(id)sender {
    [self copyShareUrl];
}

-(void)copyShareUrl{
    UIPasteboard *pasetBoard = [UIPasteboard generalPasteboard];
    pasetBoard.string = self.shareUrl;
    ChZ_MBSuccess(@"复制分享地址成功")
    [self dismiss];
}

@end
