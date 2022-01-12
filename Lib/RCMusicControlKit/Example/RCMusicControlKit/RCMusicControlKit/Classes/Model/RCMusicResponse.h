#import <Foundation/Foundation.h>

@class RCMusicResponse;
@class RCMusicData;
@class RCMusicMeta;
@class RCMusicRecord;
@class RCMusicFigureInfo;
@class RCMusicCover;
@class RCMusicTag;
@class RCMusicVersion;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RCMusicResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, copy)   NSString *msg;
@property (nonatomic, nullable, strong) RCMusicData *data;
@property (nonatomic, nullable, copy)   NSString *taskId;
@end

@interface RCMusicData : NSObject
@property (nonatomic, nullable, copy)   NSArray<RCMusicRecord *> *record;
@property (nonatomic, nullable, strong) RCMusicMeta *meta;
@end

@interface RCMusicMeta : NSObject
@property (nonatomic, nullable, strong) NSNumber *totalCount;
@property (nonatomic, nullable, strong) NSNumber *currentPage;
@end

@interface RCMusicRecord : NSObject
@property (nonatomic, nullable, copy)   NSString *musicId;
@property (nonatomic, nullable, copy)   NSString *intro;
@property (nonatomic, nullable, copy)   NSString *musicName;
@property (nonatomic, nullable, copy)   NSString *albumId;
@property (nonatomic, nullable, copy)   NSString *albumName;
@property (nonatomic, nullable, strong) NSNumber *duration;
@property (nonatomic, nullable, strong) NSNumber *bpm;
@property (nonatomic, nullable, strong) NSNumber *auditionBegin;
@property (nonatomic, nullable, strong) NSNumber *auditionEnd;
@property (nonatomic, nullable, copy)   NSArray<RCMusicTag *> *tag;
@property (nonatomic, nullable, copy)   NSArray<RCMusicCover *> *cover;
@property (nonatomic, nullable, copy)   NSArray<RCMusicFigureInfo *> *composer;
@property (nonatomic, nullable, copy)   NSArray<RCMusicVersion *> *version;
@property (nonatomic, nullable, copy)   NSArray<RCMusicFigureInfo *> *artist;
@property (nonatomic, nullable, copy)   NSArray<RCMusicFigureInfo *> *author;
@property (nonatomic, nullable, copy)   NSArray<RCMusicFigureInfo *> *arranger;
//计算属性，下载进度
//authorName 返回作者名字，优先级 表演者 artist > 作词者 author > 作曲者 composer > 编曲者 arranger
@property (nonatomic, nullable, copy)   NSString *authorName;
@property (nonatomic, nullable, copy)   NSString *coverUrl;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign, getter=isLocal) BOOL local;
@end

@interface RCMusicFigureInfo : NSObject
@property (nonatomic, nullable, copy) NSString *name;
@property (nonatomic, nullable, copy) NSString *code;
@property (nonatomic, nullable, copy) NSString *avatar;
@end

@interface RCMusicCover : NSObject
@property (nonatomic, nullable, copy) NSString *url;
@property (nonatomic, nullable, copy) NSString *size;
@end

@interface RCMusicTag : NSObject
@property (nonatomic, nullable, strong) NSNumber *tagId;
@property (nonatomic, nullable, copy)   NSString *tagName;
@property (nonatomic, nullable, copy)   NSArray<RCMusicTag *> *child;
@end

@interface RCMusicVersion : NSObject
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, copy)   NSString *musicId;
@property (nonatomic, nullable, strong) NSNumber *free;
@property (nonatomic, nullable, strong) NSNumber *price;
@property (nonatomic, nullable, strong) NSNumber *majorVersion;
@property (nonatomic, nullable, strong) NSNumber *duration;
@property (nonatomic, nullable, strong) NSNumber *auditionBegin;
@property (nonatomic, nullable, strong) NSNumber *auditionEnd;
@end

NS_ASSUME_NONNULL_END
