//
//  RCMusicInfoModel.m
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import "RCMusicInfoModel.h"

@implementation RCMusicInfoModel
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fileUrl forKey:@"fileUrl"];
    [coder encodeObject:self.coverUrl forKey:@"coverUrl"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.musicName forKey:@"musicName"];
    [coder encodeObject:self.size forKey:@"size"];
    [coder encodeObject:self.albumName forKey:@"albumName"];
    [coder encodeObject:self.musicId forKey:@"musicId"];
    
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _fileUrl = [[coder decodeObjectForKey:@"fileUrl"] copy];
        _coverUrl = [[coder decodeObjectForKey:@"coverUrl"] copy];
        _author = [[coder decodeObjectForKey:@"author"] copy];
        _musicName = [[coder decodeObjectForKey:@"musicName"] copy];
        _size = [[coder decodeObjectForKey:@"size"] copy];
        _albumName = [[coder decodeObjectForKey:@"albumName"] copy];
        _musicId = [[coder decodeObjectForKey:@"musicId"] copy];
    }
    return self;
}

- (BOOL)isEqualToMusic:(id<RCMusicInfo>)music {
    
    if (music == nil) {
        return NO;
    }
    
    if (![music conformsToProtocol:@protocol(RCMusicInfo)]) {
        return NO;
    }
    
    return [self isEqual:music];
}
- (BOOL)isEqual:(id)object {
    
    if (self == object) {
        return  YES;
    }
    
    id <RCMusicInfo> music = object;

    return [music.musicId isEqualToString:self.musicId];
}
@end
