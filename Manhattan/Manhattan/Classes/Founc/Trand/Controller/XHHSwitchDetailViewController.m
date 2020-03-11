//
//  XHHSwitchDetailViewController.m
//  FuturePurse
//
//  Created by Apple on 2018/8/29.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHSwitchDetailViewController.h"
#import "XHHExplicitPriceView.h"
#import "XHHTradBottomBuyView.h"
#import "ZXAssemblyView.h"
#import "XHHPublicItemsView.h"
@interface XHHSwitchDetailViewController ()<AssemblyViewDelegate,ZXSocketDataReformerDelegate,XHHPublicItemsViewProtocol>
/**
 *k线实例对象
 */
@property (nonatomic,strong) ZXAssemblyView        *assenblyView;
/**
 *横竖屏方向
 */
@property (nonatomic,assign) UIInterfaceOrientation orientation;
/**
 *当前绘制的指标名
 */
@property (nonatomic,strong) NSString *currentDrawQuotaName;
/**
 *所有的指标名数组
 */
@property (nonatomic,strong) NSArray *quotaNameArr;

/**
 *所有数据模型
 */
@property (nonatomic,strong) NSMutableArray *dataArray;

/**
 *
 */
@property (nonatomic,assign) ZXTopChartType topChartType;

@property (nonatomic,strong) NSTimer  *timer;

@property (strong, nonatomic) XHHExplicitPriceView        *priceView;

@property (strong, nonatomic) UISegmentedControl          *segmentControl;

@property (nonatomic , strong) XHHPublicItemsView         *itemsView;

//时间
@property (nonatomic, assign) double  requestDate;

@property (nonatomic , strong) XHHTradBottomBuyView       *bottomBuyView;

@property (strong, nonatomic) UIScrollView                *bgScrollView;
@end

@implementation XHHSwitchDetailViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _loadTimer];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _removeTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestDate = 60;
    
    self.topChartType = ZXTopChartTypeCandle;
   
    self.currentDrawQuotaName = self.quotaNameArr[0];
    
    [self zh_setupUI];
    
    [self configureData];
    
    [self requestIsCollect];
}
-(void)zh_setupUI{
    CGFloat bottomHeight = ChZ_IsiPhoneX ? 34 : 0;
    //背景滚动视图
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    self.bgScrollView = bgScrollView;
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 80+bottomHeight, 0));
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [contentView addSubview:self.priceView];
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(contentView);
        make.height.mas_equalTo(160);
    }];
    
    [contentView addSubview:self.itemsView];
    [self.itemsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(self.priceView.mas_bottom);
        make.height.mas_equalTo(47);
    }];
    
    [contentView addSubview:self.assenblyView];
    [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.itemsView.mas_bottom);
        make.left.mas_equalTo(contentView);
        make.width.mas_equalTo(TotalWidth);
        make.height.mas_equalTo(TotalHeight);
    }];

    [self.bgScrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(bgScrollView).insets(UIEdgeInsetsZero);
        make.width.equalTo(bgScrollView);
        make.bottom.equalTo(self.assenblyView);
    }];
    [self.view addSubview:self.bottomBuyView];
    [self.bottomBuyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-bottomHeight);
        make.height.mas_equalTo(80);
    }];
    
}
-(XHHExplicitPriceView *)priceView{
    if (!_priceView) {
        _priceView = [[[NSBundle mainBundle] loadNibNamed:@"XHHExplicitPriceView" owner:nil options:nil] lastObject];
    }
    return _priceView;
}
-(XHHTradBottomBuyView *)bottomBuyView{
    if (!_bottomBuyView) {
        _bottomBuyView = [[[NSBundle mainBundle] loadNibNamed:@"XHHTradBottomBuyView" owner:nil options:nil] lastObject];
        @weakify(self);
        _bottomBuyView.collectBlock = ^{
            @strongify(self);
            [self collectTrad];
        };
    }
    return _bottomBuyView;
}

