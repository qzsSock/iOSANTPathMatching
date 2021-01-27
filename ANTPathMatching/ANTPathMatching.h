//
//  ANTPathMatching.h
//  Procuratorate
//
//  Created by 邱子硕 on 2020/7/9.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANTPathMatching : NSObject
/// ANT路径识别
/// @param pattern ANT风格表达式
/// @param path 判断的路径
/// @param fullMatch 是否完全匹配 默认yes
+(BOOL)doMatchPattern:(NSString*)pattern path:(NSString*)path fullMatch:(BOOL)fullMatch;
@end

NS_ASSUME_NONNULL_END
