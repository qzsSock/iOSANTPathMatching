//
//  ANTPathMatching.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/7/9.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "ANTPathMatching.h"

static  NSString*pathSeparator = @"/";

@implementation ANTPathMatching


+ (BOOL)doMatchPattern:(NSString*)pattern path:(NSString*)path fullMatch:(BOOL)fullMatch
{
    
    if ([pattern isEqualToString:@"*"]) {
        return YES;
    }
    
    if ([path hasPrefix:pathSeparator] !=  [pattern hasPrefix:pathSeparator]) {
       return NO;
    }

    NSArray *pattDirs = [pattern componentsSeparatedByString:pathSeparator];
    NSArray *pathDirs = [path componentsSeparatedByString:pathSeparator];


    NSInteger pattIdxStart = 0;
    NSInteger pattIdxEnd = pattDirs.count - 1;
    NSInteger pathIdxStart = 0;
    NSInteger pathIdxEnd = pathDirs.count - 1;


    // Match all elements up to the first **
    while (pattIdxStart <= pattIdxEnd && pathIdxStart <= pathIdxEnd)
    {
        NSString* patDir = pattDirs[pattIdxStart];

        if ([@"**" isEqualToString:patDir]) {
            break;
        }

        if (![self matchStrings:patDir str:pathDirs[pathIdxStart]]) {
            return NO;
        }
        pattIdxStart++;
        pathIdxStart++;
        
    }


    if (pathIdxStart > pathIdxEnd) {
         // Path is exhausted, only match if rest of pattern is * or **'s
         if (pattIdxStart > pattIdxEnd)
         {
              
             return ( [pattern hasSuffix:pathSeparator] ?
                     [path hasSuffix:pathSeparator] :![path hasSuffix:pathSeparator]);
         }
         if (!fullMatch) {
             return YES;
         }
        
        if (pattIdxStart == pattIdxEnd && [pattDirs[pattIdxStart] isEqualToString:@"*"] && [path hasSuffix:pathSeparator]) {
             return true;
        }
        
        for (NSInteger i = pattIdxStart; i < pattIdxEnd; ++i) {
            if (![pattDirs[i] isEqualToString:@"**"]) {
                return NO;
            }
           
        }
        
         return YES;
     } else if (pattIdxStart > pattIdxEnd)
     {
         // String not exhausted, but pattern is. Failure.
         return NO;
      
     } else if (!fullMatch && [@"" isEqualToString:pattDirs[pattIdxStart]])
     {
         // Path start definitely matches due to "**" part in pattern.
         return YES;
     }
    
    
        // up to last '**'
        while (pattIdxStart <= pattIdxEnd && pathIdxStart <= pathIdxEnd) {
        NSString* patDir = pattDirs[pattIdxEnd];
            
        if ([patDir isEqualToString:@"**"])
        {
           break;
        }
            
        if (![self matchStrings:patDir str:pathDirs[pathIdxEnd]])
        {
           return NO;
        }
        pattIdxEnd--;
        pathIdxEnd--;
        }
        if (pathIdxStart > pathIdxEnd) {
        // String is exhausted
        for (NSInteger i = pattIdxStart; i <= pattIdxEnd; i++)
        {
           
           if (! [pattDirs[i] isEqualToString:@"**"]) {
               return NO;
           }
        }
        return YES;
        }
    
    while (pattIdxStart != pattIdxEnd && pathIdxStart <= pathIdxEnd) {
               NSInteger patIdxTmp = -1;
               for (NSInteger i = pattIdxStart + 1; i <= pattIdxEnd; i++)
               {
                   
                   if ([pattDirs[i] isEqualToString:@"**"])
                   {
                       patIdxTmp = i;
                       break;
                   }
               }
               if (patIdxTmp == pattIdxStart + 1) {
                   // '**/**' situation, so skip one
                   pattIdxStart++;
                   continue;
               }
               // Find the pattern between padIdxStart & padIdxTmp in str between
               // strIdxStart & strIdxEnd
               NSInteger patLength = (patIdxTmp - pattIdxStart - 1);
               NSInteger strLength = (pathIdxEnd - pathIdxStart + 1);
               NSInteger foundIdx = -1;

               strLoop:
               for (int i = 0; i <= strLength - patLength; i++)
                {
                   for (int j = 0; j < patLength; j++) {
                       NSString*subPat = (NSString*) pattDirs[pattIdxStart + j + 1];
                       NSString* subStr = (NSString*) pathDirs[pathIdxStart + i + j];
                       
                       if (![self matchStrings:subPat str:subStr]) {
                           goto  strLoop;
                       }
                   }
                   foundIdx = pathIdxStart + i;
                   break;
               }

               if (foundIdx == -1) {
                   return NO;
               }

               pattIdxStart = patIdxTmp;
               pathIdxStart = foundIdx + patLength;
           }

    for (int i = pattIdxStart; i <= pattIdxEnd; i++)
    {
        
        if (![pattDirs[i] isEqualToString:@"**"]) {
            return NO;
        }
    }

    return YES;
}



