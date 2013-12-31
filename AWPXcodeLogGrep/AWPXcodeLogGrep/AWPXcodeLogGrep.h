//
//  AWPXcodeLogGrep.h
//  AWPXcodeLogGrep
//
//  Created by Prang, Andreas on 5/8/12.
//  Copyright (c) 2012 iSolute-Berlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ConfigWindowController.h"

@interface AWPXcodeLogGrep : NSObject <NSTokenFieldDelegate>

@property (nonatomic, strong) NSSearchField *searchField;
//@property (nonatomic, strong) NSTokenField *searchTokenField;

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic) __block NSUInteger currentSearStarts;

@property (nonatomic, strong) ConfigWindowController *configWindowController;

- (void)proceedGrep;
- (void)proceedGrepInRange:(NSRange)range;

@end
