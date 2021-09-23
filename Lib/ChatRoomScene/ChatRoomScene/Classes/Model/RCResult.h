//
//  RCResult.h
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 RCResult *result = [RCResult success:@(123)];
 switch (result.type) {
     case RCResultSuccess:
         NSLog(@"%@", result.value);
         break;
         
     case RCResultFailure:
         NSLog(@"%@", result.error);
         break;
 }
 */

typedef NS_ENUM(NSUInteger, RCResultType) {
    RCResultSuccess,
    RCResultFailure,
};

@interface RCResult : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new NS_UNAVAILABLE;

+ (nonnull RCResult *)success:(nonnull id)value;
+ (nonnull RCResult *)failure:(nonnull NSError *)error;

@property (readonly) RCResultType type;
@property (readonly, nonnull) id value;
@property (readonly, nonnull) NSError *error;

@end

NS_ASSUME_NONNULL_END
