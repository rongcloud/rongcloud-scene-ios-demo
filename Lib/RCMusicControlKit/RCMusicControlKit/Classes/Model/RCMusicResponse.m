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
        @"artist":RCMusicFigureInfo.class,
        @"author":RCMusicFigureInfo.class,
        @"composer":RCMusicFigureInfo.class,
        @"arranger":RCMusicFigureInfo.class,
        @"version":RCMusicVersion.class,
    };
}

- (NSString *)authorName {
    
    BOOL artistNameIsValid = self.artist != nil && self.artist.count > 0 && self.artist.firstObject.name;
    BOOL authorNameIsValid = self.author != nil && self.author.count > 0 && self.author.firstObject.name;
    BOOL composerNameIsValid = self.composer != nil && self.composer.count > 0 && self.composer.firstObject.name;
    BOOL arrangerNameIsValid = self.arranger != nil && self.arranger.count > 0 && self.arranger.firstObject.name;
    
    NSString *res = @"";
    if (artistNameIsValid) {
        res = self.artist.firstObject.name;
    } else if (authorNameIsValid) {
        res = self.author.firstObject.name;
    } else if (composerNameIsValid) {
        res = self.composer.firstObject.name;
    } else if (arrangerNameIsValid) {
        res = self.arranger.firstObject.name;
    }
    
    return res;
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