-(XHHPublicItemsView *)itemsView{
    if (!_itemsView) {
        _itemsView = [[XHHPublicItemsView alloc] init];
        [_itemsView zh_setupUIWithItems:@[@"1分",@"5分",@"15分",@"30分",@"1小时",@"1天",@"1周",@"1月",]];
        _itemsView.delegate = self;
    }
    return _itemsView;
}
-(void)itemsClickIndex:(NSInteger)index{
    
    switch (index) {
        case 0:
            self.requestDate = 60;
            break;
        case 1:
            self.requestDate = 60 * 5;
            break;
        case 2:
            self.requestDate = 60 * 15;
            break;
        case 3:
            self.requestDate = 60 * 30;
            break;
        case 4:
            self.requestDate = 60 * 60;
            break;
        case 5:
            self.requestDate = 60 * 60 * 24;
            break;
        case 6:
            self.requestDate = 60 * 60 * 24 * 7;
            break;
        case 7:
            self.requestDate = 60 * 60 * 24 * 30;
            break;
            
        default:
            break;
    }
    [self configureData];
}
-(void)setCoinModel:(ChZRealCoinInfoModel *)coinModel{
    _coinModel = coinModel;
    self.priceView.coinModel = coinModel;
}
- (void)configureData
{
    
    @weakify(self);
    [ChZHomeRequest requestKLineData:self.symblId date:self.requestDate SuccessBlock:^(id dataSource)
     {
         @strongify(self);
         dispatch_main_async_safe(^{
             [self reloadKlineWithArray:dataSource];
         });
     } errorBlock:^(int code, NSString *error)
     {
         NSLog(@"%@",error);
     }];
}
-(void)reloadKlineWithArray:(NSArray *)array{
    [self.dataArray removeAllObjects];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i<array.count
         ; i++) {
        NSArray *arr = array[i];
        if (arr && arr.count > 0)
        {
            [tempArray addObject:[NSString stringWithFormat:@"%ld,%@,%@,%@,%@,%@",[arr[0] integerValue]/1000,arr[1],arr[2],arr[3],arr[4],arr[5]]];
        }
    }
    NSArray *transformedDataArray =  [[ZXDataReformer sharedInstance] transformDataWithOriginalDataArray:tempArray currentRequestType:@"M1"];
    self.dataArray = [transformedDataArray mutableCopy];
    //====绘制k线图
    [self.assenblyView drawHistoryCandleWithDataArr:self.dataArray precision:2 stackName:@"股票名" needDrawQuota:self.currentDrawQuotaName];
    [ZXSocketDataReformer sharedInstance].delegate = self;
    
    [self _loadTimer];
    
}
#pragma mark -  计算精度
- (NSInteger)calculatePrecisionWithOriginalDataArray:(NSArray *)dataArray
{
    NSString *dataString = dataArray.lastObject;
    NSArray *strArr = [dataString componentsSeparatedByString:@","];
    //取的最高值
    NSInteger maxPrecision = [self calculatePrecisionWithPrice:strArr[3]];
    return maxPrecision;
}
- (NSInteger)calculatePrecisionWithPrice:(NSString *)price
{
    //计算精度
    NSInteger dig = 0;
    if ([price containsString:@"."])
    {
        NSArray *com = [price componentsSeparatedByString:@"."];
        dig = ((NSString *)com.lastObject).length;
    }
    return dig;
}
#pragma mark - AssemblyViewDelegate
- (void)tapActionActOnQuotaArea
{
    if (self.topChartType==ZXTopChartTypeTimeLine) {
        return;
    }
    //这里可以进行quota图的切换
    NSInteger index = [self.quotaNameArr indexOfObject:self.currentDrawQuotaName];
    if (index<self.quotaNameArr.count-1) {
        
        self.currentDrawQuotaName = self.quotaNameArr[index+1];
    }else{
        self.currentDrawQuotaName = self.quotaNameArr[0];
    }
    [self drawQuotaWithCurrentDrawQuotaName:self.currentDrawQuotaName];
}

