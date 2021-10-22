//
//  HFVLibUtils.m
//  HFVMusic
//
//  Created by 灏 孙  on 2019/7/23.
//  Copyright © 2019 HiFiVe. All rights reserved.
//

#import "HFVLibUtils.h"
#import <UIKit/UIKit.h>
#include <CommonCrypto/CommonCrypto.h>
#import "HFVLibInfo.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation HFVLibUtils

+ (NSString *)uuidString {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    return [[uuid uppercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)base64EncodeString:(NSString *)string {
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString *)base64DecodeString:(NSString *)string {
    NSData *data=[[NSData alloc]initWithBase64EncodedString:string options:0];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)sha256String:(NSString *)string {
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

+(NSString *)md5Hex:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString *)hmacSHA1String:(NSString *)string Key:(NSString *)key error:(NSError**)error{
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (!cData) {
        *error = HFVMusicError(20503, @"特殊字符不能完成签名");
        return nil;
    }

    //sha1
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    //NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC
     //                                         length:sizeof(cHMAC)];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //const char *cStr = [outputData bytes];
    CC_MD5( cHMAC, 20, result );
    //CC_MD5( cHMAC, (CC_LONG)strlen(cHMAC), result );

    //x表示小写，X大写
    NSString *resultStr = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return resultStr;
}

+ (NSString *)hmacSHA256String:(NSString *)string Key:(NSString *)key {
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];

    size_t size;
    size = CC_SHA256_DIGEST_LENGTH;
    
    unsigned char result[size];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), data.bytes, data.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:size * 2];
    for (int i = 0; i < size; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

+(NSString *)generateTradeNO:(NSUInteger)length {
    //生成随机字符串，区分大小写，数字和字母
    if (length>0) {
        NSMutableString *resultString = [NSMutableString stringWithCapacity:0];
        NSString *string = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        for (int i=0; i<length; i++) {
            //生成一个随机数
            NSUInteger ramdom = rand() % [string length];
            NSString *sub = [string substringWithRange:NSMakeRange(ramdom, 1)];
            [resultString appendString:sub];
        }
        return resultString;
    } else {
        return nil;
    }
}

+ (NSArray<NSString *> *)stortByASCII:(NSArray<NSString *> *)strings {
    
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        
        return [[obj1 isKindOfClass:[NSString class]] ? obj1 : [NSString stringWithFormat:@"%@",obj1] compare:[obj2 isKindOfClass:[NSString class]] ? obj2 : [NSString stringWithFormat:@"%@",obj2] ];
    };
    return [strings sortedArrayUsingComparator:sort];
}

+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (NSString *)strUTF8Encoding:(NSString *)str {
    if (@available(iOS 9.0, *)) {
        NSString * charaters = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:charaters] invertedSet];
        return [str stringByAddingPercentEncodingWithAllowedCharacters:set];
    } else {
        return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, (CFStringRef)@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ", kCFStringEncodingUTF8));
    }
}
+ (NSString *)urlEncode:(NSString *)url {
    if (@available(iOS 9.0, *)) {
        return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else {
        return  [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
//    NSString *result = (NSString*)CFURLCreateStringByAddingPercentEscapes(nil,
//                                                                          (CFStringRef)url, nil,
//                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
}

+ (NSDictionary *)urlEncodeWithDIctionary:(NSDictionary *)dict {
    NSMutableDictionary *encodeDict = [NSMutableDictionary dictionary];
    for (NSString *key in dict.allKeys) {
        NSString *value = [NSString stringWithFormat:@"%@",[dict objectForKey:key]];
        
        NSString * charaters = @"?!@#$^&=%*+,:;'\"`<>()[]{}/\\| ";
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:charaters] invertedSet];
        NSString *urlEncodeValue;
        if (@available(iOS 9.0, *)) {
            urlEncodeValue = [value stringByAddingPercentEncodingWithAllowedCharacters:set];
        }else {
            urlEncodeValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (urlEncodeValue) {
            [encodeDict setObject:urlEncodeValue forKey:key];
        }
      
    }
    return [encodeDict copy];
}
+ (NSError *)creatError:(NSInteger)code msg:(NSString *)msg {
    return [NSError errorWithDomain:HFVMusicDomain code:code userInfo:@{@"code":@(code),@"msg":msg}];
}

+ (void)log:(NSString *)str {
    if ([HFVLibInfo shared].isDebug) {
        NSLog(@"%@", str);
    }
   
}

+(BOOL) isHaveChinese:(NSString *) str {
    if ([HFVLibUtils isBlankString:str]) {
        return NO;
    }
    for (NSInteger i = 0; i<str.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subStr = [str substringWithRange:range];
        const char *cStr = [subStr UTF8String];
        if (!cStr) {
            return YES;
        }
        if (cStr && strlen(cStr)>=3) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)isHavespecial:(NSString *)str {
    if ([HFVLibUtils isBlankString:str]) {
        return NO;
    }
    NSString * specialString = @"~,￥,#,&,*,<,>,《,》,(,),[,],{,},【,】,^,@,/,￡,¤,,|,§,¨,「,」,『,』,￠,￢,￣,（,）,——,+,|,$,_,€,¥";
            NSArray *specialArray = [specialString componentsSeparatedByString:@","];
    for (NSString *symbol in specialArray) {
        if ([str rangeOfString:symbol].location != NSNotFound) {
            //有特殊字符
            return  YES;
        }
    }
    return NO;
}

+(BOOL)isOnlyHaveNumberAndLetter:(NSString *)str {
    NSString * regex = @"^[A-Za-z0-9]{1,50}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

+(BOOL)isOnlyHaveNumberLetterAndChinese:(NSString *)str {
    NSString * regex = @"^[A-Za-z0-9\u4e00-\u9fa5]{1,50}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}


@end
