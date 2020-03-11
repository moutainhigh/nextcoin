//
//  XHHTradHomeCell.m
//  FuturePurse
//
//  Created by Apple on 2018/7/25.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHTradHomeCell.h"
#import "ChZRealCoinInfoModel.h"

@interface XHHTradHomeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *sumLable;
@property (weak, nonatomic) IBOutlet UILabel *pricLable;
@property (weak, nonatomic) IBOutlet UILabel *sumPriceLable;
@property (weak, nonatomic) IBOutlet UIButton *upLable;

@property (nonatomic , assign) NSInteger reshData;

@property (nonatomic , strong) ChZMarketListModel *model;

@property (nonatomic, strong) NSTimer  *timer;

@end

@implementation XHHTradHomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _reshData = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)reloadCellWithModel:(ChZMarketListModel *)model{
    self.typeImage.image = nil;
    self.nameLable.text = nil;
    self.model = model;
    if (model.sellWebLogo) {
        [self.typeImage sd_setImageWithURL:[NSURL URLWithString:model.sellWebLogo]];
    }
    if (ChZ_StringIsEmpty(model.sellShortName)) {
        self.nameLable.text = model.sellShortName;
    }
    self.sumLable.text = [NSString stringWithFormat:@"更新中..."];
    self.pricLable.text = [NSString stringWithFormat:@"更新中..."];
    self.sumPriceLable.text = [NSString stringWithFormat:@"更新中..."];
    [self.upLable setTitle:@"更新中..." forState:UIControlStateNormal];
}
-(void)reloadCellWitCoinhModel:(ChZRealCoinInfoModel *)model
{
    self.typeImage.image = nil;
    self.nameLable.text = nil;
    NSArray *coins = [APPControl sharedAPPControl].allCoins;
    for(ChZMarketListModel *lModle in coins)
    {
        if([lModle.sellShortName isEqualToString:model.sellSymbol])
        {
            if (ChZ_StringIsEmpty(lModle.sellWebLogo))
            {
                [self.typeImage sd_setImageWithURL:[NSURL URLWithString:lModle.sellWebLogo]];
                break;
            }
        }
    }
    if (ChZ_StringIsEmpty(model.sellSymbol)) {
        self.nameLable.text = model.sellSymbol;
    }
    self.sumLable.text = [NSString stringWithFormat:@"更新中..."];
    self.pricLable.text = [NSString stringWithFormat:@"更新中..."];
    self.sumPriceLable.text = [NSString stringWithFormat:@"更新中..."];
    [self.upLable setTitle:@"更新中..." forState:UIControlStateNormal];
}
-(void)setTradId:(NSString *)tradId
{
    _tradId = tradId;
    [self _loadTimer];
}


- (void)_handleData:(NSArray *)array
{
    if (array == nil || array.count == 0) {
        return;
    }
    ChZRealCoinInfoModel *model = [array firstObject];
    self.coinModel = model;
    
}
- (void)setCoinModel:(ChZRealCoinInfoModel *)coinModel
{
    self.typeImage.image = nil;
    NSArray *coins = [APPControl sharedAPPControl].allCoins;
    for(ChZMarketListModel *lModle in coins)
    {
        if([lModle.sellShortName isEqualToString:coinModel.sellSymbol])
        {
            if (ChZ_StringIsEmpty(lModle.sellWebLogo))
            {
                [self.typeImage sd_setImageWithURL:[NSURL URLWithString:lModle.sellWebLogo]];
                break;
            }
        }
    }
    if (ChZ_StringIsEmpty(coinModel.total)) {
        double total = [coinModel.total doubleValue];
        self.sumLable.text = [NSString stringWithFormat:@"量  %.2f",total];
    }
    if (ChZ_StringIsEmpty(coinModel.sellSymbol)) {
        self.nameLable.text = coinModel.sellSymbol;
    }
    if (ChZ_StringIsEmpty(coinModel.p_new))
    {
        double price_close = [coinModel.p_new doubleValue];
        double cny = [[APPControl sharedAPPControl].cny doubleValue];
        
        
        self.pricLable.text = [NSString stringWithFormat:@"%.4f",price_close];
        self.sumPriceLable.text = [NSString stringWithFormat:@"%.4f",price_close * cny];
        
        if([coinModel.chg floatValue] > 0)
        {
            [_upLable setBackgroundImage:[UIImage imageNamed:@"trad_home_botton_up"] forState:UIControlStateNormal];
            [_upLable setTitle:[NSString stringWithFormat:@"+%.2f%%",[coinModel.chg floatValue]] forState:UIControlStateNormal];
        }else
        {
            [_upLable setBackgroundImage:[UIImage imageNamed:@"trad_home_botton_down"] forState:UIControlStateNormal];
            [_upLable setTitle:[NSString stringWithFormat:@"%.2f%%",[coinModel.chg floatValue]] forState:UIControlStateNormal];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:coinModel.p_new forKey:[@"XHH" stringByAppendingString:self.nameLable.text]];
    _coinModel = coinModel;
}
- (void)_refreshData
{
    @weakify(self);
    [ChZHomeRequest requestRealCoin:self.tradId successBlock:^(id dataSource){
        @strongify(self);
        [self _handleData:dataSource];
    } errorBlock:^(int code, NSString *error){
        
    }];
}
- (void)_loadTimer
{
    if (self.timer == nil)
    {
        self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(_refreshData) userInfo:nil repeats:YES];
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
}
@end
