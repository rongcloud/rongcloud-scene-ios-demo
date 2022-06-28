//
//  MHSDK.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHSDK : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSMutableArray * menuArray;
@property (nonatomic, strong) NSMutableArray * beautyAssembleArr;
@property (nonatomic, strong) NSMutableArray * stickerArray;
@property (nonatomic, strong) NSMutableArray * makeupArray;
@property (nonatomic, strong) NSMutableArray * effectMenuArray;
@property (nonatomic, strong) NSMutableArray * magnifiedArray;
@property (nonatomic, strong) NSMutableArray * meunMagnifiedArray;
@property (nonatomic, strong) NSMutableArray * skinArray;
@property (nonatomic, strong) NSMutableArray * faceArr;
@property (nonatomic, strong) NSMutableArray * completeBeautyArray;
@property (nonatomic, strong) NSMutableArray * filterArray;
@property (nonatomic, strong) NSMutableArray * specificEffectArray;
@property (nonatomic, strong) NSMutableArray * actionArray;

- (void)init:(NSString *)appKey;

- (void)dataTaskWithURLKey:(NSString *)urlKey responseCompletionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
/**
 获取sdk的版本0：基础版，1:专业版，2:精简版
 */
- (int)getSDKLevel;
@end

NS_ASSUME_NONNULL_END
