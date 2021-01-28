# iOSANTPathMatching
OC for ANTPathMatching

## 使用
```
pod 'iOSANTPathMatching'
```

## 暂时只能识别单个表达式

```
/// ANT路径识别
/// @param pattern ANT风格表达式
/// @param path 判断的路径
/// @param fullMatch 是否完全匹配 默认yes
+(BOOL)doMatchPattern:(NSString*)pattern path:(NSString*)path fullMatch:(BOOL)fullMatch;
```
