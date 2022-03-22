//
//  QMNetworkManager.h
//  Pods
//
//  Created by ZCZ on 2022/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMNetworkManager : NSObject

+ (void)uploadZhugeData:(NSDictionary *)data completion:(void(^)(BOOL))completion;
+ (void)uploadZhugeData:(NSDictionary *)data isDebug:(BOOL)isDebug completion:(void(^)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
