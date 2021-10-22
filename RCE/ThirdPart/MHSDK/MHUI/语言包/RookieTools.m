//
//  RookieTools.m
//  SwitchLanguage
//
//  Created by Rookie on 2017/8/24.
//  Copyright © 2017年 Rookie. All rights reserved.
//

#import "RookieTools.h"
#import <UIKit/UIKit.h>
//#import "ShowMessageVC.h"

static RookieTools *shareTool = nil;

@interface RookieTools()

@property(nonatomic,strong)NSBundle *bundle;
@property(nonatomic,copy)NSString *language;

@end

@implementation RookieTools

+(id)shareInstance {
    @synchronized (self) {
        if (shareTool == nil) {
            shareTool = [[RookieTools alloc]init];
        }
    }
    return shareTool;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareTool == nil) {
        shareTool = [super allocWithZone:zone];
    }
    return shareTool;
}

-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}

-(void)resetLanguage:(NSString *)language withFrom:(NSString *)appdelegate{
    if ([language isEqualToString:self.language]) {
        return;
    }
    if ([language isEqualToString:@"kor"]) {
        language = @"ko";
    }
    if ([language isEqualToString:@"en"] || [language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"ko"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    self.language = language;
    
    [[NSUserDefaults standardUserDefaults]synchronize];
//    if (![appdelegate isEqualToString:@"appdelegate"]) {
//        [self resetRootViewController];
//    }
    
}
//-(void)resetRootViewController {
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//
//    ZYTabBarController *root = [[ZYTabBarController alloc]init];
//    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:root];
//    window.rootViewController = navi;
////    [root changeLanguage];
//
//}

@end
