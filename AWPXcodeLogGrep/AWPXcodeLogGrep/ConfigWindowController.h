//
//  ConfigWindowController.h
//  AWPXcodeLogGrep
//
//  Created by Andreas Prang on 29.12.13.
//  Copyright (c) 2013 iSolute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfigWindowController : NSWindowController <NSWindowDelegate>

@property (assign) IBOutlet NSTextField *previewTextField;

@property (assign) IBOutlet NSButton *linesWithResultsButton;
@property (assign) IBOutlet NSButton *linesWithoutResultsButton;
@property (assign) IBOutlet NSButton *searchStringResultsButton;
@property (assign) IBOutlet NSButton *hideLinesWithoutResultsButton;

- (NSFont *)lineWithResultsFont;
- (NSFont *)lineWithoutResultsFont;
- (NSFont *)searchStringResultsFont;

- (NSColor *)lineWithResultsColor;
- (NSColor *)lineWithoutResultsColor;
- (NSColor *)searchStringResultsColor;
- (IBAction)hideLinesWithoutResultsButtonUp:(NSButton *)sender;
- (BOOL)linesWithoutResultsHidden;

@end
