#import "RCMusicChannelResponse.h"

@implementation RCMusicChannelResponse

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"data":RCMusicChannelData.class,
    };
}
@end

@implementation RCMusicChannelData
@end
