//
//  RCMusicPlayingLayer.m
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import "RCMusicPlayingLayer.h"

@interface RCMusicPlayingLayer ()
@property (nonatomic, strong) CALayer *layer1;
@property (nonatomic, strong) CALayer *layer2;
@property (nonatomic, strong) CALayer *layer3;
@property (nonatomic, strong) CALayer *layer4;
@end

@implementation RCMusicPlayingLayer

- (instancetype)init {
    if (self = [super init]) {
        self.masksToBounds = YES;
        self.layer1 = [[CALayer alloc] init];
        self.layer2 = [[CALayer alloc] init];
        self.layer3 = [[CALayer alloc] init];
        self.layer4 = [[CALayer alloc] init];
        
        [self addSublayer:self.layer1];
        [self addSublayer:self.layer2];
        [self addSublayer:self.layer3];
        [self addSublayer:self.layer4];
        
        self.layer1.backgroundColor = [UIColor redColor].CGColor;
        self.layer2.backgroundColor = [UIColor redColor].CGColor;
        self.layer3.backgroundColor = [UIColor redColor].CGColor;
        self.layer4.backgroundColor = [UIColor redColor].CGColor;
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    [self updateLayers];
}

- (void)updateLayers {
    if (self.bounds.size.width <= 0) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGFloat lineWidth = 2;
    CGFloat xSpace = (self.bounds.size.width - lineWidth) / 3.0;
    self.layer1.frame = CGRectMake(xSpace * 0, self.bounds.size.height, lineWidth, self.bounds.size.height);
    self.layer2.frame = CGRectMake(xSpace * 1, self.bounds.size.height, lineWidth, self.bounds.size.height);
    self.layer3.frame = CGRectMake(xSpace * 2, self.bounds.size.height, lineWidth, self.bounds.size.height);
    self.layer4.frame = CGRectMake(xSpace * 3, self.bounds.size.height, lineWidth, self.bounds.size.height);
    [CATransaction commit];
}

- (void)startAnimation {
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animation];
    animation1.keyPath = @"position.y";
    animation1.keyTimes = @[@0,@0.5,@1.0];
    animation1.values = @[@12,@30,@12];
    animation1.duration = 1.0;
    animation1.repeatCount = MAXFLOAT;
    animation1.removedOnCompletion = NO;
    
    [self.layer1 addAnimation:animation1 forKey:@"animation"];
    
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animation];
    animation2.keyPath = @"position.y";
    animation2.keyTimes = @[@0,@0.5,@1.0];
    animation2.values = @[@28,@18,@28];
    animation2.duration = 1.0;
    animation2.repeatCount = MAXFLOAT;
    animation2.removedOnCompletion = NO;
    
    animation2.timeOffset = 0.2;
    [self.layer2 addAnimation:animation2 forKey:@"animation"];
    
    CAKeyframeAnimation *animation3 = animation1;
    animation3.timeOffset = 0.4;
    [self.layer3 addAnimation:animation3 forKey:@"animation"];
    
    CAKeyframeAnimation *animation4 = animation2;
    animation4.timeOffset = 0.6;
    [self.layer4 addAnimation:animation4 forKey:@"animation"];
    
}

- (void)stopAnimation {
    [self.layer1 removeAllAnimations];
    [self.layer2 removeAllAnimations];
    [self.layer3 removeAllAnimations];
    [self.layer4 removeAllAnimations];
}

@end
