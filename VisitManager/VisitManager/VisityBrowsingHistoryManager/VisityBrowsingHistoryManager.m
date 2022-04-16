//
//  VisityBrowsingHistoryManager.m
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import "VisityBrowsingHistoryManager.h"

static NSInteger const int_VisityBrowsingHistoryManagerMaxCount = 100;

NSString *const K_VisityBrowsingHistoryManager_didChange_headNode = @"K_VisityBrowsingHistoryManager_didChange_headNode";
NSString *const K_VisityBrowsingHistoryManager_didChange_endNode = @"K_VisityBrowsingHistoryManager_didChange_endNode";

static NSString *const K_VisityBrowsingHistoryManager_filePath = @"K_VisityBrowsingHistoryManager_filePath";


@interface VisityBrowsingHistoryManager()
@property (nonatomic,assign) NSInteger base_cacheMaxCount;
@property (nonatomic,strong) NSMutableDictionary <NSString *,VisityBrowsingHistoryNode *>* base_cacheDicM;

@property (nonatomic,copy) BOOL(^base_checkKeyBlock)(NSString *key);
@property (nonatomic,copy) BOOL(^base_checkNodeBlock)(VisityBrowsingHistoryNode *node);
@property (nonatomic,strong) VisityBrowsingHistoryNode *base_headNode;
@property (nonatomic,strong) VisityBrowsingHistoryNode *base_endNode;

@end

@implementation VisityBrowsingHistoryManager

+ (instancetype) createWithCacheMaxCount:(NSInteger)cacheMaxCount {
    static VisityBrowsingHistoryManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self unarchiveDataWithFileName:K_VisityBrowsingHistoryManager_filePath];
        if (!manager) {
            manager = [[self alloc]init];
        }
        [manager registerNodificationCenter];
        manager.base_cacheMaxCount = cacheMaxCount;
    });
    return manager;
}

+ (instancetype) manager {
    return [self createWithCacheMaxCount:int_VisityBrowsingHistoryManagerMaxCount];
}

// MARK: - get datas
/**
 * node cache
 * key: node的key
 * value: node
 */
+ (NSDictionary <NSString *,VisityBrowsingHistoryManager *>*)nodeCache {
    return [[self manager] base_cacheDicM].copy;
}

/**
 * 表头
 * 表头实时变化，记录表头没有意义
 * 监听表头变动通知：K_VisityBrowsingHistoryManager_didChange_headNode
 */
- (VisityBrowsingHistoryNode * _Nullable) headNode {
    return self.base_headNode;
}

/**
 * 表尾
 * 表尾实时变化，记录表头没有意义
 * 监听表头变动通知：K_VisityBrowsingHistoryManager_didChange_endNode
 */
- (VisityBrowsingHistoryNode * _Nullable) endNode {
    return self.base_endNode;
}

/**
 * 获取node
 */
- (VisityBrowsingHistoryNode * _Nullable) getNodeWithKey: (NSString *)key {
    NSString *keyCopy = key.copy;
    if ([self base_errorWithKey:key]) {
        return nil;
    }
    return self.base_cacheDicM[keyCopy];
}

/**
 * 获取最大缓存个数
 */
- (NSInteger) getHistoryMaxCount {
    return self.base_cacheMaxCount;
}

/**
 * 浏览了 key
 */
- (void) visitWithKey: (NSString *)key {
    [self base_appendNodeIfNeeded:key];
}

// MARK: - data
- (void) base_appendNodeIfNeeded:(NSString *)key {
    if (self.base_cacheMaxCount <= 0) {
        [self clearMemoryCache];
        return;
    }
    
    NSString *keyCopy = key.copy;
    if ([self base_errorWithKey:key]) {
        return;
    }
    
    VisityBrowsingHistoryNode *node = self.base_cacheDicM[keyCopy];
    
    if ([node isEqualToNode:self.endNode]){
        return;
    }
    
    if (node) {
        [self removeNodeWithKey:keyCopy];
    }else{
        node = [[VisityBrowsingHistoryNode alloc]init];
        node.key = key;
    }
    node.timeInterval = (long long)[[NSDate date] timeIntervalSince1970];
    [self base_appendNode:node];
}

- (void) base_appendNode:(VisityBrowsingHistoryNode *)node {
    
    if (self.base_cacheMaxCount <= 0) {
        [self clearMemoryCache];
        return;
    }
    
    NSString *key = node.key.copy;
    if ([self base_errorWithKey:key]) {
        return;
    }
    
    NSInteger overflowCount = MAX(0,self.base_cacheDicM.count + 1 - self.base_cacheMaxCount);
    if (overflowCount > 0) {
        [self removeNodeInRnage:NSMakeRange(0, overflowCount)];
    }
    
    self.base_cacheDicM[key] = node;
    self.base_endNode.nextNodeKey = node.key;
    node.prevNodeKey = self.base_endNode.key;
    self.base_endNode = node;
    
    if (self.base_cacheDicM.count == 1) {
        self.base_headNode = node;
        self.base_endNode = node;
    }
}

- (void) base_removeFirstNode {
    VisityBrowsingHistoryNode *node = [self removeNodeWithKey:self.base_headNode.key];
    self.base_headNode = node.getNextNode;
    self.base_headNode.prevNodeKey = nil;
}

- (void) removeNodeInRnage: (NSRange)range {
    if (range.length <= 0) {
        return;
    }
    NSInteger count = self.base_cacheDicM.count;
    VisityBrowsingHistoryNode *node = self.headNode;
    NSInteger rightOverFlowIndex = range.location + range.length;
    
    for (int i = 0; i < count; i ++) {
        if(i >= range.location && i < rightOverFlowIndex) {
            [self removeNodeWithKey:node.key];
        }
        node = node.getNextNode;
        if (i >= rightOverFlowIndex) {
            break;
        }
    }
}

