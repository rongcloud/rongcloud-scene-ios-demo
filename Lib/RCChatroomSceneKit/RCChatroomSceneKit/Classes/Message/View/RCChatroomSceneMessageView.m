//
//  RCChatroomSceneMessageView.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/27.
//

#import <Masonry/Masonry.h>

#import "RCChatroomSceneMessageView.h"

#import "RCChatroomSceneProtocol.h"
#import "RCChatroomSceneMessageCell.h"
#import "RCChatroomSceneVoiceMessageCell.h"
#import "RCChatroomSceneMessageViewConfig.h"

@interface RCChatroomSceneMessageView () <RCChatroomSceneEventProtocol, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<id<RCChatroomSceneMessageProtocol>> *messages;

@property (nonatomic, weak) id<RCChatroomSceneEventProtocol> eventDelegate;
@property (nonatomic, strong) RCChatroomSceneMessageViewConfig *config;

@end

@implementation RCChatroomSceneMessageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _config = [RCChatroomSceneMessageViewConfig default];
        [self addSubview:self.tableView];
        [self setupUI];
    }
    return self;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        [_tableView registerClass:[RCChatroomSceneMessageCell class]
           forCellReuseIdentifier:[RCChatroomSceneMessageCell cellIdentifier]];
        [_tableView registerClass:[RCChatroomSceneVoiceMessageCell class]
           forCellReuseIdentifier:[RCChatroomSceneVoiceMessageCell cellIdentifier]];
        _messages = [NSMutableArray array];
    }
    return _tableView;
}

- (void)setupUI {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(_config.contentInsets);
    }];
}

- (void)addMessage:(id<RCChatroomSceneMessageProtocol>)message {
    [self.messages addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    for (NSIndexPath *tmp in self.tableView.indexPathsForVisibleRows) {
        if (tmp.row < self.messages.count - 2) continue;
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
        break;
    }
}

- (void)setEventDelegate:(id<RCChatroomSceneEventProtocol>)eventDelegate {
    _eventDelegate = eventDelegate;
}


- (void)setMaxVisibleCount:(NSInteger)maxVisibleCount {
    NSInteger tmpCount = _config.maxVisibleCount;
    if (tmpCount <= maxVisibleCount) return;
    
    NSInteger count = tmpCount - maxVisibleCount;
    NSRange range = NSMakeRange(0, count);
    [self.messages removeObjectsInRange:range];
    
    NSMutableArray<NSIndexPath *> *indexPathes = [NSMutableArray<NSIndexPath *> array];
    for (NSInteger index = 0; index < count; index ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexPathes addObject:indexPath];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPathes
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - RCChatroomSceneEventProtocol -

- (void)cell:(UITableViewCell *)cell didClickEvent:(NSString *)event {
    if ([_eventDelegate respondsToSelector:@selector(cell:didClickEvent:)]) {
        [_eventDelegate cell:cell didClickEvent:event];
    }
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<RCChatroomSceneMessageProtocol> message = self.messages[indexPath.row];
    if ([message conformsToProtocol:@protocol(RCChatroomSceneVoiceMessage)]) {
        RCChatroomSceneVoiceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[RCChatroomSceneVoiceMessageCell cellIdentifier] forIndexPath:indexPath];
        return [cell update:message delegate:self config:_config];
    }
    if ([message conformsToProtocol:@protocol(RCChatroomSceneMessageProtocol)]) {
        RCChatroomSceneMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[RCChatroomSceneMessageCell cellIdentifier] forIndexPath:indexPath];
        return [cell update:message delegate:self config:_config];
    }
    return [[UITableViewCell alloc] init];
}

@end
