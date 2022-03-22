//
//  QMNetworkManager.m
//  Pods
//
//  Created by ZCZ on 2022/3/21.
//

#import "QMNetworkManager.h"
#import <ZhugeioAnalytics/Zhuge.h>
@implementation QMNetworkManager

+ (void)uploadZhugeData:(NSDictionary *)data completion:(void(^)(BOOL))completion {
    [self uploadZhugeData:data isDebug:NO completion:completion];
}

+ (void)uploadZhugeData:(NSDictionary *)data isDebug:(BOOL)isDebug completion:(void(^)(BOOL))completion {
    NSURL *url = [NSURL URLWithString:@"https://u.zhugeapi.com/open/v2/event_statis_srv/upload_event"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *appkey = @"483b1af760ef4eddadf8fac984dba785";
    NSString *secretkey = @"249c745a0dba44be9e6df8fbe94c4571";
    
    NSString *baseKey = [NSString stringWithFormat:@"%@:%@", appkey, secretkey];
    NSString *baseData = [[baseKey dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", baseData];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = @"POST";
        
    
    NSData *jsonData = [self handData:data isDebug:isDebug appkey:appkey];
    request.HTTPBody = jsonData;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"data = %@", dict);
            if ([dict[@"return_code"] integerValue] == 0) {
                completion(YES);
            } else {
                completion(NO);
            }
        } else {
            NSLog(@"error = %@", error);
            completion(NO);
        }
        
    }];
    
    [dataTask resume];
    
}

+ (NSData *)handData:(NSDictionary *)data isDebug:(BOOL)isDebug appkey:(NSString *)appkey {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:appkey forKey:@"ak"];
    
    NSString *eid = data[@"data"] ?: @"";
    NSTimeInterval ct = [data[@"time"] doubleValue];
    NSString *sid = data[@"sid"] ? : @"";

    NSString *accessid = data[@"accessId"] ? : @"";
    NSString *userName = data[@"userName"] ? : @"";
    NSString *userId = data[@"userId"] ? : @"";
    NSString *cuid = [NSString stringWithFormat:@"%@_%@_%@", accessid, userName, userId];
    NSString *version = data[@"version"] ? : @"";
            
    NSString *json = [NSString stringWithFormat:@"{\"pr\":{\"$eid\":\"%@\",\"$vn\":\"%@\",\"$cuid\":\"%@\",\"$ct\":%.0lf,\"$sid\":\"%@\"},\"debug\":%d,\"ak\":\"%@\",\"dt\":\"evt\",\"pl\":\"ios\"}", eid, version, cuid, ct, sid, isDebug, appkey];
    
    return [json dataUsingEncoding:NSUTF8StringEncoding];
}


@end
