//
//  VisityBrowsingHistoryNode.m
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import "VisityBrowsingHistoryNode.h"
#import "VisityBrowsingHistoryManager.h"

@implementation VisityBrowsingHistoryNode
- (NSArray<NSString *> *)base_getCoderPropertys {
    return @[
        @"prevNodeKey",
        @"nextNodeKey",
        @"key",
        @"data",
        @"timeInterval"
    ];
}
/**
 * 获取左节点
 */
- (VisityBrowsingHistoryNode *)getPrevNode {
    return [[VisityBrowsingHistoryManager manager] getNodeWithKey:self.prevNodeKey];
}

/**
 * 获取左节点
 */
- (VisityBrowsingHistoryNode *)getNextNode {
    return [[VisityBrowsingHistoryManager manager] getNodeWithKey:self.nextNodeKey];
}

- (BOOL) isEqualToNode: (VisityBrowsingHistoryNode *)node {
    return [self.key isEqualToString:node.key];
}
@end
