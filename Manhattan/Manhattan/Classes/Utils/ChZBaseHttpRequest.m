//
//  ChZBaseHttpRequest.m
//  zubu
//
//  Created by ChZ on 2016/10/20.
//  Copyright © 2016年 ChZ. All rights reserved.
//

#import "ChZBaseHttpRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static AFHTTPSessionManager *manager;
//请求token错误此时
int errorCount;
//是否正在刷新token
BOOL isRefreshInterfaceTokening;

@implementation ChZBaseHttpRequest

+ (AFHTTPSessionManager *)sharedHTTPSessionManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        isRefreshInterfaceTokening = NO;
        errorCount = 0;
        manager.requestSerializer.timeoutInterval = 60;
    });
    return manager;
}


+ (void)upLoadImageWithURL:(NSString *)url
                parameters:(NSDictionary *) parameters
 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                  progress:(nullable void (^) (NSProgress *_Nonnull uploadProgress) )progress
                   success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success
                   failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         if (block)
         {
             block(formData);
         }
     } progress:^(NSProgress * _Nonnull uploadProgress)
     {
         if (progress)
         {
             progress(uploadProgress);
         }
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ChZ_ErrorLog(@"上传图片错误！%@",error);
         if (failure)
         {
             failure(task,error);
         }
     }];
}
+ (void)PostAuthWithURL:(NSString *)url
             parameters:(NSDictionary * )parameters
               progress:(void (^)(NSProgress * uploadProgress) )progress
                success:(void (^)(NSURLSessionDataTask *  task, id   responseObject))success
                failure:(void (^)(NSURLSessionDataTask *  task, NSError *  error))failure
{
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    NSString *token = [APPControl  sharedAPPControl].token;
    NSString *key =  [APPControl sharedAPPControl].secretKey;
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    
    if (ChZ_StringIsEmpty(token)) [dic setObject:token forKey:@"AccessKeyId"];
    [dic setObject:@"2" forKey:@"SignatureVersion"];
    [dic setObject:@"HmacSHA256" forKey:@"SignatureMethod"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSTimeInterval timeInterval = [datenow timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", timeInterval];//转为字符型
    [dic setObject:timeString forKey:@"Timestamp"];
    
    NSString *signature = [self createAuth:@"POST" parameters:dic urlString:url key:key];
    
    if (ChZ_StringIsEmpty(token)) [dic setObject:token forKey:@"token"];
    if (ChZ_StringIsEmpty(signature)) [dic setObject:signature forKey:@"Signature"];
    
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress)
     {
         if (progress)
         {
             progress(uploadProgress);
         }
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ChZ_ErrorLog(@"%@",error);
         if (failure)
         {
             failure(task,error);
         }
         
     }];
}

+ (void)Post2WithURL:(NSString *)url parameters:(NSDictionary * )parameters progress:(void (^) (NSProgress *_Nonnull uploadProgress) )progress success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    NSDictionary *paramater = [self createAuthParameters:parameters];
    NSMutableString *parameterstring = [NSMutableString string];
    [paramater enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 服务器接收参数的 key 值.
        NSString *paramaterKey = key;
        // 参数内容
        NSString *paramaterValue = obj;
        // appendFormat :可变字符串直接拼接的方法!
        [parameterstring appendFormat:@"%@=%@&",paramaterKey,paramaterValue];
    }];
    [parameterstring replaceCharactersInRange:NSMakeRange(parameterstring.length -1, 1) withString:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [parameterstring dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err;
        NSString *infostring= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        ChZ_DebugLog(@"%@",infostring);
        return ;
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
//        ChZ_DebugLog(@"%@---%@",dic,err);
//        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        ChZ_DebugLog(@"%@",string);
        
    }];
    [dataTask resume];
}


+ (void)PosPHPtWithURL:(NSString *)url parameters:(NSDictionary * )parameters progress:(void (^) (NSProgress *_Nonnull uploadProgress) )progress success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    
    
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    NSDictionary *dic = [self createAuthParameters:parameters];
    
    
    [manager POST:[self signBase64Url:url]  parameters:dic progress:^(NSProgress * _Nonnull uploadProgress)
     {
         if (progress)
         {
             progress(uploadProgress);
         }
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ChZ_ErrorLog(@"%@",error);
         if (failure)
         {
             failure(task,error);
         }
         
     }];
}

+ (void)PostWithURL:(NSString *)url parameters:(NSDictionary * )parameters progress:(void (^) (NSProgress *_Nonnull uploadProgress) )progress success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    NSDictionary *dic = [self createAuthParameters:parameters];
    
    
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress)
     {
         if (progress)
         {
             progress(uploadProgress);
         }
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ChZ_ErrorLog(@"%@",error);
         if (failure)
         {
             failure(task,error);
         }
         
     }];
}

+ (void)GetWithURL:(NSString *)url parameters:(NSDictionary * )parameters progress:(void (^) (NSProgress *_Nonnull downloadProgress) )progress success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress)
     {
         if (progress)
         {
             progress(downloadProgress);
         }
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (failure)
         {
             failure(task,error);
         }
     }];
}

