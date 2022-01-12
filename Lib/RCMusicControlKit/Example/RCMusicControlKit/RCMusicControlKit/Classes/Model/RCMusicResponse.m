#import "RCMusicResponse.h"

@implementation RCMusicResponse
@end

@implementation RCMusicData
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"record":RCMusicRecord.class,
    };
}
@end

@implementation RCMusicMeta
@end

@implementation RCMusicFigureInfo
@end

@implementation RCMusicRecord
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"tag":RCMusicTag.class,
        @"cover":RCMusicCover.class,
        @"composer":RCMusicFigureInfo.class,
        @"version":RCMusicVersion.class,
    };
}

- (NSString *)authorName {
//    if (self.artist != nil && self.artist.count > 0) {
//        return self.artist.firstObject.name;
//    } else if (self.author != nil && self.author.count > 0) {
//        return self.author.firstObject.name;
//    } else if (self.composer != nil && self.composer.count > 0) {
//        return self.composer.firstObject.name;
//    } else if (self.arranger != nil && self.arranger.count > 0) {
//        return self.arranger.firstObject.name;
//    }
    return self.composer.firstObject.name;
}

- (NSString *)coverUrl {
    if (self.cover != nil && self.cover.count > 0) {
        return self.cover.firstObject.url;;
    }
    return nil;
}

@end


@implementation RCMusicCover
@end

@implementation RCMusicTag
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"child":RCMusicTag.class,
    };
}
@end

@implementation RCMusicVersion
@end
