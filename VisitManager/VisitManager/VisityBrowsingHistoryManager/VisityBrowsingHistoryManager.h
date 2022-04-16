//
//  VisityBrowsingHistoryManager.h
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVisityBrowsingHistoryModel.h"
#import "VisityBrowsingHistoryNode.h"

NS_ASSUME_NONNULL_BEGIN

/** 表头发生变化 */
extern NSString *const K_VisityBrowsingHistoryManager_didChange_listHead;
/** 表尾发生变化 */
extern NSString *const K_VisityBrowsingHistoryManager_didChange_listEnd;

@interface VisityBrowsingHistoryManager : BaseVisityBrowsingHistoryModel
/**
 * 初始化 history manager
 * 次初始化可以指定 单例的 最大缓存数量
 * 如果已有单例对象，再调用此函数，不能更改最大缓存
 * @param cacheMaxCount 最大缓存数
 */
+ (instancetype) createWithCacheMaxCount:(NSInteger)cacheMaxCount;

/**
 * 获取manager，如果没有单例实例对象，则创建一个缓存为 100 的单例实例对象
 */
+ (instancetype) manager;

/**
 * node cache
 * key: node的key
 * value: node
 */
+ (NSDictionary <NSString *,VisityBrowsingHistoryManager *>*)nodeCache;

/**
 * 表头
 * 表头实时变化，记录表头没有意义
 * 监听表头变动通知：K_VisityBrowsingHistoryManager_didChange_listHead
 */
- (VisityBrowsingHistoryNode * _Nullable) headNode;

/**
 * 表尾
 * 表尾实时变化，记录表头没有意义
 * 监听表头变动通知：K_VisityBrowsingHistoryManager_didChange_listEnd
 */
- (VisityBrowsingHistoryNode * _Nullable) endNode;

/**
 * 获取node
 */
- (VisityBrowsingHistoryNode * _Nullable) getNodeWithKey: (NSString *)key;

/**
 * 获取最大缓存个数
 */
- (NSInteger) getHistoryMaxCount;

/**
 * 浏览了 key
 */
- (void) visitWithKey: (NSString *)key;

/**
 * 删除某节点
 * @return 如果删除成功，则返回被删除的node
 */
- (VisityBrowsingHistoryNode * _Nullable) removeNodeWithKey:(NSString *)key;

- (void) removeNodeInRnage: (NSRange)range;

/**
 * 清除内存缓存
 */
- (void) clearMemoryCache;

/**
 * 清空内存与磁盘中的数据
 */
- (void) clearDiskAndMemoryCache;

/**
 * 保存到磁盘
 */
- (void) saveCacheToDisk;

/**
 * 检查这个key 是否合规
 * return: true：合规，false：不合规
 */
+ (void) config_checkKeyWithBlock:(BOOL(^)(NSString *key))block;

/**
 * 检查node是否合格
 */
+ (void) checkNodeIsQualifiedWithBlock: (BOOL(^)(VisityBrowsingHistoryNode *node))block;

/**
 * 强制检查各个node
 * 调用这个方法 会调用 checkNodeIsQualifiedWithBlock中的block
 */
- (void) checkNodesQualified;

/**
 * 检查当前key 是否有 有效的 node
 */
+ (BOOL) checkNodeIsQualifiedWithKey: (NSString *)key;
@end

NS_ASSUME_NONNULL_END
