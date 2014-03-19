//
//  AWPXcodeLogGrep.m
//  AWPXcodeLogGrep
//
//  Created by Prang, Andreas on 5/8/12.
//  Copyright (c) 2012 iSolute-Berlin. All rights reserved.
//

#import "AWPXcodeLogGrep.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MethodSwizzler.h"

static AWPXcodeLogGrep *sharedPlugin = nil;

@implementation AWPXcodeLogGrep

+ (void) pluginDidLoad:(NSBundle*) bundle {
	
	static dispatch_once_t once;
	dispatch_once(&once, ^{

        // Reset UserDefaults
//		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
		sharedPlugin = [[self alloc] init];
	});
	
	XLog(@"pluginDidLoad:");
}

+ (void)load
{
	XLog(@"load");
}

- (id)init {
	if (self = [super init])
	{
		[MethodSwizzler swizzleInstanceMethod:@selector(fixAttributesInRange:)
									  ofClass:[NSTextStorage class]
								   withMethod:@selector(fixAttributesInRange:)
									  ofClass:[AWPXcodeLogGrep class]];

		self.configWindowController = [[ConfigWindowController alloc] initWithWindowNibName:@"ConfigWindowController"];
	}
	
	return self;
}


- (BOOL) testTextStorage:(NSTextStorage *)textStorage
{
    id textView = nil;
    // MXLog(@"%@, %lx", NSStringFromClass([textStorage class]), (long)textStorage);
    // is NSTextStorage instance
	if ([textStorage respondsToSelector:@selector(layoutManagers)])
	{
		id layoutManagers = [(NSTextStorage*)textStorage layoutManagers];
		XLog(@"%@", layoutManagers);
		if ([layoutManagers count])
		{
			id layoutManager = [layoutManagers objectAtIndex:0];
			if ([layoutManager respondsToSelector:@selector(firstTextView)])
				textView = [layoutManager firstTextView];
		}
	}
	XLog(@"0");

    // this textstorage hasn't NSTextView, return
    if (textView == nil) return NO;
	XLog(@"1");
    // textView is not console textView, return
    if (![NSStringFromClass([textView class]) isEqualToString:@"IDEConsoleTextView"]) return NO;
	XLog(@"2");
    // try to find console NSTextView and toolbar View's commom parent. (Hardcode: I found it was NSView)
    NSView *pView = textView;
    while (pView != nil && ![NSStringFromClass([pView class]) isEqualToString:@"NSView"]) {
        // MXLog(@"pView class:[%@]", NSStringFromClass([pView class]));
        pView = pView.superview;
    }
    if (pView == nil) { // pView should not be nil. or the Xcode's UI changes. Fix it in other Xcode versions.
        XLog(@"FIXME: Cannot find NSView in the hierarchy!");
        return NO;
    }
	XLog(@"3");

    //-- find toolbar view
    NSView *toolbarView = nil;
    for (int i = 0; i != [pView.subviews count]; ++i) {
        NSView *tmp = [pView.subviews objectAtIndex:i];
        if ([NSStringFromClass([tmp class]) isEqualToString:@"DVTScopeBarView"]) {
            toolbarView = tmp;
            break;
        }
    }
    if (toolbarView == nil) {
        XLog(@"FIXME: Cannot find toolbar view!");
        return NO;
    }
	XLog(@"4");

    //-- find Output PopUpButton. add customized views after it.
    NSPopUpButton *outputPopUpButton = nil;
    for (int i = 0; i != [toolbarView.subviews count]; ++i) {
        NSView *tmp = [toolbarView.subviews objectAtIndex:i];
        if ([NSStringFromClass([tmp class]) isEqualToString:@"NSPopUpButton"]) {
            outputPopUpButton = (NSPopUpButton *)tmp;
            break;
        }
    }
    if (outputPopUpButton == nil) {
        XLog(@"FIXME: Cannot find output popup button");
        return NO;
    }
	XLog(@"5");

    //-- almost done. now we find all views we need. BUT the textStorage is not!!
    /*
     * The textStorage is a DVTFoldTextStorage, you can dump it to see some detail.
     *  I found that change the textStorage's attrs not work for the console.
     *  But there is a "realTextStorage" member in the DVTFoldTextStorage, that is exactly what we want.
     *  How to get it? HARDCODE! It's OK in Xcode4.3.2, maybe crash in other versions. Fix it!
     */
    NSTextStorage *realTextStorage = nil;
    NSString *classInfo = [NSString stringWithFormat:@"%@", textStorage];
    // MXLog(@"textStorage info:[%@]", classInfo);
    NSRange r = [classInfo rangeOfString:@"realTextStorage: <DVTTextStorage: "];
    if (r.length > 0) { // find
        unsigned long long addr;
        NSScanner *scanner = [NSScanner scannerWithString:[classInfo substringFromIndex:r.location + r.length]];
        [scanner scanHexLongLong:&addr];
        if (addr > 0) {
            realTextStorage = (NSTextStorage *)addr;
            XLog(@"Reset console textstorage:[%@]", realTextStorage);
        }
    }
    
    if (realTextStorage == nil) {
        realTextStorage = textStorage;
    }
    
	self.textStorage = textStorage;
	
//    XLog_Console *console = [[XLog_Console alloc] init];
//    console.realTextStorage = realTextStorage;
//    console.textView = textView;
//    console.lastStrlen = 0;
//    console.lastSearchText = nil;
//    console.lastLogLevel = 0;
    [self addCustomizedViews:outputPopUpButton textStorage:textStorage];
//    // add to map
//    [consoleTextStorageMap setObject:console forKey:hash(textStorage)]; // add textStorage to prevent multipule init console
//    [consoleTextStorageMap setObject:console forKey:hash(realTextStorage)]; // add realTextStorage to parse it.
//    // MXLog(@"%ld , %ld", [textStorage hash], [realTextStorage hash]); // there are equal...
//    [console release];
    return YES;
}

