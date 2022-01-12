#import <Foundation/Foundation.h>

@class RCMusicSheetResponse;
@class RCMusicSheetData;
@class RCMusicSheetMeta;
@class RCMusicSheetRecord;
@class RCMusicSheetCover;
@class RCMusicSheetMusic;
@class RCMusicSheetArtist;
@class RCMusicSheetTag;
@class RCMusicSheetVersion;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface RCMusicSheetResponse : NSObject
@property (nonatomic, nullable, strong) NSNumber *code;
@property (nonatomic, nullable, copy)   NSString *msg;
@property (nonatomic, nullable, strong) RCMusicSheetData *data;
@property (nonatomic, nullable, copy)   NSString *taskId;
@end

@interface RCMusicSheetData : NSObject
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetRecord *> *record;
@property (nonatomic, nullable, strong) RCMusicSheetMeta *meta;
@end

@interface RCMusicSheetMeta : NSObject
@property (nonatomic, nullable, strong) NSNumber *totalCount;
@property (nonatomic, nullable, strong) NSNumber *currentPage;
@end

@interface RCMusicSheetRecord : NSObject
//选中状态
@property (nonatomic,assign) BOOL selected;
@property (nonatomic, nullable, strong) NSNumber *sheetId;
@property (nonatomic, nullable, copy)   NSString *sheetName;
@property (nonatomic, nullable, strong) NSNumber *musicTotal;
@property (nonatomic, nullable, strong) NSNumber *type;
@property (nonatomic, nullable, copy)   NSString *describe;
@property (nonatomic, nullable, strong) NSNumber *free;
@property (nonatomic, nullable, strong) NSNumber *price;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetTag *> *tag;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetMusic *> *music;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetCover *> *cover;
@end

@interface RCMusicSheetCover : NSObject
@property (nonatomic, nullable, copy) NSString *url;
@property (nonatomic, nullable, copy) NSString *size;
@end

@interface RCMusicSheetMusic : NSObject
@property (nonatomic, nullable, copy)   NSString *musicId;
@property (nonatomic, nullable, copy)   NSString *musicName;
@property (nonatomic, nullable, copy)   NSString *intro;
@property (nonatomic, nullable, copy)   NSString *albumId;
@property (nonatomic, nullable, copy)   NSString *albumName;
@property (nonatomic, nullable, strong) NSNumber *duration;
@property (nonatomic, nullable, strong) NSNumber *bpm;
@property (nonatomic, nullable, strong) NSNumber *auditionBegin;
@property (nonatomic, nullable, strong) NSNumber *auditionEnd;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetTag *> *tag;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetCover *> *cover;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetArtist *> *artist;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetArtist *> *author;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetArtist *> *composer;
@property (nonatomic, nullable, copy)   NSArray *arranger;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetVersion *> *version;
@end

@interface RCMusicSheetArtist : NSObject
@property (nonatomic, nullable, copy) NSString *name;
@property (nonatomic, nullable, copy) NSString *code;
@property (nonatomic, nullable, copy) NSString *avatar;
@end

@interface RCMusicSheetTag : NSObject
@property (nonatomic, nullable, strong) NSNumber *tagId;
@property (nonatomic, nullable, copy)   NSString *tagName;
@property (nonatomic, nullable, copy)   NSArray<RCMusicSheetTag *> *child;
@end

@interface RCMusicSheetVersion : NSObject
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
