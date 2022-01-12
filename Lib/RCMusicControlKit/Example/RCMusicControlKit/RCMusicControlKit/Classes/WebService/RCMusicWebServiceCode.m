//
//  RCMusicWebServiceCode.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RCMusicWebServiceCode) {
    RCMusicWebServiceCodeSuccess = 10200,
    RCMusicWebServiceCodeUnRegistered = 20500,
    RCMusicWebServiceCodeNoLogin = 20501,
    RCMusicWebServiceCodeMissingParameter = 20502,
    RCMusicWebServiceCodeParameterError = 20503,
    RCMusicWebServiceCodeJsonError = 20504,
    RCMusicWebServiceCodeNoNetwork = 20505,
    RCMusicWebServiceCodeRequestTimeOut = 20506,
};
