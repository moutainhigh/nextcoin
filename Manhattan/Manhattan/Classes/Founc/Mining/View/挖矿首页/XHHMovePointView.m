//
//  XHHMovePointView.m
//  Manhattan
//
//  Created by Apple on 2018/8/30.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "XHHMovePointView.h"
#import "UIView+i7Rotate360.h"
 #define XHHWidthProportion ChZ_WIDTH/320.0
@interface XHHMovePointView ()

@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic , strong) UIImageView *imageView2;

@property (nonatomic , strong) UIImage *image1;
@property (nonatomic , strong) UIImage *image2;


@property (strong, nonatomic) UIView *lightView1;
@property (strong, nonatomic) UIView *lightView2;

@property (nonatomic , strong) UIColor *roundColor;
@property (assign , nonatomic) CGFloat imgY;
@property (assign , nonatomic) CGFloat imgY2;
@end


@implementation XHHMovePointView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        [self zh_setupUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRotate) name:@"BEGINSCROLLOW" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMiningSuccess:) name:@"GETMININGSUCCESS" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTimer) name:@"CLOSETIMER" object:nil];
        
    }
    return self;
}
-(void)moddleImage:(UIImage *)image
{
    self.image1 = image;
    self.imageView.image = image;
}
-(void)topImage:(UIImage *)image
{
    self.image2 = image;
    self.imageView2.image = image;
}
-(void)lightColor:(UIColor *)color{
    
    self.roundColor = color;
    [self.lightView1 setGradientBackgroundWithColors:@[color,[UIColor clearColor]] locations:nil startPoint:CGPointMake(0, 1) endPoint:CGPointMake(0, 0)];

    [self.lightView2 setGradientBackgroundWithColors:@[color,[UIColor clearColor]] locations:nil startPoint:CGPointMake(0, 1) endPoint:CGPointMake(0, 0)];
}
-(void)zh_setupUI{
    
    UIView *bigView = [[UIView alloc] init];
    bigView.alpha = 0.4;
    bigView.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:bigView];
    self.lightView1 = bigView;
    [bigView setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"1eddfe"],[UIColor colorWithHexString:@"0B1031"]] locations:nil startPoint:CGPointMake(0, 1) endPoint:CGPointMake(0, 0)];
    CGFloat imagex = 0;
    if (self.width > 28*XHHWidthProportion)
    {
       imagex = 7;
        
    }else if (24*XHHWidthProportion < self.width  && self.width < 29*XHHWidthProportion)
    {
        imagex = 5;
    }else if (20*XHHWidthProportion < self.width  && self.width < 25*XHHWidthProportion)
    {
        imagex = 3;
    }else
    {
        imagex = 0;
    }
    
    UIView *bigView1 = [[UIView alloc] init];
    bigView1.alpha = 0.4;
    bigView1.frame = CGRectMake(imagex, 0, self.width-2*imagex, self.height);
    [self addSubview:bigView1];
    self.lightView2 = bigView1;
    [bigView1 setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"1eddfe"],[UIColor colorWithHexString:@"0B1031"]] locations:nil startPoint:CGPointMake(0, 1) endPoint:CGPointMake(0, 0)];
    
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    imageView.image = [UIImage imageNamed:@"mining_trad_blueTT"];
    imageView.frame = CGRectMake(imagex, self.height - (self.width-2*imagex), self.width-2*imagex, self.width-2*imagex);
    [self addSubview:imageView];
    //[imageView rotate360WithDuration:10 repeatCount:100000 timingMode:i7Rotate360TimingModeLinear];
    self.imgY = imageView.y;
    
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    self.imageView2 = imageView2;
    imageView2.image = [UIImage imageNamed:@""];
    imageView2.frame = CGRectMake(2*imagex, self.height - 2*(self.width-2*imagex), self.width-2*imagex, self.width-2*imagex);
    [self addSubview:imageView2];
    //[imageView2 rotate360WithDuration:10 repeatCount:100000 timingMode:i7Rotate360TimingModeLinear];
    self.imgY2 = imageView2.y;
}

-(void)beginRotate
{
    
    switch (self.isRotate) {
        case XHHRoteTypeUpDownAnRoteAnddBubble:
            [self.imageView rotate360WithDuration:10 repeatCount:100000 timingMode:i7Rotate360TimingModeLinear];
            [self.imageView2 rotate360WithDuration:10 repeatCount:100000 timingMode:i7Rotate360TimingModeLinear];
            [self _loadTimer];
            break;
        case XHHRoteTypeRoteAndBubble:
            [self.imageView rotate360WithDuration:10 repeatCount:100000 timingMode:i7Rotate360TimingModeLinear];
            [self _loadTimer];
            break;
        case XHHRoteTypeWithnotBubbleAndRote:
            
            break;
        case XHHRoteTypeUpDownAndBubble:
            [self _loadTimer];
            break;
            
        default:
            break;
    }
}
-(void)imageUpDown
{
    [UIView animateWithDuration:0.8 animations:^{
        if (self.imageView.y == self.imgY)
        {
            self.imageView.y = self.imgY - 5;
        }else
        {
            self.imageView.y = self.imgY;
        }
        if (self.imageView2.y == self.imgY2)
        {
            self.imageView2.y = self.imgY2 - 5;
        }else
        {
            self.imageView2.y = self.imgY2;
        }
    } completion:^(BOOL finished)
    {
 
    }];
}
-(void)getMiningSuccess:(NSNotification *)noti
{
    XHHMiningHomeModel *succModel = noti.object;
    if ([succModel.getid isEqualToString:self.model.getid])
    {
        [self removeImageRotate];
    }
}
- (void)_refreshData
{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = self.roundColor;
    CGFloat w = [self getRandomNumber:1 to:6];
    v.frame = CGRectMake([self getRandomNumber:4 to:26], [self getRandomNumber:self.height to:self.height +5], w, w);
    v.layer.cornerRadius = w/2;
    v.layer.masksToBounds = YES;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:v.bounds];
    v.layer.shadowColor = [UIColor blackColor].CGColor;
    // 阴影偏移量
    v.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    // 阴影的透明度
    v.layer.shadowOpacity = 0.8f;
    // 设置阴影路径
    v.layer.shadowPath = shadowPath.CGPath;
    
    
    
    [self addSubview:v];
    [UIView animateWithDuration:15 animations:^{
        v.y = -10;
        v.width = 0;
        v.height = 0;
    } completion:^(BOOL finished) {

        [v removeFromSuperview];
    }];
    
    if(self.isRotate)
    {
        [self imageUpDown];
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    if (self.clickBlock)
    {
        self.clickBlock(self.model);
    }
    if(self.model)
    {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CLICKMINGAREA" object:self.model];
    }
    
   
}
- (void)_loadTimer
{
    if (self.timer == nil)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(_refreshData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
- (void)_removeTimer
{
    if (_timer && _timer.valid) {
        [_timer invalidate];
    }
    _timer = nil;
}
- (void)dealloc
{
    
    [self _removeTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BEGINSCROLLOW" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GETMININGSUCCESS" object:nil];
}
-(void)closeTimer
{
    [self _removeTimer];
    [self.imageView rotate360WithDuration:1 repeatCount:1 timingMode:i7Rotate360TimingModeLinear];
    if (self.imageView2.image)
    {
        [self.imageView2 rotate360WithDuration:1 repeatCount:1 timingMode:i7Rotate360TimingModeLinear];
    }
}
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}
-(void)removeImageRotate
{
    self.imageView.hidden = YES;
    self.imageView2.hidden = YES;
}
-(void)showImageRotate
{
    self.imageView.hidden = NO;
    self.imageView2.hidden = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
