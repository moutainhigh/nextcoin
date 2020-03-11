//
//  ChZPopQRCodeView.m
//  CoinBlock
//
//  Created by Howe on 2018/8/17.
//  Copyright © 2018年 Howe. All rights reserved.
//

#import "ChZPopQRCodeView.h"
#import "SGQRCodeTool.h"

@interface ChZPopQRCodeView()
@property (weak, nonatomic) IBOutlet UIImageView *qrImgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ChZPopQRCodeView
- (IBAction)closeAction:(id)sender
{
    [self close];
}
- (void)close
{
    [UIView animateWithDuration:0.1 animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.contentView.alpha = 0.1f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (instancetype)showToView:(UIView *)view  qrcodeurl:(NSString *)qrcodeurl
{
    ChZPopQRCodeView *viewSelf = [ChZPopQRCodeView nibLoadSelf];
    viewSelf.frame = view.bounds;
    if ([qrcodeurl containsString:@"http"])
    {
        [viewSelf.qrImgView sd_setImageWithURL:[NSURL URLWithString:qrcodeurl]];
    }else
    {
        [viewSelf.qrImgView sd_setImageWithURL:[NSURL URLWithString:RequestURL(qrcodeurl)]];
    }
//    viewSelf.qrImgView.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:qrcode imageViewWidth:150];
    [view addSubview:viewSelf];
    viewSelf.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.1 animations:^{
        viewSelf.contentView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            viewSelf.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }completion:^(BOOL finished) {
        }];
    }];
    return viewSelf;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view != self && [view isMemberOfClass:[UIView class]])
    {
        return self.contentView;
    }
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (touch.view == self.contentView) {
            return;
        }
        [self closeAction:nil];
        return;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
