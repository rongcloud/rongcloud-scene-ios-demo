//
//  NSString+LogOutput.h
//  RCE
//
//  Created by 叶孤城 on 2021/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LogOutput)

+ (void)redirectNSlogToDocumentFolder;

@end

NS_ASSUME_NONNULL_END
