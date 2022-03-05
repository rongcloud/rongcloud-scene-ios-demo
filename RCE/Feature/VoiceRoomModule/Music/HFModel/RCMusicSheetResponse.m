#import "RCMusicSheetResponse.h"

@implementation RCMusicSheetResponse
@end

@implementation RCMusicSheetData
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"record":RCMusicSheetRecord.class,
    };
}
@end

@implementation RCMusicSheetMeta
@end

@implementation RCMusicSheetRecord
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"tag":RCMusicSheetTag.class,
        @"music":RCMusicSheetMusic.class,
        @"cover":RCMusicSheetCover.class,
    };
}
@end

@implementation RCMusicSheetCover
@end

@implementation RCMusicSheetMusic
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"tag":RCMusicSheetTag.class,
        @"cover":RCMusicSheetCover.class,
        @"artist":RCMusicSheetArtist.class,
        @"author":RCMusicSheetArtist.class,
        @"composer":RCMusicSheetArtist.class,
        @"version":RCMusicSheetVersion.class,
    };
}
@end

@implementation RCMusicSheetArtist
@end

@implementation RCMusicSheetTag
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
        @"child":RCMusicSheetTag.class,
    };
}
@end

@implementation RCMusicSheetVersion
@end
