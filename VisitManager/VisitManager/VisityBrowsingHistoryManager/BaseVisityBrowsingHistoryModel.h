//
//  BaseVisityBrowsingHistoryModel.h
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseVisityBrowsingHistoryModel : NSObject <NSCoding>
- (NSArray <NSString *>*)base_getCoderPropertys;
- (void)archiveDataWithFileName:(NSString *)fileName;
+ (instancetype)unarchiveDataWithFileName:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
