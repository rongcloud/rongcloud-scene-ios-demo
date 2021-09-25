//
//  RCCRSGiftModel.h
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCRSGiftModel : NSObject

@property (nonatomic, strong, nonnull) NSString *giftId;
@property (nonatomic, strong, nonnull) NSString *name;
@property (nonatomic, assign) NSUInteger value;
@property (nonatomic, assign) NSUInteger count;

- (instancetype)initWith:(NSString *)giftId
                    name:(NSString *)name
                   value:(NSUInteger)value
                   count:(NSUInteger)count;

+ (NSDictionary *)encode:(RCCRSGiftModel *)gift;
+ (RCCRSGiftModel *)decode:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
