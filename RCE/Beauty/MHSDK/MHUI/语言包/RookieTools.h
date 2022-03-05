//
//  RookieTools.h
//  SwitchLanguage
//
//  Created by Rookie on 2017/8/24.
//  Copyright © 2017年 Rookie. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface RookieTools : NSObject

+(id)shareInstance;
/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;
/**
 *  重置语言
 *
 *  @param language 新语言
 */
-(void)resetLanguage:(NSString*)language withFrom:(NSString *)appdelegate;

@end
