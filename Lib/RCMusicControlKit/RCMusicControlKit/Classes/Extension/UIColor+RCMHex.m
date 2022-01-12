//
//  UIColor+RCMHex.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import "UIColor+RCMHex.h"

@implementation UIColor (RCMHex)
+ (UIColor *)rcmColorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