//- (void) addCustomizedViews(NSPopUpButton *anchorBtn, XLog_Console *console, NSTextStorage *textStorage)
- (void)addCustomizedViews:(NSPopUpButton *)anchorBtn textStorage:(NSTextStorage *)textStorage
{
	XLog(@"addCustomizedViews:");
    NSFont *font = anchorBtn.font;
    
    NSView *pView = anchorBtn.superview;    // parent view (container)
    CGFloat x = anchorBtn.frame.origin.x + anchorBtn.frame.size.width;  // for horizental layout
    CGFloat pHeight = pView.frame.size.height;
    CGFloat margin = 1.0f;   // search field and filter button's top/bottom margin
    
    // add log level popup button
//    NSPopUpButton *logLevelButton = [[NSPopUpButton alloc] initWithFrame:CGRectZero pullsDown:NO];
//    NSArray *items = [NSArray arrayWithObjects:@"All logs", @"Debug", @"Info", @"Warn", @"Error", nil];
//    [logLevelButton addItemsWithTitles:items];
//    [logLevelButton setBordered:NO];
//    [logLevelButton setFont:font];
//    [logLevelButton sizeToFit];
//    CGRect frame = logLevelButton.frame;
//    logLevelButton.frame = CGRectMake(x, (pHeight - frame.size.height) / 2.0f, frame.size.width, frame.size.height) ;
//    [pView addSubview:logLevelButton];
//    [logLevelButton release];
//    
    // set click handler
//    [logLevelButton setTarget:self];
//    [logLevelButton setAction:@selector(onLogLevelButtonClick:)];
//    logLevelButton.tag = (long)textStorage; // save the refer
    
//    x += logLevelButton.frame.size.width;
    
    // add regex filter textview
//    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:CGRectMake(x, margin, 200.0f, pHeight - 2 * margin)];
//    searchField.font = font;
//    [searchField.cell setPlaceholderString:@"Grep expression"];
//	[searchField setDelegate:self];
//    [pView addSubview:searchField];
//    [searchField release];
    
    self.searchTokenField = [[NSTokenField alloc] initWithFrame:CGRectMake(x, margin, 200.0f, pHeight - 2 * margin)];
    [self.searchTokenField setTokenStyle:NSPlainTextTokenStyle];
    [self.searchTokenField setDelegate:self];		// this can also be done in Interface Builder
    [self.searchTokenField setCompletionDelay:0.5];	// speed up auto completion a bit for type matching
    [self.searchTokenField.cell setPlaceholderString:@"Grep expression"];
    [pView addSubview:self.searchTokenField];
    [self.searchTokenField release];

    
    x += self.searchTokenField.frame.size.width;
    
    // add config button
	NSButton *configButton =[[NSButton alloc] initWithFrame:CGRectZero];
	[configButton setBordered:NO];
	NSImage *configButtonImage = [NSImage imageNamed:NSImageNameActionTemplate];
	configButton.image = configButtonImage;
    configButton.font = font;
    [configButton sizeToFit];
    CGRect frame = configButton.frame;
    configButton.frame = CGRectMake(x + 10.0f, (pHeight - frame.size.height) / 2.0f, frame.size.width, frame.size.height);
    [pView addSubview:configButton];
    [configButton release];
    [configButton setTarget:self];
    [configButton setAction:@selector(configButtonClick:)];
    
	[self proceedGrep];
}



- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
	NSTokenStyle returnStyle = NSPlainTextTokenStyle;
    returnStyle = NSRoundedTokenStyle;

    return returnStyle;
}

- (void)proceedGrep;
{
	[self proceedGrepInRange:NSMakeRange(0, self.textStorage.string.length)];
    XLog(@"[AWPXcodeLogGrep proceedGrep]");
}

