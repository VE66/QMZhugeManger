//
//  QMZhugeManager.m
//  Pods
//
//  Created by ZCZ on 2022/3/18.
//

#import "QMZhugeManager.h"
#import "QMZhugeDB.h"
#import "QMNetworkManager.h"

@interface QMZhugeManager ()

@property (nonatomic, copy) NSString *accessId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *sid;

@property (nonatomic, strong) NSTimer *upTimer;
@property (nonatomic, assign) NSUInteger currentUpLoad;

@end

@implementation QMZhugeManager

+ (instancetype)shared {
    static QMZhugeManager *_zhugeMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zhugeMgr = [QMZhugeManager new];
    });
    
    return _zhugeMgr;
}

- (instancetype)init {
    if (self) {
        [QMZhugeDB shared];
    }
    return self;
}

+ (void)setAccessid:(NSString *)accessId userId:(NSString *)userId userName:(nonnull NSString *)userName version:(nonnull NSString *)version sid:(NSString *)sid {
    QMZhugeManager.shared.accessId = accessId;
    QMZhugeManager.shared.userId = userId;
    QMZhugeManager.shared.userName = userName;
    QMZhugeManager.shared.version = version;
    QMZhugeManager.shared.sid = sid;
}

- (void)changeRealSid:(NSString *)sid {
    if (self.sid.length == 0) {
        self.sid = sid;
    } else {
        self.sid = [NSString stringWithFormat:@"%@#%@", self.sid, sid];
    }
}

+ (void)trackEvent:(NSString *)eventName {
    
    NSString *accessId = QMZhugeManager.shared.accessId ? : @"";
    NSString *userId = QMZhugeManager.shared.userId ? : @"";
    NSString *userName = QMZhugeManager.shared.userName ? : @"";
    NSString *version = QMZhugeManager.shared.version ? : @"";
    NSString *sid = QMZhugeManager.shared.sid ? : @"";

    // 存入数据库
    [QMZhugeDB insertData:eventName accessId:accessId userId:userId userName:userName version:version sid:sid];
    
    if (QMZhugeManager.shared.upTimer.isValid == false) {
        if (@available(iOS 10.0, *)) {
            [self upZhugeData];
            __weak typeof(self)wSelf = self;
            QMZhugeManager.shared.upTimer = [NSTimer scheduledTimerWithTimeInterval:80 repeats:YES block:^(NSTimer * _Nonnull timer) {
                __strong typeof(wSelf)sSelf = wSelf;
                [sSelf upZhugeData];
            }];
        } else {
            // Fallback on earlier versions
            QMZhugeManager.shared.upTimer = [NSTimer scheduledTimerWithTimeInterval:80 target:self selector:@selector(upZhugeData) userInfo:nil repeats:YES];
        }
    }
    
}

+ (void)upZhugeData {
    if (QMZhugeManager.shared.currentUpLoad == 0 || QMZhugeManager.shared.currentUpLoad == NSNotFound) {
        NSArray *items = [QMZhugeDB getTrackData];
        if (items.count > 0) {
            QMZhugeManager.shared.currentUpLoad = items.count;
            dispatch_group_t group = dispatch_group_create();
            for (NSDictionary *param in items) {
                dispatch_group_enter(group);
                [QMNetworkManager uploadZhugeData:param isDebug:YES completion:^(BOOL rel) {
                    if (rel) {
                        NSString *time = param[@"time"];
                        [QMZhugeDB.shared deleteDataWithTime:time];
                    }
                    dispatch_group_leave(group);
                }];
            }
            
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                QMZhugeManager.shared.currentUpLoad = 0;                
            });
        }
    }
    
}

+ (void)trackNetWorking:(NSDictionary *)event {
    if (event && [event isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingFragmentsAllowed error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString) {
            [self trackEvent:jsonString];
        }
    }
}

@end
