//
//  ChZHomeRequest.m
//  FuturePurse
//
//  Created by Howe on 2018/8/8.
//  Copyright © 2018年 jbtm. All rights reserved.
//

#import "ChZHomeRequest.h"
#import "ChZMarketAreaModel.h"
#import "ChZMarketListModel.h"
#import "ChZRealCoinInfoModel.h"
#import "ChZMarketTxsOrderItemModel.h"
#import "HCMarketAreaModel.h"
#import "XHHNotesItemModel.h"
#import "XHHNotesListModel.h"
#import "XHHNotesDetailModel.h"

#import "XHHC2CCnyListModel.h"
#import "XHHC2CBuyDataModel.h"
#import "XHHC2CMyReleaseModel.h"
#import "XHHC2CMyOrderModel.h"
#import "XHHC2CKineModel.h"
@implementation ChZHomeRequest
+ (void)requestKLineData:(NSString *)Fid
                    date:(double )date
            SuccessBlock:(ChZ_SuccessBlock)successBlock
              errorBlock:(ErrorCodeBlock)errorBlock
{
    
    NSString *url = RequestURL(@"/kline/fullperiod.html");
    NSString *urlStr = [NSString stringWithFormat:@"%@?symbol=%@&step=%.f", url, Fid,date];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                  {
                                      if (error) {
                                          if (errorBlock)    errorBlock(0,@"请求失败");
                                          return ;
                                      }
                                      
                                      NSError *jsonError;
                                      NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                                      if (jsonError) {
                                          if (errorBlock)    errorBlock(0,@"请求失败");
                                          return ;
                                      }
                                      if (array)
                                          if (successBlock) {
                                              successBlock(array);
                                          }
                                  }];
    [task resume];
}

+ (void)requestAreaSuccessBlock:(ChZ_SuccessBlock)successBlock
                     errorBlock:(ErrorCodeBlock)errorBlock
{
    NSString *urlStr = RequestURL(kURL_marketArea);
    [self GetWithURL:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"data"];
        if (data)
        {
            NSArray *objArray = [HCMarketAreaModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock)
            {
                successBlock(objArray);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}

+ (void)requestRealCoin:(NSString *)idString
           successBlock:(ChZ_SuccessBlock)successBlock
             errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_realCoin)];
    if (ChZ_StringIsEmpty(idString)) {
        [url appendString:[NSString stringWithFormat:@"?symbol=%@",idString]];
    }
    [self GetWithURL:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        
        
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"data"];
        if (data)
        {
            NSArray *objArray = [ChZRealCoinInfoModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock)
            {
                successBlock(objArray);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
    
}


+ (void)requestAreaList:(NSString *)fid
           successBlock:(ChZ_SuccessBlock)successBlock
             errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_marketList)];
    
    if (ChZ_StringIsEmpty(fid)) {
        [url appendString:[NSString stringWithFormat:@"?symbol=%@",fid]];
    }
    
    [self GetWithURL:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"data"];
        if (data)
        {
            NSArray *objArray = [ChZMarketListModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock)
            {
                successBlock(objArray);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}

+ (void)requestCancelOrder:(NSString *)fid
              successBlock:(ChZ_SuccessBlock)successBlock
                errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(fid))[parameters setObject:fid forKey:@"id"];
    [self PostAuthWithURL:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *responseDic = responseObject;
         if ([responseDic isKindOfClass:[NSNull class]])
         {
             if (errorBlock) errorBlock(0,@"请求失败"); return;
         }
         int code = [[responseDic objectForKey:@"code"]intValue];
         NSString *msg = [responseDic objectForKey:@"msg"];
         if (code != kv_JavaRequestSuccess)
         {
             if (ChZ_StringIsEmpty(msg))
             {
                 if (errorBlock) errorBlock(code,msg); return;
             }
             if (errorBlock) errorBlock(code,@"请求失败"); return;
         }
         if (successBlock)successBlock(nil);
         return;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     }];
}

