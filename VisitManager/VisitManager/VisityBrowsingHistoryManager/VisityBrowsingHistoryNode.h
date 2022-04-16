//
//  VisityBrowsingHistoryNode.h
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVisityBrowsingHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VisityBrowsingHistoryNode : BaseVisityBrowsingHistoryModel
/**
 * 左节点的key
 */
@property (nonatomic,copy,nullable) NSString *prevNodeKey;
/**
 * 右节点的key
 */
@property (nonatomic,copy,nullable) NSString * nextNodeKey;
/**
 * 当前节点的key
 */
@property (nonatomic,copy) NSString *key;
/**
 * 携带的数据
 */
@property (nonatomic,copy) id data;

/**
 * 最近更新的时间 单位：秒
 */
@property (nonatomic,assign) NSTimeInterval timeInterval;

/**
 * 获取左节点
 */
- (VisityBrowsingHistoryNode * _Nullable)getPrevNode;

/**
 * 获取左节点
 */
- (VisityBrowsingHistoryNode * _Nullable)getNextNode;

- (BOOL) isEqualToNode: (VisityBrowsingHistoryNode *)node;
@end

NS_ASSUME_NONNULL_END