- (VisityBrowsingHistoryNode *) removeNodeWithKey:(NSString *)key {
    
    NSString *keyCopy = key;
    if ([self base_errorWithKey:keyCopy]) {
        return nil;
    }
    
    VisityBrowsingHistoryNode *node =  [self getNodeWithKey:keyCopy];
    VisityBrowsingHistoryNode *prevNode = node.getPrevNode;
    VisityBrowsingHistoryNode *nextNode = node.getNextNode;
    
    prevNode.nextNodeKey = nextNode.key;
    nextNode.prevNodeKey = prevNode.key;
    
    if ([node.key isEqualToString:self.base_headNode.key]) {
        self.base_headNode = nextNode;
    }
    
    [self.base_cacheDicM removeObjectForKey:keyCopy];

    if (self.base_cacheDicM.count <= 0) {
        [self clearMemoryCache];
    }
    return node;
}

- (void) clearMemoryCache {
    self.base_headNode = nil;
    self.base_endNode = nil;
    [self.base_cacheDicM removeAllObjects];
}

- (void) clearDiskAndMemoryCache {
    [self clearMemoryCache];
    [self saveCacheToDisk];
}

- (void) saveCacheToDisk; {
    [self archiveDataWithFileName:K_VisityBrowsingHistoryManager_filePath];
}

- (void)setBase_endNode:(VisityBrowsingHistoryNode *)base_endNode {
    _base_endNode = base_endNode;
    _base_endNode.nextNodeKey = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:K_VisityBrowsingHistoryManager_didChange_endNode object:nil];
}

- (void)setBase_headNode:(VisityBrowsingHistoryNode *)base_headNode {
    _base_headNode = base_headNode;
    _base_headNode.prevNodeKey = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:K_VisityBrowsingHistoryManager_didChange_headNode object:nil];
}

// MARK: check
/**
 * 检查这个key 是否合规
 */
+ (void) config_checkKeyWithBlock:(BOOL(^)(NSString *key))block {
    [[self manager] setBase_checkKeyBlock: block];
}

- (BOOL) base_errorWithKey: (NSString *)key {
    NSString *keyCopy = key;
    if ([self base_checkKeyBlock] && !self.base_checkKeyBlock(keyCopy)) {
        return true;
    }
    if(keyCopy.length == 0) {
        return true;
    }
    return false;
}

+ (void) checkNodeIsQualifiedWithBlock: (BOOL(^)(VisityBrowsingHistoryNode *node))block {
    [[self manager] setBase_checkNodeBlock: block];
    [[self manager] checkNodesQualified];
}

- (void) checkNodesQualified {
   // 随意找一个 node
    __block VisityBrowsingHistoryNode *node;
    [[self base_cacheDicM] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VisityBrowsingHistoryNode * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:VisityBrowsingHistoryNode.class]) {
            return;
        }
        node = obj;
        *stop = true;
    }];
    
    if (!node) {
        // 没有找到node 说明 字典为空
        return;
    }
    // 判断node是否合格
    BOOL isQualified =  [self checkWithNode:node];
    if (!isQualified) {
        [self removeNodeWithKey:node.key];
    }

    // 判断node 的左右node是否合格 并循环
    VisityBrowsingHistoryNode *prevNode = node.getPrevNode;
    VisityBrowsingHistoryNode *nextNode = node.getNextNode;
    BOOL isQualified_prevNode = false;
    BOOL isQualified_nextNode = false;
    
    do {
        
        isQualified_prevNode = [self checkWithNode:prevNode];
        isQualified_nextNode = [self checkWithNode:nextNode];
        
        if(!isQualified_prevNode){
            [self removeNodeWithKey:prevNode.key];
        }
        if(!isQualified_nextNode){
            [self removeNodeWithKey:nextNode.key];
        }
        
        prevNode = prevNode.getPrevNode;
        nextNode = nextNode.getNextNode;
        
    } while ((nextNode || prevNode) && ![prevNode isEqualToNode:nextNode]);
    
}

+ (BOOL) checkNodeIsQualifiedWithKey: (NSString *)key {
    return [[self manager]getNodeWithKey:key] != nil;
}

- (BOOL) checkWithNode: (VisityBrowsingHistoryNode *)node {
    if (node.key.length == 0) {
        return false;
    }
    if (self.base_checkNodeBlock){
        return self.base_checkNodeBlock(node);
    }
    return true;
}

// MARK: - setter && getter
- (NSMutableDictionary<NSString *,VisityBrowsingHistoryNode *> *)base_cacheDicM {
    if (!_base_cacheDicM) {
        _base_cacheDicM = [NSMutableDictionary dictionary];
    }
    return _base_cacheDicM;
}

// MARK: 通知监听
- (void) registerNodificationCenter {
    //  - 添加通知的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

// - 事件处理
/** 程序进入后台的通知的事件监听 */
-(void)appEnterBackground{
    [[VisityBrowsingHistoryManager manager] saveCacheToDisk];
    NSLog(@"✅- 后台");
}
/** 程序被杀死 */
-(void)applicationWillTerminate{
    //  - 监听到 app 被杀死时候的回调....
    NSLog(@"✅- 被杀死");
}

// MARK: - codeing
- (NSArray <NSString *>*) base_getCoderPropertys {
    return @[
        @"base_headNode",
        @"base_endNode",
        @"base_cacheDicM"
    ];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [[self base_getCoderPropertys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = obj;
            if (key && [aDecoder decodeObjectForKey:key]) {
                [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
            }
        }];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [[self base_getCoderPropertys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        if (key) {
            [aCoder encodeObject:[self valueForKey:key] forKey:key];
        }
    }];
}
@end