+ (void)requestCreateOrder:(NSString *)symbolId
                    number:(float )number
                     price:(float )price
                      type:(NSString *)type
                  tradePwd:(NSString *)tradePwd
              successBlock:(ChZ_SuccessBlock)successBlock
                errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_place)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(symbolId))[parameters setObject:symbolId forKey:@"symbol"];
    [parameters setObject:[NSString stringWithFormat:@"%f",number] forKey:@"tradeAmount"];
    [parameters setObject:[NSString stringWithFormat:@"%f",price] forKey:@"tradePrice"];
    if (ChZ_StringIsEmpty(tradePwd))[parameters setObject:tradePwd forKey:@"tradePwd"];
    if (ChZ_StringIsEmpty(type))[parameters setObject:type forKey:@"type"];
    [self PostAuthWithURL:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *responseDic = responseObject;
         if ([responseDic isKindOfClass:[NSNull class]])
         {
             if (errorBlock) errorBlock(0,@"请求失败"); return;
         }
         int code = [[responseDic objectForKey:@"code"]intValue];
         NSString *msg = [responseDic objectForKey:@"msg"];
         if (code != kv_JavaRequestSuccess)
         {
             if (ChZ_StringIsEmpty(msg))
             {
                 if (errorBlock) errorBlock(code,msg); return;
             }
             if (errorBlock) errorBlock(code,@"请求失败"); return;
         }
         if (successBlock)successBlock(nil);
         return;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     }];
}

#pragma mark - 获取订单列表
+ (void)requestTxsOrderListWithSymbol:(NSString *)symbol
                                 type:(NSString *)type
                         successBlock:(ChZ_SuccessBlock)successBlock
                           errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_orderRecords)];
    NSString *token = [APPControl sharedAPPControl].token;
    if(!ChZ_StringIsEmpty(token))
    {
        ChZ_MBError(@"登录过期，请从新登录");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[APPControl sharedAPPControl] toLogin];
        });
        return;
    }
    if (ChZ_StringIsEmpty(token)) {
        [url appendString:[NSString stringWithFormat:@"?token=%@",token]];
    }
    if (ChZ_StringIsEmpty(symbol)) {
        [url appendString:[NSString stringWithFormat:@"&symbol=%@",symbol]];
    }
    if (ChZ_StringIsEmpty(type)) {
        [url appendString:[NSString stringWithFormat:@"&type=%@", type]];
    }
    [self GetWithURL:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"data"];
        if (data)
        {

            NSArray *entrutsCurArray = data[@"entrutsCur"];
            NSArray *entrutsHisArray = data[@"entrutsHis"];
            NSMutableArray *tempItemArray = [NSMutableArray array];
            if (entrutsCurArray != nil && entrutsCurArray.count !=0 )
            {
                [tempItemArray addObjectsFromArray:entrutsCurArray];
            }

            if (entrutsHisArray != nil && entrutsHisArray.count !=0 )
            {
                [tempItemArray addObjectsFromArray:entrutsHisArray];
            }

            if (tempItemArray.count == 0) if (successBlock)successBlock(nil);

            NSArray *objArray = [ChZMarketTxsOrderItemModel mj_objectArrayWithKeyValuesArray:tempItemArray];
            if (successBlock)successBlock(objArray);
        } else
        {
            if (successBlock)successBlock(nil);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}