- (void)proceedGrepInRange:(NSRange)range;
{
	NSString *string	= self.textStorage.string;
	NSRange searchRange = range;

	if (!self.configWindowController)
	{
		self.configWindowController = [ConfigWindowController new];
	}
	
	NSFont			*searchStringFont							= self.configWindowController.searchStringResultsFont;
	NSColor			*searchStringColor							= self.configWindowController.searchStringResultsColor;
	NSDictionary	*searchstringAttributesDictionary			= @{NSFontAttributeName: searchStringFont, NSForegroundColorAttributeName: searchStringColor};

	NSFont			*lineWithSearchStringFont					= self.configWindowController.lineWithResultsFont;
	NSColor			*lineWithSearchStringColor					= self.configWindowController.lineWithResultsColor;
	NSDictionary	*lineWithSearchStringAttributesDictionary	= @{NSFontAttributeName: lineWithSearchStringFont, NSForegroundColorAttributeName: lineWithSearchStringColor};

	NSFont			*lineWithoutSearchStringFont				= self.configWindowController.lineWithoutResultsFont;
	NSColor			*lineWithoutSearchStringColor				= self.configWindowController.lineWithoutResultsColor;
	NSDictionary	*lineWithoutSearchStringAttributesDictionary= @{NSFontAttributeName: lineWithoutSearchStringFont, NSForegroundColorAttributeName: lineWithoutSearchStringColor};

	NSFont			*lineHiddenFont								= [NSFont systemFontOfSize:0.00001];
	NSColor			*lineHiddenColor							= [NSColor clearColor];
	NSDictionary	*lineHiddenAttributesDictionary				= @{NSFontAttributeName: lineHiddenFont, NSForegroundColorAttributeName: lineHiddenColor};

	NSArray         *searchStrings								= self.searchTokenField.objectValue;

	[self.textStorage beginEditing];

	if (searchStrings.count)
	{
		[string enumerateSubstringsInRange:searchRange
								   options:NSStringEnumerationByLines
								usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
		 {
             BOOL substringContainsSearchString = NO;
             [self.textStorage setAttributes:lineWithSearchStringAttributesDictionary range:substringRange];
             
             for (NSString *searchString in searchStrings)
             {
                 
                 NSRange lineSearchRange = NSMakeRange(0,substring.length);
                 NSRange foundRange;
                 while (lineSearchRange.location < substring.length)
                 {
                     lineSearchRange.length = substring.length-lineSearchRange.location;
                     foundRange = [substring rangeOfString:searchString options:NSCaseInsensitiveSearch range:lineSearchRange];
                     if (foundRange.location != NSNotFound)
                     {
                         lineSearchRange.location = foundRange.location+foundRange.length;
                         
                         XLog(@"searchString: %@", searchString.class);
                         NSRange textStorageSearchSubStringRange = NSMakeRange(foundRange.location + substringRange.location, foundRange.length);
                         XLog(@"Range: %lui || %lui", textStorageSearchSubStringRange.location, textStorageSearchSubStringRange.length);
                         [self.textStorage setAttributes:searchstringAttributesDictionary range:textStorageSearchSubStringRange];
                         substringContainsSearchString = YES;
                     }
                     else
                     {
                         // no more substring to find
                         break;
                     }
                 }
             }
             
			 if (substringContainsSearchString)
			 {
                 
			 }
			 else
			 {
				 // line without search string
				 if (!self.configWindowController.linesWithoutResultsHidden)
				 {
					 [self.textStorage setAttributes:lineWithoutSearchStringAttributesDictionary range:substringRange];
				 }
				 else
				 {
					 [self.textStorage setAttributes:lineHiddenAttributesDictionary range:substringRange];
				 }
			 }
		 }];
	}
	else
	{
		[self.textStorage setAttributes:lineWithSearchStringAttributesDictionary range:searchRange];
	}
	
	[self.textStorage endEditing];
}



# pragma mark - swizzling methodes

- (void)fixAttributesInRange:(NSRange)range
{
	XLog(@"fixAttributesInRange:");
//	XLog(@"self = %@", self);
//    originalFixAttributesInRange(self, _cmd, range);
    
    NSString *className = NSStringFromClass([self class]);
//    XLog(@"fixAttributesInRange[%@]", className);
    // it must not a console textstorage.
    if (![className isEqualToString:@"DVTFoldingTextStorage"]
        && ![className isEqualToString:@"DVTTextStorage"]) {
        return ;
    }
	
	if (self == sharedPlugin.textStorage && sharedPlugin)
	{
		[sharedPlugin proceedGrepInRange:range];
//		[sharedPlugin proceedGrep];
		
		return;
	}
	
	NSTextStorage *dvtTextStorage = (NSTextStorage *)self;
	
    // self is new, test it. Only need test DVTFoldingTextStorage
    if (!sharedPlugin.textStorage &&  [className isEqualToString:@"DVTTextStorage"])
	{
		XLog(@"sharedPlugin testTextStorage:");
		[sharedPlugin testTextStorage:dvtTextStorage];
    }
}



# pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
	NSTokenField *searchTokenField = (NSTokenField *)notification.object;
	XLog(@"controlTextDidChange: %@", searchTokenField.objectValue);

	self.currentSearStarts++;
	
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
				   {
					   if (self.currentSearStarts > 1)
					   {
						   // Do nothing
					   }
					   else
					   {
						   [self proceedGrep];
					   }
					   
					   self.currentSearStarts--;
				   });
}



#pragma mark - Actions

- (IBAction)configButtonClick:(NSButton *)button;
{
	NSWindow *window = self.configWindowController.window;
	[NSApp beginSheet:window
	   modalForWindow:[[NSApplication sharedApplication] mainWindow]
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];}

@end



