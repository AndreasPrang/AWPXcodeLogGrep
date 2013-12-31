//
//  MethodSwizzler.h
//  SwizzelTest
//
//  Created by Andreas Prang @ Bild Digital on 27.04.13.
//  Copyright (c) 2013 TenStepsAhead UG. All rights reserved.

@interface MethodSwizzler : NSObject

+ (void)swizzleInstanceMethod:(SEL)firstSelector ofClass:(Class)firstClass withMethod:(SEL)secondSelector ofClass:(Class)secondClass;
+ (void)swizzleInstanceMethod:(SEL)firstSecector withMethod:(SEL)secondSelector ofClass:(Class)class;
+ (void)swizzleClassMethod:(SEL)firstSelector ofClass:(Class)firstClass withMethod:(SEL)secondSelector ofClass:(Class)secondClass;
+ (void)addInstanceMethod:(SEL)selector fromClass:(Class)firstClass toClass:(Class)secondClass;

@end
