//
//  HFVLibUtils.h
//  HFVMusic
//
//  Created by 灏 孙  on 2019/7/23.
//  Copyright © 2019 HiFiVe. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HFVMusicDomain @"HFVMusicDomain"
#define HFVMusicError(c,m) [[NSError alloc] initWithDomain:@"HFVMusicDomain" code:c userInfo:@{@"code":@(c),@"msg":m}]


#define KHFVNotification_Api_RequestError @"KHFVNotification_Api_RequestError"
#define KHFVNotification_Api_ServerError @"KHFVNotification_Api_ServerError"

@interface HFVLibUtils : NSObject

+ (NSString *)uuidString;
+ (NSString *)md5Hex:(NSString *)string;
+ (NSString *)base64EncodeString:(NSString *)string;
+ (NSString *)base64DecodeString:(NSString *)string;
+ (NSString *)sha256String:(NSString *)string;
+ (NSString *)hmacSHA1String:(NSString *)string Key:(NSString *)key error:(NSError**)error;
+ (NSString *)hmacSHA256String:(NSString *)string Key:(NSString *)key;
+ (NSArray<NSString *> *)stortByASCII:(NSArray<NSString *> *)strings;
+ (BOOL)isBlankString:(NSString *)string;
+ (NSString *)strUTF8Encoding:(NSString *)str;
+ (NSString *)urlEncode:(NSString *)url;
+ (NSString *)generateTradeNO:(NSUInteger) length;
+ (NSMutableDictionary *)urlEncodeWithDIctionary:(NSDictionary *)dict;
+ (void)log:(NSString *)str;
+(BOOL) isHaveChinese:(NSString *) str;
+(BOOL)isHavespecial:(NSString *)str;
+(BOOL)isOnlyHaveNumberAndLetter:(NSString *)str;
+(BOOL)isOnlyHaveNumberLetterAndChinese:(NSString *)str;
@end

