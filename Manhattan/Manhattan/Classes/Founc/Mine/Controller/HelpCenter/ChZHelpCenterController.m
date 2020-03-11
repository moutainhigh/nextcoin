
//
//  ChZHelpCenterController.m
//  FuturePurse
//
//  Created by Howe on 2018/8/3.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "ChZHelpCenterController.h"
//#import "XHHTranCustmerController.h"
#import "XTTMineRequest.h"
#import "XTTMineModel.h"

#import "ChZRateStandardController.h"
#import "ChZCoinInfoController.h"
#import "ChZValuationTypeController.h"
#import "ChZCommonProblemController.h"
#import "ChZCoinInfoCell.h"
@interface ChZHelpCenterController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray  *dataSource;

@end

@implementation ChZHelpCenterController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title =@"帮助中心";
    [self config];
    [self requestMineHelp];
}

- (IBAction)backAction:(id)sender
{
    [self pop];
}
-(void)config
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ChZCoinInfoCell" bundle:nil] forCellReuseIdentifier:@"MineHelpListCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [UIView new];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XTTMineAppHelpListModel *model = self.dataSource[indexPath.row];
    ChZCoinInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineHelpListCell"];
    cell.nameLabel.text = model.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XTTMineAppHelpListModel *model = self.dataSource[indexPath.row];

    switch (indexPath.row) {
        case 0:{
            ChZRateStandardController *vc = [ChZRateStandardController initWithStoryboard:@"HelpCenter"];
            vc.catid = model.fid;
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        case 1:{
            ChZCoinInfoController *vc = [ChZCoinInfoController initWithStoryboard:@"HelpCenter"];
            vc.catid = model.fid;
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        case 2:{
            ChZValuationTypeController *vc = [ChZValuationTypeController initWithStoryboard:@"HelpCenter"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        case 3:{
            ChZCommonProblemController *vc = [ChZCommonProblemController initWithStoryboard:@"HelpCenter"];
            vc.catid = model.fid;
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestMineHelp{
    ChZ_MBMsg(nil)
    [XTTMineRequest requestMineHelpList:^(id dataSource) {
        ChZ_MBDismss
        self.dataSource = dataSource;
        [self.tableView reloadData];
    } errorBlock:^(NSString *error) {
        ChZ_MBDismss
        ChZ_MBError(error);
    }];
}
@end
