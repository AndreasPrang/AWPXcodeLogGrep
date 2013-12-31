//
//  MethodSwizzler.m
//  SwizzelTest
//
//  Created by Andreas Prang @ Bild Digital on 27.04.13.
//  Copyright (c) 2013 TenStepsAhead UG. All rights reserved.

#import "objc/runtime.h"

#import "MethodSwizzler.h"
#import <objc/runtime.h>

@implementation MethodSwizzler

+ (void)swizzleInstanceMethod:(SEL)firstSelector ofClass:(Class)firstClass withMethod:(SEL)secondSelector ofClass:(Class)secondClass;
{
    Method firstMethod = class_getInstanceMethod(firstClass, firstSelector);
    Method secondMethod = class_getInstanceMethod(secondClass, secondSelector);

	XLog(@"REPLACE: %p", firstMethod);
	XLog(@"with");
	XLog(@"%p", secondMethod);

	if (class_addMethod(firstClass, firstSelector, method_getImplementation(secondMethod), method_getTypeEncoding(secondMethod)))
	{
		XLog(@"class_addMethod");
//		class_replaceMethod(firstClass, secondSelector, method_getImplementation(firstMethod), method_getTypeEncoding(firstMethod));
	}
	else
	{
		XLog(@"method_exchangeImplementations");
		method_exchangeImplementations(firstMethod, secondMethod);
	}
}

+ (void)swizzleInstanceMethod:(SEL)firstSecector withMethod:(SEL)secondSelector ofClass:(Class)class;
{
    Method firstMethod = class_getClassMethod(class, firstSecector);
    Method secondMethod = class_getClassMethod(class, secondSelector);
	
    class = object_getClass((id)class);
	
    if (class_addMethod(class, firstSecector, method_getImplementation(secondMethod), method_getTypeEncoding(secondMethod)))
    {
        class_replaceMethod(class, secondSelector, method_getImplementation(firstMethod), method_getTypeEncoding(firstMethod));
    }
    else
    {
        method_exchangeImplementations(firstMethod, secondMethod);
    }
}

+ (void)swizzleClassMethod:(SEL)firstSelector ofClass:(Class)firstClass withMethod:(SEL)secondSelector ofClass:(Class)secondClass;
{
    Method firstMethod = class_getClassMethod(firstClass, firstSelector);
    Method secondMethod = class_getClassMethod(secondClass, secondSelector);

    if (class_addMethod(firstClass, firstSelector, method_getImplementation(secondMethod), method_getTypeEncoding(secondMethod)))
	{
		class_replaceMethod(firstClass, secondSelector, method_getImplementation(firstMethod), method_getTypeEncoding(firstMethod));
	}
	else
	{
		method_exchangeImplementations(firstMethod, secondMethod);
	}
}

+ (void)addInstanceMethod:(SEL)selector fromClass:(Class)firstClass toClass:(Class)secondClass;
{
    Method newMethod = class_getInstanceMethod(firstClass, selector);

    class_addMethod(secondClass, selector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
}

@end
