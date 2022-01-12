//
//  NSString+MD5.m
//  ios-livevideosdk-quickdemo
//
//  Created by xuefeng on 2021/10/27.
//

#import "NSString+RCMMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (RCMMD5)
- (NSString *)rcm_md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

- (NSString *)sizeFormatString {
    if ([self isEqualToString:@"0"]) {
        return self;
    }
    if ([self integerValue] == 0) {
        NSAssert(NO, @"sizeFormatString string convert to int fail");
    }
    return [NSByteCountFormatter stringFromByteCount:[self integerValue] * 1024 countStyle:NSByteCountFormatterCountStyleFile];;
}

@end
