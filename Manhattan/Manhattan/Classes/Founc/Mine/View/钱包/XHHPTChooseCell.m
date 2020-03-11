//
//  XHHPTChooseCell.m
//  FuturePurse
//
//  Created by Apple on 2018/7/23.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "XHHPTChooseCell.h"

@interface XHHPTChooseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *ptImageView;

@property (weak, nonatomic) IBOutlet UILabel *tyNameLable;

@property (weak, nonatomic) IBOutlet UIImageView *isSelectedImageView;

@end

@implementation XHHPTChooseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setSelectedCell:(BOOL)isSelected{
    self.isSelectedImageView.hidden = !isSelected;
}
- (void)setCnyModel:(XHHC2CCnyListModel *)cnyModel{
    _cnyModel = cnyModel;
    self.tyNameLable.text = cnyModel.short_name;
}

-(void)setCellDic:(NSDictionary *)cellDic{
    _cellDic = cellDic;
    self.tyNameLable.text = [cellDic objectForKey:@"name"];
}
@end