- (void)tapActionActOnCandleArea
{
    
}
#pragma mark - 画指标
//在返回的数据里面。可以调用预置的指标接口绘制指标，也可以根据返回的数据自己计算数据，然后调用绘制接口进行绘制
- (void)drawQuotaWithCurrentDrawQuotaName:(NSString *)currentDrawQuotaName
{
    
    if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[0]])
    {
        //macd绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithMACD];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[1]])
    {
        
        //KDJ绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithKDJ];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[2]])
    {
        
        //BOLL绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithBOLL];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[3]])
    {
        
        //RSI绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithRSI];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[4]])
    {
        
        //Vol绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithVOL];
    }
//    [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:10 timestamp:10 volumn:@(100) dataArray:self.dataArray isFakeData:NO];
}
#pragma ------------实时获取K线数据-----------
- (void)creatFakeSocketData
{
    @weakify(self);
    [ChZHomeRequest requestKLineData:self.symblId date:self.requestDate SuccessBlock:^(id dataSource)
     {
         @strongify(self);
         dispatch_main_async_safe(^{
             NSArray *array = dataSource;
             [self setSoketDataWithArray:array];
         });
     } errorBlock:^(int code, NSString *error)
     {
         NSLog(@"%@",error);
     }];
//    KlineModel *model = self.dataArray[self.dataArray.count-2];
//    int32_t highestPrice = model.highestPrice*100000;
//    int32_t lowestPrice = model.lowestPrice*100000;
//    CGFloat newPrice = (arc4random_uniform(highestPrice-lowestPrice)+lowestPrice)/100000.0;
//    NSLog(@"%f",newPrice);
//    NSInteger volumn = arc4random_uniform(100);
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval timestamp = [date timeIntervalSince1970];
//    //socket数据处理
//    [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:newPrice timestamp:timestamp volumn:@(volumn) dataArray:self.dataArray isFakeData:NO];
}
-(void)setSoketDataWithArray:(NSArray *)array
{
    if(array.count)
    {
        NSArray * strArr = [array lastObject];
        if (strArr && strArr.count >= 6)
        {
            NSString *timestamp = [NSString stringWithFormat:@"%ld",[strArr[0] integerValue]/1000];
            int32_t highestPrice = [strArr[3] floatValue]*100000;
            int32_t lowestPrice = [strArr[4] floatValue]*100000;
            CGFloat newPrice = ((highestPrice-lowestPrice)+lowestPrice)/100000.0;
            [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:newPrice timestamp:[timestamp integerValue] volumn:@(100) dataArray:self.dataArray isFakeData:NO];
        }
    }
}
#pragma mark - ZXSocketDataReformerDelegate
- (void)bulidSuccessWithNewKlineModel:(KlineModel *)newKlineModel
{
    //维护控制器数据源
    if (newKlineModel.isNew) {
        
        [self.dataArray addObject:newKlineModel];
        [[ZXQuotaDataReformer sharedInstance] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
        
    }else{
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
        
        [[ZXQuotaDataReformer alloc] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
    }
    //绘制最后一个蜡烛
    [self.assenblyView drawLastKlineWithNewKlineModel:newKlineModel];
}
#pragma mark - Getters & Setters
- (ZXAssemblyView *)assenblyView
{
    if (!_assenblyView) {
        //仅仅只有k线的初始化方法
        //        _assenblyView = [[ZXAssemblyView alloc] initWithDrawJustKline:YES];
        //带指标的初始化
        _assenblyView = [[ZXAssemblyView alloc] init];
        _assenblyView.backgroundColor = bgColor;
        _assenblyView.delegate = self;
    }
    return _assenblyView;
}
- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (NSArray *)quotaNameArr
{
    if (!_quotaNameArr) {
        _quotaNameArr = @[@"MACD",@"KDJ",@"BOLL",@"RSI",@"VOL"];
    }
    return _quotaNameArr;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)requestIsCollect
{
    @weakify(self);
    [ChZHomeRequest requestIsCollectFid:[APPControl sharedAPPControl].user.fid
                                 tradId:self.symblId
                           successBlock:^(id dataSource)
    {
        @strongify(self);
        NSString *isCollect = [dataSource objectForKey:@"is_collect"];
        if ([isCollect floatValue] == 1)
        {
            self.bottomBuyView.isCollect = YES;
        }else{
            self.bottomBuyView.isCollect = NO;
        }
       
    } errorBlock:^(int code, NSString *error)
    {
        ChZ_DebugLog(@"%@--",error);
    }];
}
-(void)collectTrad{
    @weakify(self);
    [ChZHomeRequest requestCollectTradFid:[APPControl sharedAPPControl].user.fid
                                   tradId:self.symblId
                             successBlock:^(id dataSource)
    {
        @strongify(self);
        [self requestIsCollect];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"COLLECTREFRESH" object:nil];
    } errorBlock:^(int code, NSString *error) {
        ChZ_DebugLog(@"%@--",error);
    }];
}

- (void)_loadTimer
{
    if (self.timer == nil)
    {
        self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(creatFakeSocketData) userInfo:nil repeats:YES];
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
-(void)dealloc{
    
    [self _removeTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
