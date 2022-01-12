//
//  RCMusicDownloadTaskReceiver.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import "RCMusicDownloadTaskReceiver.h"
#import "RCMusicDataPath.h"

@interface RCMusicDownloadTaskReceiver ()
@property (nonatomic, strong) NSProgress *downloadProgress;
@property (nonatomic, copy) NSString *filePath;
@end

@implementation RCMusicDownloadTaskReceiver

- (void)dealloc {
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

- (instancetype)init {
    if (self = [super init]) {
        //监听下载进度
        self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        [self.downloadProgress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
    return self;
}

#pragma mark OBSERVER
//监听下载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
}

#pragma mark - SESSION DELEGATE

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (self.completionHandler) {
        self.completionHandler(task.response, self.filePath, error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    self.downloadProgress.totalUnitCount = expectedTotalBytes;
    self.downloadProgress.completedUnitCount = fileOffset;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    self.filePath = location.relativePath;
    if (self.downloadTaskDidFinishDownloading) {
        self.downloadTaskDidFinishDownloading(self.filePath, downloadTask.response);
    }
}

#pragma mark - GETTER

- (NSProgress *)downloadProgress {
    if (_downloadProgress == nil) {
        _downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    return _downloadProgress;
}

@end
