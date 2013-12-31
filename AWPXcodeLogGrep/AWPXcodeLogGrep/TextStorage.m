//
//  TextStorage.m
//  AWPXcodeLogGrep
//
//  Created by Andreas Prang on 29.12.13.
//  Copyright (c) 2013 iSolute. All rights reserved.
//

#import "TextStorage.h"

@implementation TextStorage

- (void)fixAttributesInRange:(NSRange)range
{
//    originalFixAttributesInRange(self, _cmd, range);
//    
//    NSString *className = NSStringFromClass([self class]);
//    MXLog(@"fixAttributesInRange[%@]", className);
//    // it must not a console textstorage.
//    if (![className isEqualToString:@"DVTFoldingTextStorage"]
//        && ![className isEqualToString:@"DVTTextStorage"]) {
//        return ;
//    }
//	
//    XLog_Console *console = getConsole(self);
//    if (console != nil && console.lastStrlen != [self length]) {   // this is a console textStorage and text changed
//        if (XLogInstance.defaultAttrs == nil) {  // save default text attr at first time
//            XLogInstance.defaultAttrs = [self attributesAtIndex:0 effectiveRange:NULL];
//        }
//        console.lastStrlen = [self length];
//        parse(console, range);
//    }
//    
//    // self is new, test it. Only need test DVTFoldingTextStorage
//    if (console == nil && [className isEqualToString:@"DVTTextStorage"]) {
//        testTextStorage(self);
//    }
}

@end
