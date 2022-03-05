//
//  MHBeautyManager+Default.m
//  RCE
//
//  Created by shaoshuai on 2022/1/30.
//

#import "MHBeautyParams.h"
#import "MHBeautyManager+Default.h"

@implementation MHBeautyManager (Default)

- (void)handleFaceBeautyWithType:(NSInteger)type sliderValue:(NSInteger)value {
    self.isUseFaceBeauty = YES;
    switch (type) {
        case MHBeautyFaceType_Original:{
            //原图-->人脸识别设置
            self.isUseFaceBeauty = NO;
            [self setFaceLift:0];
            [self setBigEye:0];
            [self setMouthLift:0];
            [self setNoseLift:0];
            [self setChinLift:0];
            [self setForeheadLift:0];
            [self setEyeBrownLift:0];
            [self setEyeAngleLift:0];
            [self setEyeAlaeLift:0];
            [self setShaveFaceLift:0];
            [self setEyeDistanceLift:0];
        }
            break;
        case MHBeautyFaceType_ThinFace:
            [self setFaceLift:(int)value];
            break;
        case MHBeautyFaceType_BigEyes:
            [self setBigEye:(int)value];
            break;
        case MHBeautyFaceType_Mouth:
            [self setMouthLift:(int)value];
            break;
        case MHBeautyFaceType_Nose:
            [self setNoseLift:(int)value];
            break;
        case MHBeautyFaceType_Chin:
            [self setChinLift:(int)value];
            break;
        case MHBeautyFaceType_Forehead:
            [self setForeheadLift:(int)value];
            break;
        case MHBeautyFaceType_Eyebrow:
            [self setEyeBrownLift:(int)value];
            break;
        case MHBeautyFaceType_Canthus:
            [self setEyeAngleLift:(int)value];
            break;
        case MHBeautyFaceType_EyeAlae:
            [self setEyeAlaeLift:(int)value];
            break;
        case MHBeautyFaceType_EyeDistance:
            [self setEyeDistanceLift:(int)value];
            break;
        case MHBeautyFaceType_ShaveFace:
            [self setShaveFaceLift:(int)value];
            break;
        case MHBeautyFaceType_LongNose:
            [self setLengthenNoseLift:(int)value];
            break;
        default:
            break;
    }
    
}

- (void)handleBeautyWithType:(NSInteger)type level:(CGFloat)beautyLevel {
    switch (type) {
        case MHBeautyType_Original:{
            [self setRuddiness:0];
            [self setSkinWhiting:0];
            [self setBuffing:0.0];
        }
            break;
            
        case MHBeautyType_Mopi:
            [self setBuffing:beautyLevel];
            
            break;
        case MHBeautyType_White:
            [self setSkinWhiting:beautyLevel];
            break;
        case MHBeautyType_Ruddiess:
            [self setRuddiness:beautyLevel];
            break;
        case MHBeautyType_Brightness:
            [self setBrightnessLift:beautyLevel];
            break;
            
        default:
            break;
    }
}

- (void)applyDefaultValues {
    NSArray *faceValues = @[@"0", @"28", @"37", @"58", @"0", @"27", @"80", @"0", @"55", @"0", @"77", @"0", @"20"];
    for (int i = 0; i < faceValues.count; i++) {
        if (i == 0) continue;
        NSString *value = faceValues[i];
        NSString *key = [NSString stringWithFormat:@"face_%d", i];
        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:key];
        [self handleFaceBeautyWithType:i sliderValue:value.integerValue];
    }
    
    NSArray *beautyValues = @[@"0",@"2",@"6",@"5",@"0"];
    for (int i = 0; i < beautyValues.count; i++) {
        if (i == 0) continue;
        NSString * value = beautyValues[i];
        NSString *key = [NSString stringWithFormat:@"beauty_%d", i];
        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:key];
        [self handleBeautyWithType:i level:(value.integerValue/10.0)];
    }
}

@end
