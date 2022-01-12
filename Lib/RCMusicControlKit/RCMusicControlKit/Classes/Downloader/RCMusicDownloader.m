//
//  RCMusicDownloader.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import "RCMusicDownloader.h"
#import "RCMusicDownloadTaskReceiver.h"
#import "RCMusicEngine.h"
#import "SVProgressHUD.h"
#import "RCMusicDataPath.h"
@interface RCMusicDownloader ()<NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) NSMutableDictionary *taskReceiverTable;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation RCMusicDownloader

#pragma mark - SHARE INSTANCE

+ (RCMusicDownloader *)shareInstance {
    static dispatch_once_t onceToken;
    static RCMusicDownloader *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.lock = [[NSLock alloc] init];
        self.taskReceiverTable = [@{} mutableCopy];
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - GETTER

+ (nullable NSURLSessionDownloadTask *)downloadWithInfo:(id<RCMusicInfo>)info
                                     progress:(void (^ _Nullable)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                               downloadFinish:(void(^ _Nullable)(NSString * _Nullable filePath, NSURLResponse * _Nullable response))downloadFinish
                            completionHandler:(void (^ _Nullable)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error))completionHandler {
    if (info.fileUrl == nil  || info.fileUrl.length == 0) return  nil;
    info.fileUrl = [info.fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDownloadTask *task = [[self shareInstance].session downloadTaskWithURL:[NSURL URLWithString:info.fileUrl]];
    [[self shareInstance] addReceiverForDownloadTask:task progress:downloadProgressBlock downloadFinish:downloadFinish completionHandler:completionHandler];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //串行下载，可接受多个任务
        dispatch_semaphore_wait([RCMusicDownloader shareInstance].semaphore, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC));
        //本地存在的音频取消任务
        
        if ([[RCMusicEngine shareInstance].dataSource musicIsExist:info] && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@""]]) {
            [task cancel];
        } else {
            [task resume];
        }
    });
    return task;
}

- (NSURLSession *)session {
    if (_session == nil) {
        @synchronized (self) {
            _session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:self.queue];
        }
    }
    return _session;
}

- (NSURLSessionConfiguration *)configuration {
    return [NSURLSessionConfiguration defaultSessionConfiguration];
}

- (NSOperationQueue *)queue {
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (void)addReceiverForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                          progress:(void (^)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                    downloadFinish:(void(^)(NSString * _Nullable filePath, NSURLResponse * _Nullable response))downloadFinish
                 completionHandler:(void (^)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error))completionHandler {
    //添加代理回调监听的对象
    RCMusicDownloadTaskReceiver *receiver = [[RCMusicDownloadTaskReceiver alloc] init];
    receiver.downloadProgressBlock = downloadProgressBlock;
    receiver.completionHandler = completionHandler;
    receiver.downloadTaskDidFinishDownloading = downloadFinish;
    [self setReceiver:receiver forTask:downloadTask];
}

- (void)setReceiver:(RCMusicDownloadTaskReceiver *)receiver forTask:(NSURLSessionDownloadTask *)task {
    if (receiver == nil || task == nil) {
        return;
    }
    [self.lock lock];
    self.taskReceiverTable[@(task.taskIdentifier)] = receiver;
    [self.lock unlock];
}

- (nullable RCMusicDownloadTaskReceiver *)receiverForTask:(NSURLSessionTask *)task {
    
    if (task == nil) {
        return nil;
    }
    RCMusicDownloadTaskReceiver *delegate = nil;
    [self.lock lock];
    delegate = self.taskReceiverTable[@(task.taskIdentifier)];
    [self.lock unlock];

    return delegate;
}


#pragma mark - URL SESSION DELEGATE

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    RCMusicDownloadTaskReceiver *receiver = [self receiverForTask:task];
    [receiver URLSession:session task:task didCompleteWithError:error];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    RCMusicDownloadTaskReceiver *receiver = [self receiverForTask:downloadTask];
    [receiver URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    RCMusicDownloadTaskReceiver *receiver = [self receiverForTask:downloadTask];
    [receiver URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    RCMusicDownloadTaskReceiver *receiver = [self receiverForTask:downloadTask];
    [receiver URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
}
@end
