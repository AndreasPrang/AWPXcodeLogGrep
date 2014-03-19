//
//  TextStorage.h
//  AWPXcodeLogGrep
//
//  Created by Andreas Prang on 29.12.13.
//  Copyright (c) 2013 iSolute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextStorage : NSTextStorage

// used to replace NSTextStorage's method
- (void)TextStorage:(NSRange)range;

@end
