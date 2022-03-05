#import <Foundation/Foundation.h>

@class RCMusicChannelResponse;
@class RCMusicChannelData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RCMusicChannelResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, copy)   NSString *msg;
@property (nonatomic, nullable, copy)   NSArray<RCMusicChannelData *> *data;
@property (nonatomic, nullable, copy)   NSString *taskId;
@end

@interface RCMusicChannelData : NSObject
@property (nonatomic, nullable, copy) NSString *groupId;
@property (nonatomic, nullable, copy) NSString *groupName;
@property (nonatomic, nullable, copy) NSString *coverURL;
@end

NS_ASSUME_NONNULL_END
