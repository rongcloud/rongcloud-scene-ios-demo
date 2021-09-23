//
//  RCResult.m
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import "RCResult.h"

@interface RCResult()

@property (nonatomic, assign) RCResultType type;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError *error;

@end

@implementation RCResult

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _type = RCResultSuccess;
        _value = value;
    }
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    self = [super init];
    if (self) {
        _type = RCResultFailure;
        _error = error;
    }
    return self;
}

+ (RCResult *)success:(id)value {
    return [[RCResult alloc] initWithValue:value];
}

+ (RCResult *)failure:(NSError *)error {
    return [[RCResult alloc] initWithError:error];
}

- (id)value {
    NSAssert(_type == RCResultSuccess, @"Not a success. Check the result type. Contains an error: %@", _error);
    return _value;
}

- (NSError *)error {
    NSAssert(_type == RCResultFailure, @"Not a failure. Check the result type.");
    return _error;
}

@end
