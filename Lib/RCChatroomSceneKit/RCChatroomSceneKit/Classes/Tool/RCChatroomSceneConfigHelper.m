//
//  RCChatroomSceneConfigHelper.m
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/7.
//

#import "RCChatroomSceneConfigHelper.h"
#import "RCChatroomSceneConstants.h"

@implementation RCChatroomSceneConfigHelper

+ (id)configFromJsonForClass:(Class)cls {
    NSBundle *selfBundle = [NSBundle bundleForClass:[RCChatroomSceneConfigHelper class]];
    NSString *resourceBundlePath = [selfBundle pathForResource:RCChatroomSceneBundleName ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *jsonPath = [resourceBundle pathForResource:RCChatroomSceneKitConfigPathComponent ofType:@"json"];
    return  [self configFromLocalPath:jsonPath forClass:cls];
}

+ (id)configFromLocalPath:(NSString *)path forClass:(Class)cls {
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    if (err) {
        return nil;
    }
    if (cls == [RCChatroomSceneToolBarConfig class]) {
        NSDictionary *toolBarConfigDict = [configDict valueForKeyPath:@"ChatRoomKit.ToolBar"];
        RCChatroomSceneToolBarConfig *config = [RCChatroomSceneToolBarConfig yy_modelWithJSON:toolBarConfigDict];
        return config;
    }
   
    if (cls == [RCChatroomSceneInputBarConfig class]) {
        NSDictionary *inputBarConfigDict = [configDict valueForKeyPath:@"ChatRoomKit.InputBar"];
        RCChatroomSceneInputBarConfig *config = [RCChatroomSceneInputBarConfig yy_modelWithJSON:inputBarConfigDict];
        return config;
    }
    if (cls == [RCChatroomSceneMessageViewConfig class]) {
        NSDictionary *messageViewrConfigDict = [configDict valueForKeyPath:@"ChatRoomKit.MessageView"];
        RCChatroomSceneMessageViewConfig *config = [RCChatroomSceneMessageViewConfig yy_modelWithJSON:messageViewrConfigDict];
        return config;
    }
    
    return nil;
}

@end
