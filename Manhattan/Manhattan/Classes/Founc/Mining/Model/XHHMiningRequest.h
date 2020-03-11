//
//  XHHCityRequest.h
//  Manhattan
//
//  Created by Apple on 2018/9/13.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "ChZBaseHttpRequest.h"

@interface XHHMiningRequest : ChZBaseHttpRequest

/**
 挖矿首页

 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestCityHomeSuccess:(ChZ_SuccessBlock)successBlock
                    error:(ErrorCodeBlock)errorBlock;

/**
 首页banner

 @param successBlock 回调
 @param errorBlock 失败回调
 */
+(void)requestHomeBannerSuccess:(ChZ_SuccessBlock)successBlock
                          error:(ErrorCodeBlock)errorBlock;

/**
 挖矿记录

 @param page 页数
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestMinListPage:(NSInteger)page success:(ChZ_SuccessBlock)successBlock
                    error:(ErrorCodeBlock)errorBlock;

/**
 挖矿

 @param getId 矿ID
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestMiningInComeGetId:(NSString *)getId
                        success:(ChZ_SuccessBlock)successBlock
                          error:(ErrorCodeBlock)errorBlock;

/**
 开矿区

 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestMiningAreaListSuccess:(ChZ_SuccessBlock)successBlock
                              error:(ErrorCodeBlock)errorBlock;


/**
 一键复投

 @param miningType 矿区
 @param status 1:复投；2:不复投
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestMiningOneKeyInputType:(NSString *)miningType
                             status:(XHHMiningOnekeyType)status
                            success:(ChZ_SuccessBlock)successBlock
                              error:(ErrorCodeBlock)errorBlock;

/**
 开矿区投入

 @param miningType 矿区
 @param num 投入数量
 @param coin_id 投入数量
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestMiningInputMiningType:(NSString *)miningType
                                num:(NSString *)num
                            coin_id:(NSString *)coin_id
                            success:(ChZ_SuccessBlock)successBlock
                              error:(ErrorCodeBlock)errorBlock;

/**
 算力任务

 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestForseTaskSuccess:(ChZ_SuccessBlock)successBlock
                         error:(ErrorCodeBlock)errorBlock;

/**
 算力记录

 @param page 页数
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+(void)requestForseWorkListPage:(NSInteger)page
                        success:(ChZ_SuccessBlock)successBlock
                          error:(ErrorCodeBlock)errorBlock;

@end
