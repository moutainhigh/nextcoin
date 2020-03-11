//
//  XHHTradPayMessageView.m
//  FuturePurse
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHTradPayMessageView.h"
#import "XHHTradPayMessageCell.h"
#import "XHHTradPayMessageHeadView.h"
#import "XHHTradQRCodeView.h"
static NSString *cellIndienfiter = @"XHHTradPayMessageCell";
@interface XHHTradPayMessageView ()<UITableViewDelegate,UITableViewDataSource>



@property (strong, nonatomic) NSMutableArray      *dataArray;

@property (strong, nonatomic) XHHTradPayMessageHeadView  *headView;

@property (strong, nonatomic) XHHTradQRCodeView          *codeView;

@end

@implementation XHHTradPayMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//-(instancetype)init{
//    self = [super init];
//    if (self) {
//        [self zh_setupUI];
//    }
//    return self;
//}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self zh_setupUI];
}
-(void)zh_setupUI{
    [self addSubview:self.headView ];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(197);
    }];
    
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.headView.mas_bottom);
        make.height.mas_equalTo(105 * self.dataArray.count);
    }];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.backgroundColor = bgColor;
        [_tableView setSeparatorColor:LineCorlor];
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView registerNib:[UINib nibWithNibName:@"XHHTradPayMessageCell" bundle:nil] forCellReuseIdentifier:cellIndienfiter];
    }
    return _tableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(void)setOrderModel:(XHHC2CMyOrderModel *)orderModel
{
    _orderModel = orderModel;
    [self.dataArray removeAllObjects];
    if (orderModel.bank == nil || !ChZ_StringIsEmpty(orderModel.bank.fid))
    {
        self.headView.hidden = YES;
        [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }else
    {
        self.headView.model = orderModel.bank;
    }
    if (orderModel.alipay != nil && ChZ_StringIsEmpty(orderModel.alipay.fid)) {
        [self.dataArray addObject:@"alipay"];
    }
    if (orderModel.weixin != nil && ChZ_StringIsEmpty(orderModel.weixin.fid)) {
        [self.dataArray addObject:@"weixin"];
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make){
        make.height.mas_equalTo(106 * self.dataArray.count);
     }];
}
-(XHHTradPayMessageHeadView *)headView{
    if (!_headView) {
        _headView = [[[NSBundle mainBundle] loadNibNamed:@"XHHTradPayMessageHeadView" owner:nil options:nil] lastObject];
        [_headView setFrame:CGRectMake(0, 0, ChZ_WIDTH, 200)];
    }
    return _headView;
}
-(XHHTradQRCodeView *)codeView{
    if (!_codeView) {
        _codeView = [[[NSBundle mainBundle] loadNibNamed:@"XHHTradQRCodeView" owner:nil options:nil] lastObject];
    }
    return _codeView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XHHTradPayMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndienfiter];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArray.count > indexPath.row) {
        NSString *type = self.dataArray[indexPath.row];
        if (ChZ_StringIsEmpty(type)) {
            if ([type isEqualToString:@"alipay"])
            {
                cell.isAlipay = YES;
            }
            if ([type isEqualToString:@"weixin"])
            {
                cell.isAlipay = NO;
            }
        }
    }
    cell.model = self.orderModel;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArray.count > indexPath.row) {
        NSString *type = self.dataArray[indexPath.row];
        if (ChZ_StringIsEmpty(type)) {
            if ([type isEqualToString:@"alipay"])
            {
                self.codeView.alertLabel.text = @"用支付宝扫二维码付款";
                if (ChZ_StringIsEmpty(self.orderModel.alipay.qrcode))
                {
                    if ([self.orderModel.alipay.qrcode hasPrefix:@"http"])
                    {
                        [self.codeView.qrImageView sd_setImageWithURL:[NSURL URLWithString:self.orderModel.alipay.qrcode]];
                    }else
                    {
                        NSString *url = RequestURL(self.orderModel.alipay.qrcode);
                        [self.codeView.qrImageView sd_setImageWithURL:[NSURL URLWithString:url]];
                    }
                }
            }
            if ([type isEqualToString:@"weixin"])
            {
                self.codeView.alertLabel.text = @"用微信扫二维码付款";
                if (ChZ_StringIsEmpty(self.orderModel.weixin.qrcode))
                {
                    if ([self.orderModel.weixin.qrcode hasPrefix:@"http"])
                    {
                        [self.codeView.qrImageView sd_setImageWithURL:[NSURL URLWithString:self.orderModel.weixin.qrcode]];
                    }else
                    {
                        NSString *url = RequestURL(self.orderModel.weixin.qrcode);
                        [self.codeView.qrImageView sd_setImageWithURL:[NSURL URLWithString:url]];
                    }
                }
            }
        }
    }
    
    [self.codeView showInView:self.viewController.view.window];
}
@end