+ (BOOL)matchStrings:(NSString*)pattern  str:(NSString*)str
{
    
    unsigned char patArr[pattern.length];
    memcpy(patArr, [pattern cStringUsingEncoding:NSUTF8StringEncoding], pattern.length);
    
    
    unsigned char strArr[str.length];
       memcpy(strArr, [str cStringUsingEncoding:NSUTF8StringEncoding], str.length);
    
        NSInteger patIdxStart = 0;
        NSInteger patIdxEnd = sizeof(patArr) - 1;
        NSInteger strIdxStart = 0;
        NSInteger strIdxEnd = sizeof(strArr) - 1;
        char ch;

        BOOL containsStar = NO;
        
    for (int i = 0; i < sizeof(patArr); i++) {
       
        if ( patArr[i] == '*') {
           containsStar = true;
           break;
        }
        
    }
    
    
        if (!containsStar) {
            // No '*'s, so we make a shortcut
            if (patIdxEnd != strIdxEnd) {
                return NO; // Pattern and string do not have the same size
            }
            for (int i = 0; i <= patIdxEnd; i++) {
                ch = patArr[i];
                if (ch != '?') {
                    if (ch != strArr[i]) {
                        return NO;// Character mismatch
                    }
                }
            }
            return YES; // String matches against pattern
        }


        if (patIdxEnd == 0) {
            return YES; // Pattern contains only '*', which matches anything
        }

        // Process characters before first star 先找到不是*的位置开始，进行原始的比较
        while ((ch = patArr[patIdxStart]) != '*' && strIdxStart <= strIdxEnd) {
            if (ch != '?') {
                if (ch != strArr[strIdxStart]) {
                    return NO;// Character mismatch
                }
            }
            patIdxStart++;
            strIdxStart++;
        }
        if (strIdxStart > strIdxEnd) {
            // All characters in the string are used. Check if only '*'s are
            // left in the pattern. If so, we succeeded. Otherwise failure.
            for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
                if (patArr[i] != '*') {
                    return NO;
                }
            }
            return YES;
        }

        // Process characters after last star
        while ((ch = patArr[patIdxEnd]) != '*' && strIdxStart <= strIdxEnd) {
            if (ch != '?') {
                if (ch != strArr[strIdxEnd]) {
                    return NO;// Character mismatch
                }
            }
            patIdxEnd--;
            strIdxEnd--;
        }
        if (strIdxStart > strIdxEnd) {
            // All characters in the string are used. Check if only '*'s are
            // left in the pattern. If so, we succeeded. Otherwise failure.
            for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
                if (patArr[i] != '*') {
                    return NO;
                }
            }
            return YES;
        }

        // process pattern between stars. padIdxStart and patIdxEnd point
        // always to a '*'.
        while (patIdxStart != patIdxEnd && strIdxStart <= strIdxEnd) {
            NSInteger patIdxTmp = -1;
            for (NSInteger i = patIdxStart + 1; i <= patIdxEnd; i++) {
                if (patArr[i] == '*') {
                    patIdxTmp = i;
                    break;
                }
            }
            if (patIdxTmp == patIdxStart + 1) {
                // Two stars next to each other, skip the first one.
                patIdxStart++;
                continue;
            }
            // Find the pattern between padIdxStart & padIdxTmp in str between
            // strIdxStart & strIdxEnd
             // Find the pattern between padIdxStart & padIdxTmp in str between
                       // strIdxStart & strIdxEnd
           NSInteger patLength = (patIdxTmp - patIdxStart - 1);
           NSInteger strLength = (strIdxEnd - strIdxStart + 1);
           NSInteger foundIdx = -1;
           
         strLoop:  for (NSInteger i = 0; i <= (strLength - patLength); i++)
           {
               for (NSInteger j = 0; j < patLength; j++)
               {
                   ch = patArr[patIdxStart + j + 1];
                   if (ch != '?') {
                       if (ch != strArr[strIdxStart + i + j]) {
                           goto strLoop;
                       }
                   }
               }

               foundIdx = strIdxStart + i;
               break;
           }
            
            if (foundIdx == -1) {
                return NO;
            }

            patIdxStart = patIdxTmp;
            strIdxStart = foundIdx + patLength;
        }

        // All characters in the string are used. Check if only '*'s are left
        // in the pattern. If so, we succeeded. Otherwise failure.
        for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
            if (patArr[i] != '*') {
                return NO;
            }
        }

        return true;
    
}


@end