+ (void)GetPHPWithURL:(NSString *)url parameters:(NSDictionary * )parameters progress:(void (^) (NSProgress *_Nonnull downloadProgress) )progress success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    [self setRequestHead:manager];
    [manager GET:[self signBase64Url:url] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress)
     {
         if (progress)
         {
             progress(downloadProgress);
         }
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         if (failure)
         {
             failure(task,error);
         }
     }];
}
+ (void)XHHuploadImageWithURL:(NSString *)url
                       images:(NSArray *)images
                   parameters:(NSDictionary * )parameters
                     progress:(void (^) (NSProgress *_Nonnull downloadProgress) )progress
                      success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    AFHTTPSessionManager *manager =  [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         
                                                         nil];
    manager.requestSerializer= [AFHTTPRequestSerializer serializer];
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    [manager POST:[self signBase64Url:url] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //把image  转为data , POST上传只能传data
        NSInteger fileNmaeIndex = 0;
        for(UIImage *image in images){
            NSData *data = UIImageJPEGRepresentation(image,0.5);
            NSString *date= [ChZUtil chz_dateStringWtihDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"iosapp%@.png",date];
            
            //            NSString *fileName = [NSString stringWithFormat:@"squareRelease%ld.png",fileNmaeIndex];
            [formData appendPartWithFileData:data
                                        name:@"file"
                                    fileName:fileName
                                    mimeType:@"image/png"];
            fileNmaeIndex++;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress)
        {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success)
        {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                success(task,responseObject);
            }
            else{
                NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                success(task,dic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
        {
            failure(task,error);
        }
    }];
}
+(NSString *)signBase64Url:(NSString *)url{
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    NSString *currString = [NSString stringWithFormat:@"%ld", (long)timeInterval];
    NSString *base64String2 = [self base64Encoding:[NSString stringWithFormat:@"%ld",(long)timeInterval*2]];
    
    NSString *currMhString = [currString stringByAppendingString:@"mhtx"];
    NSString *md5String = [ChZUtil chz_MD5WithString:[ChZUtil chz_MD5WithString:currMhString]];
    NSString *nUrl = [NSString stringWithFormat:@"%@&fid=%@&sign=%@&timestamp=%@",url,[APPControl sharedAPPControl].user.fid,md5String,base64String2];
    return nUrl;
}
+ (void)setRequestHead:(AFHTTPSessionManager *)sessionMgr
{
    
    sessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
//    sessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionMgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    sessionMgr.responseSerializer.acceptableContentTypes = nil;
    //    sessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionMgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
}

+ (NSDictionary *)createAuthParameters:(NSDictionary * )parameters
{
    NSString *appKey = @"ZLz8qeOA81";
    NSString *appsecret = @"xL01LFnRuSoG29Ar8dqb21ijNBSJCybI";
    NSNumber *nonce = [NSNumber numberWithUnsignedInt:arc4random()];
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 + 120;
    NSNumber *dealTime = [NSNumber numberWithDouble:timeInterval];
    NSMutableDictionary *parames = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    [parames setObject:appKey forKey:@"appkey"];
    [parames setObject:[NSString stringWithFormat:@"%@",nonce] forKey:@"nonce"];
    [parames setObject:[NSString stringWithFormat:@"%@",dealTime] forKey:@"dealTime"];
    NSArray *allKeyArray = parames.allKeys;
    NSArray *keyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    
    NSMutableString *sb = [NSMutableString string];
    
    [sb appendString:@"{"];
    for (NSString *key in keyArray)
    {
        NSString *value = [parames objectForKey:key];
        [sb appendFormat:@"\"%@\":\"%@\",",key,value];
    }
    [sb deleteCharactersInRange:NSMakeRange(sb.length-1, 1)];
    [sb appendString:@"}"];
    NSString *base64 = [self base64Encoding:sb];
    const char *cKey  = [appsecret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [base64 cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", cHMAC[i]];
    }
    NSString *hash = output;
    NSString *encodedSign = [self base64Encoding:hash];
    [parames setObject:encodedSign forKey:@"encodedSign"];
    return parames;
}

+ (NSString *)base64Encoding:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    NSMutableString *base64SB = [NSMutableString stringWithString:base64];
//    [base64SB replaceOccurrencesOfString:@"+" withString:@"-" options:0 range:NSMakeRange(0, base64.length)];
//    [base64SB replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0, base64.length)];
//    [base64SB replaceOccurrencesOfString:@"=" withString:@"" options:0 range:NSMakeRange(0, base64.length)];
    return base64SB;
}

+ (NSString *)createAuth:(NSString *)method parameters:(NSDictionary * )parameters urlString:(NSString *)urlString key:(NSString *)key
{
    if (!ChZ_StringIsEmpty(method) || !ChZ_StringIsEmpty(urlString) || !ChZ_StringIsEmpty(key))
    {
        return nil;
    }
    if (parameters == nil || parameters.count == 0) {
        return nil;
    }
    
    NSMutableString *sb = [NSMutableString string];
    NSURL *url = [NSURL URLWithString:urlString];
    [sb appendString:method];
    [sb appendString:@"\n"];
    
    NSString *host = url.host;
    [sb appendString:host];
    [sb appendString:@"\n"];
    
    NSString *path = url.path;
    [sb appendString:path];
    [sb appendString:@"\n"];
    
    NSArray *allKeyArray = parameters.allKeys;
    NSArray *keyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    
    for (NSString *key in keyArray) {
        NSString *value = [parameters objectForKey:key];
        [sb appendString:key];
        [sb appendString:@"="];
        
        NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
        NSCharacterSet *encodeUrlSet = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        NSString *encodePara = [value stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
        [sb appendString:encodePara];
        [sb appendString:@"&"];
    }
    [sb deleteCharactersInRange:NSMakeRange(sb.length-1, 1)];
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [sb cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *HMAC = nil;
    HMAC = [HMACData base64EncodedStringWithOptions:0];
    return HMAC;
}



@end