+ (void)requestDish:(NSString *)fid
       successBlock:(ChZ_SuccessBlock)successBlock
         errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_dish)];
    
    if (ChZ_StringIsEmpty(fid)) {
        [url appendString:[NSString stringWithFormat:@"?symbol=%@",fid]];
    }
    [self GetWithURL:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"data"];
        if (data)
        {
            
            if (successBlock)
            {
                successBlock(data);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}

+ (void)requestUserAssets:(NSString *)fid
             successBlock:(ChZ_SuccessBlock)successBlock
               errorBlock:(ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_userAssets)];
    NSString *token = [APPControl sharedAPPControl].token;
    if(!ChZ_StringIsEmpty(token))
    {
        ChZ_MBError(@"登录失效，请重新登录");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[APPControl sharedAPPControl] toLogin];
        });
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(fid))[parameters setObject:fid forKey:@"tradeid"];
    if (ChZ_StringIsEmpty(token))[parameters setObject:token forKey:@"token"];
    [self PostWithURL:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *responseDic = responseObject;
         if ([responseDic isKindOfClass:[NSNull class]])
         {
             if (errorBlock) errorBlock(0,@"请求失败"); return;
         }
         int code = [[responseDic objectForKey:@"code"]intValue];
         NSString *msg = [responseDic objectForKey:@"msg"];
         if (code != kv_JavaRequestSuccess)
         {
             if (ChZ_StringIsEmpty(msg))
             {
                 if (errorBlock) errorBlock(code,msg); return;
             }
             if (errorBlock) errorBlock(code,@"请求失败"); return;
         }
         NSDictionary *data = [responseDic objectForKey:@"data"];
         if (data)
         {
             if (successBlock)
             {
                 successBlock(data);
                 return;
             }
         }
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     }];
}
+ (void)requestCNYSuccessBlock:(ChZ_SuccessBlock)successBlock
                    errorBlock:(ErrorCodeBlock)errorBlock
{
    NSString *urlStr = RequestURL(kURL_CNYURL);
    [self GetWithURL:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_JavaRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"data"];
        if (data)
        {
            NSString *cny = [data objectForKey:@"CNY"];
            if (successBlock) {
                successBlock(cny);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}

+(void)requestNotItemsSuccessBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSString *urlStr = RequestURL(kURL_TradCenter_notes);
    [self GetWithURL:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            NSArray *objArray = [XHHNotesItemModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock) {
                successBlock(objArray);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)rerquestNotesListPage:(NSString *)page catid:(NSString *)catid successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page) [param setObject:page forKey:@"page"];
    if (catid) [param setObject:catid forKey:@"catid"];
    
    NSString *urlStr = RequestURL(kURL_TradCenter_notesList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            NSArray *objArray = [XHHNotesListModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock) {
                successBlock(objArray);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestNotesDetailId:(NSString *)notesId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (notesId) [param setObject:notesId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_TradCenter_notesDetail);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            XHHNotesDetailModel *model = [XHHNotesDetailModel mj_objectWithKeyValues:data];
            if (successBlock) {
                successBlock(model);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CcnyListSuccessBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString *urlStr = RequestURL(kURL_trad_c2cCnyList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            NSArray *objArray = [XHHC2CCnyListModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock) {
                successBlock(objArray);
                return;
            }
        }else{
            if (successBlock) {
                successBlock(nil);
                return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CBuyListCnyId:(NSString *)cnyId page:(NSInteger)page successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page) [param setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (cnyId) [param setObject:cnyId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cByList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            XHHC2CBuyDataModel *model = [XHHC2CBuyDataModel mj_objectWithKeyValues:data];
            if (successBlock) {
                successBlock(model);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSellListCnyId:(NSString *)cnyId page:(NSInteger)page successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page) [param setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (cnyId) [param setObject:cnyId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cSellList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            XHHC2CBuyDataModel *model = [XHHC2CBuyDataModel mj_objectWithKeyValues:data];
            if (successBlock) {
                successBlock(model);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CMyReleaseUid:(NSString *)uid page:(NSInteger)page successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page) [param setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (uid) [param setObject:uid forKey:@"uid"];
    NSString *urlStr = RequestURL(kURL_trad_c2cMyReleaseList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *data = responseDic[@"return"][@"data"];
        if (data)
        {
            NSArray *objArray = [XHHC2CMyReleaseModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock) {
                successBlock(objArray);
            }
        } else {
            errorBlock(0,@"请求失败");
            ChZ_MBError(@"没有数据"); return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSendBuyUid:(NSString *)uid passWord:(NSString *)passWord country:(NSString *)country num:(NSString *)num price:(NSString *)price cnyId:(NSString *)cnyId minValue:(NSString *)mineValue maxValue:(NSString *)maxValue payType:(NSString *)payType symbolName:(NSString *)symbolName successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if (uid) [param setObject:uid forKey:@"uid"];
    if (passWord) [param setObject:passWord forKey:@"data[deal_psw]"];
    if (country) [param setObject:country forKey:@"data[country]"];
    if (num) [param setObject:num forKey:@"data[order_volume_buy]"];
    if (price) [param setObject:price forKey:@"data[order_price_buy]"];
    if (cnyId) [param setObject:cnyId forKey:@"data[symbol_buy]"];
    if (mineValue) [param setObject:mineValue forKey:@"data[min_value]"];
    if (maxValue) [param setObject:maxValue forKey:@"data[max_value]"];
    if (payType) [param setObject:payType forKey:@"data[pay_type]"];
    if (symbolName) [param setObject:symbolName forKey:@"data[symbolName]"];
    NSString *urlStr = RequestURL(kURL_trad_c2cMyReleaseBuy);
    [self PostWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            if (successBlock) {
                successBlock(nil);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSendSellUid:(NSString *)uid passWord:(NSString *)passWord country:(NSString *)country num:(NSString *)num price:(NSString *)price cnyId:(NSString *)cnyId minValue:(NSString *)mineValue maxValue:(NSString *)maxValue payType:(NSString *)payType symbolName:(NSString *)symbolName successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (passWord) [param setObject:passWord forKey:@"data[deal_psw]"];
    if (country) [param setObject:country forKey:@"data[country]"];
    if (num) [param setObject:num forKey:@"data[order_volume_sell]"];
    if (price) [param setObject:price forKey:@"data[order_price_sell]"];
    if (cnyId) [param setObject:cnyId forKey:@"data[symbol_sell]"];
    if (mineValue) [param setObject:mineValue forKey:@"data[min_value]"];
    if (maxValue) [param setObject:maxValue forKey:@"data[max_value]"];
    if (payType) [param setObject:payType forKey:@"data[pay_type]"];
    if (symbolName) [param setObject:symbolName forKey:@"data[symbolName]"];

    NSString *urlStr = RequestURL(kURL_trad_c2cMyReleaseSell);
    [self PostWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            if (successBlock) {
                successBlock(nil);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestCnyHaveNumUid:(NSString *)uid cnyId:(NSString *)cnyId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (cnyId) [param setObject:cnyId forKey:@"symbol"];
    NSString *urlStr = RequestURL(kURL_trad_c2cMyCnyNumber);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            NSString *moneyString = [responseDic objectForKey:@"return"];
            if (successBlock)
            {
                successBlock(moneyString);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestReleaseDownLineUid:(NSString *)uid releaseId:(NSString *)releaseId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (releaseId) [param setObject:releaseId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cReleaseDownLine);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            if (successBlock)
            {
                successBlock(nil);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CBuyOtherCnyUid:(NSString *)uid volume:(NSString *)volume price:(NSString *)price trade_id:(NSString *)trade_id dealpsw:(NSString *)deal_psw successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (volume) [param setObject:volume forKey:@"volume"];
    if (price) [param setObject:price forKey:@"price"];
    if (trade_id) [param setObject:trade_id forKey:@"trade_id"];
    if (deal_psw) [param setObject:deal_psw forKey:@"deal_psw"];
    NSString *urlStr = RequestURL(kURL_trad_c2cBuyOherCny);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            if (successBlock)
            {
                successBlock(nil);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSellOtherCnyUid:(NSString *)uid volume:(NSString *)volume price:(NSString *)price trade_id:(NSString *)trade_id dealpsw:(NSString *)deal_psw successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (volume) [param setObject:volume forKey:@"volume"];
    if (price) [param setObject:price forKey:@"price"];
    if (trade_id) [param setObject:trade_id forKey:@"trade_id"];
    if (deal_psw) [param setObject:deal_psw forKey:@"deal_psw"];
    NSString *urlStr = RequestURL(kURL_trad_c2cSellOherCny);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }else{
            if (successBlock)
            {
                successBlock(nil);return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CMyOrdersUid:(NSString *)uid page:(NSInteger)page type:(C2CTradType)type successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (page) [param setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (type) [param setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
    NSString *urlStr = RequestURL(kURL_trad_c2cMyOrderList);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSArray *dada;
        if (type == 1 ) {
            dada = responseDic[@"return"][@"mr"];
        }else{
            dada = responseDic[@"return"][@"mc"];
        }
        if (dada) {
            NSArray *emptyArray = [XHHC2CMyOrderModel mj_objectArrayWithKeyValuesArray:dada];
            if (successBlock)
            {
                successBlock(emptyArray);return;
            }
        }else{
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CCanelOrderUid:(NSString *)uid orderId:(NSString *)orderId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (orderId) [param setObject:orderId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cCannelOrder);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSignHadGetMoneyUid:(NSString *)uid orderId:(NSString *)orderId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (orderId) [param setObject:orderId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cSigeHadGetMoney);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CSignHadPayMoneyUid:(NSString *)uid orderId:(NSString *)orderId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"uid"];
    if (orderId) [param setObject:orderId forKey:@"id"];
    NSString *urlStr = RequestURL(kURL_trad_c2cSigeHadPayMoney);
    [self GetWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}

+ (void)requestC2CReleaseBuy:(NSString *)orderId
                        page:(int)page
                successBlock:(ChZ_SuccessBlock)successBlock
                  errorBlock:(ChZ_ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_trad_c2creleaseBuy)];
    NSString *myuid = [APPControl sharedAPPControl].user.fid;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(myuid))[parameters setObject:myuid forKey:@"uid"];
    if (ChZ_StringIsEmpty(orderId))[parameters setObject:orderId forKey:@"id"];
    [parameters setObject:@(page) forKey:@"page"];
    [self PostWithURL:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *responseDic = responseObject;
         if ([responseDic isKindOfClass:[NSNull class]])
         {
             if (errorBlock) errorBlock(0,@"请求失败"); return;
         }
         int code = [[responseDic objectForKey:@"code"]intValue];
         NSString *msg = [responseDic objectForKey:@"msg"];
         if (code != kv_PHPRequestSuccess)
         {
             if (ChZ_StringIsEmpty(msg))
             {
                 if (errorBlock) errorBlock(code,msg); return;
             }
             if (errorBlock) errorBlock(code,@"请求失败"); return;
         }
         NSDictionary *data = responseDic[@"return"];
         if (data == nil || data.count == 0)
         {
             if (successBlock)successBlock(nil);return;
         }
         NSDictionary *trade  = [data objectForKey:@"trade"];
         NSArray *tempArray = [data objectForKey:@"mr"];
         XHHC2CMyReleaseModel *model = [XHHC2CMyReleaseModel mj_objectWithKeyValues:trade];
         NSArray *objArray = [XHHC2CMyOrderModel mj_objectArrayWithKeyValuesArray:tempArray];
         if (successBlock)successBlock(@{@"trad":model,@"list":objArray});return;
         return;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     }];
}


+ (void)requestC2CReleaseSell:(NSString *)orderId
                         page:(int)page
                 successBlock:(ChZ_SuccessBlock)successBlock
                   errorBlock:(ChZ_ErrorCodeBlock)errorBlock
{
    NSMutableString *url = [NSMutableString string];
    [url appendString:RequestURL(kURL_trad_c2creleaseSell)];
    NSString *myuid = [APPControl sharedAPPControl].user.fid;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(myuid))[parameters setObject:myuid forKey:@"uid"];
    if (ChZ_StringIsEmpty(orderId))[parameters setObject:orderId forKey:@"id"];
    [parameters setObject:@(page) forKey:@"page"];
    [self PostWithURL:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *responseDic = responseObject;
         if ([responseDic isKindOfClass:[NSNull class]])
         {
             if (errorBlock) errorBlock(0,@"请求失败"); return;
         }
         int code = [[responseDic objectForKey:@"code"]intValue];
         NSString *msg = [responseDic objectForKey:@"msg"];
         if (code != kv_PHPRequestSuccess)
         {
             if (ChZ_StringIsEmpty(msg))
             {
                 if (errorBlock) errorBlock(code,msg); return;
             }
             if (errorBlock) errorBlock(code,@"请求失败"); return;
         }
         NSDictionary *data = responseDic[@"return"];
         if (data == nil || data.count == 0)
         {
             if (successBlock)successBlock(nil);return;
         }
         NSDictionary *trade  = [data objectForKey:@"trade"];
         NSArray *tempArray = [data objectForKey:@"mc"];
         XHHC2CMyReleaseModel *model = [XHHC2CMyReleaseModel mj_objectWithKeyValues:trade];
         NSArray *objArray = [XHHC2CMyOrderModel mj_objectArrayWithKeyValuesArray:tempArray];
         if (successBlock)successBlock(@{@"trad":model,@"list":objArray});return;
         return;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (errorBlock) errorBlock(0,@"请求失败"); return;
     }];
}
+(void)requestTradCollectListUid:(NSString *)uid successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (uid) [param setObject:uid forKey:@"fid"];
    NSString *urlStr = RequestURL(kURL_trad_collectlist);
    
    [self GetPHPWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            NSArray *objArray = [ChZRealCoinInfoModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock) {
                successBlock(objArray);
            }
        } else {
            if (successBlock) {
                successBlock(@[]);
            }
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestIsCollectFid:(NSString *)fid tradId:(NSString *)tradId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (tradId) [param setObject:tradId forKey:@"treadId"];
    if (fid) [param setObject:fid forKey:@"fid"];
    NSString *urlStr = RequestURL(kURL_trad_isCollected);
    [self GetPHPWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            if (successBlock) {
                successBlock(data);
            }
        } else {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestCollectTradFid:(NSString *)fid tradId:(NSString *)tradId successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ErrorCodeBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (tradId) [param setObject:tradId forKey:@"treadId"];
    if (fid) [param setObject:fid forKey:@"fid"];
    NSString *urlStr = RequestURL(kURL_trad_collect);
    [self GetPHPWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(0,@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(code,msg); return;
            }
            if (errorBlock) errorBlock(code,@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            if (successBlock) {
                successBlock(data);
            }
            return;
        } else {
            if (successBlock) {
                successBlock(nil);
            }; return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(0,@"请求失败"); return;
    }];
}
+(void)requestC2CcomplaintWithOrderId:(NSString *)orderId
                              imgdata:(NSString *)imgdata
                               remark:(NSString *)remark
                         successBlock:(ChZ_SuccessBlock)successBlock
                           errorBlock:(ChZ_ErrorBlock)errorBlock
{
    NSString *uid = [APPControl sharedAPPControl].user.fid;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(uid)) [param setObject:uid forKey:@"uid"];
    if (ChZ_StringIsEmpty(orderId)) [param setObject:orderId forKey:@"orderId"];
    if (ChZ_StringIsEmpty(imgdata)) [param setObject:imgdata forKey:@"imgUrl"];
    if (ChZ_StringIsEmpty(remark)) [param setObject:remark forKey:@"description"];
    NSString *urlStr = RequestURL(kURL_c2cComplaint);
    [self PostWithURL:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(msg); return;
            }
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(@"请求失败"); return;
    }];
}
+(void)requestC2CKineLineCoinNmae:(NSString *)coinNmae time:(NSString *)time successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ChZ_ErrorBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(coinNmae)) [param setObject:coinNmae forKey:@"symbolName"];
    if (ChZ_StringIsEmpty(time)) [param setObject:time forKey:@"time"];
    NSString *url = RequestURL(kURL_trad_c2cCoinKinedata);
    [self PosPHPtWithURL:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(msg); return;
            }
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        NSArray *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            NSArray *emptyArray = [XHHC2CKineModel mj_objectArrayWithKeyValuesArray:data];
            if (successBlock)
            {
                successBlock(emptyArray);
                return;
            }
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) errorBlock(@"请求失败"); return;
    }];
}
+(void)requestCoinReleasePriceCoinName:(NSString *)coinName successBlock:(ChZ_SuccessBlock)successBlock errorBlock:(ChZ_ErrorBlock)errorBlock{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (ChZ_StringIsEmpty(coinName)) [param setObject:coinName forKey:@"symbolName"];
    NSString *url = RequestURL(kURL_trad_c2cReleasePrice);
    [self PosPHPtWithURL:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = responseObject;
        if ([responseDic isKindOfClass:[NSNull class]])
        {
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        int code = [[responseDic objectForKey:@"code"]intValue];
        NSString *msg = [responseDic objectForKey:@"msg"];
        if (code != kv_PHPRequestSuccess)
        {
            if (ChZ_StringIsEmpty(msg))
            {
                if (errorBlock) errorBlock(msg); return;
            }
            if (errorBlock) errorBlock(@"请求失败"); return;
        }
        NSDictionary *data = [responseDic objectForKey:@"return"];
        if (data)
        {
            if (successBlock)
            {
                successBlock(data);
                return;
            }
        }
        if (successBlock)
        {
            successBlock(nil);return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
@end
