//
//  ConfigWindowController.m
//  AWPXcodeLogGrep
//
//  Created by Andreas Prang on 29.12.13.
//  Copyright (c) 2013 iSolute. All rights reserved.
//

#import "ConfigWindowController.h"

#define linesWithResultsFontSize @"linesWithResultsFontSize"
#define linesWithoutResultsFontSize @"linesWithoutResultsFontSize"
#define searchStringResultsFontSize @"searchStringResultsFontSize"

#define linesWithResultsFontName @"linesWithResultsFontName"
#define linesWithoutResultsFontName @"linesWithoutResultsFontName"
#define searchStringResultsFontName @"searchStringResultsFontName"

#define linesWithResultsColor @"linesWithResultsColor"
#define linesWithoutResultsColor @"linesWithoutResultsColor"
#define searchStringsResultsColor @"searchStringResultsColor"

#define hideLinesWithoutResults @"hideLinesWithoutResults"

@interface ConfigWindowController ()
{
	NSButton *selectedFontButton;
}

@end

@implementation ConfigWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
	self.previewTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:@"Line without search results\nLine with search result"];
	self.hideLinesWithoutResultsButton.state = self.linesWithoutResultsHidden;
	[self updatePreviewText];
}

- (IBAction)saveButtonUp:(NSButton *)sender
{
	[self.window orderOut:self];
	[NSApp stopModal];

	[NSApp endSheet:self.window];
	[self close];
}

- (IBAction)selectFontButtonUp:(NSButton *)sender
{
	selectedFontButton = sender;
	
	NSLog(@"configWindow: selectFontButtonUp:");
	
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
//    [fontManager setDelegate:self];
	[fontManager setAction:@selector(changeFont:)];
	[fontManager setTarget:self];
	
	NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setTarget:self];
	[colorPanel setAction:@selector(changeColor:)];
	
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel makeKeyAndOrderFront:sender];
}

- (void)changeFont:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:@"ppp" forKey:@"ppp"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"configWindow: ppp=> \"-%@-\"", [[NSUserDefaults standardUserDefaults] objectForKey:@"ppp"]);
	
	NSLog(@"configWindow: changeFont: color:");


	NSFont			*selectedFont						= [NSFont systemFontOfSize:11];
	selectedFont = [sender convertFont:selectedFont];
	NSLog(@"configWindow: changeFont: Font: %@", selectedFont);
	
	if (selectedFontButton == self.linesWithResultsButton)
	{
		NSLog(@"configWindow: changeFont: selectedFontButton = linesWithResultsButton");

		[[NSUserDefaults standardUserDefaults] setObject:selectedFont.fontName forKey:linesWithResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:@(selectedFont.pointSize) forKey:linesWithResultsFontSize];
		
	}
	else if (selectedFontButton == self.linesWithoutResultsButton)
	{
		NSLog(@"configWindow: changeFont: selectedFontButton = linesWithoutResultsButton");

		[[NSUserDefaults standardUserDefaults] setObject:selectedFont.fontName forKey:linesWithoutResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:@(selectedFont.pointSize) forKey:linesWithoutResultsFontSize];
	}
	else if (selectedFontButton == self.searchStringResultsButton)
	{
		NSLog(@"configWindow: changeFont: selectedFontButton = searchStringResultsButton");

		[[NSUserDefaults standardUserDefaults] setObject:selectedFont.fontName forKey:searchStringResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:@(selectedFont.pointSize) forKey:searchStringResultsFontSize];
	}
	else
	{
		NSLog(@"configWindow: changeFont: selectedFontButton = nil");
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self updatePreviewText];
}

- (void)changeColor:(id)sender
{
	XLog(@"Thread: %@", [NSThread currentThread]);
	XLog(@"configWindow: changeColor: color:");

	NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
	NSColor *color = colorPanel.color;
	NSData* colorAsData = [NSArchiver archivedDataWithRootObject:color];
	
	if (selectedFontButton == self.linesWithResultsButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:linesWithResultsColor];
	}
	else if (selectedFontButton == self.linesWithoutResultsButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:linesWithoutResultsColor];
	}
	else if (selectedFontButton == self.searchStringResultsButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:searchStringsResultsColor];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeAttributes:(id) sender
{
	XLog(@"received -changeAttributes: from <%@>", sender );
	
	NSDictionary *newAttributes = [sender convertAttributes:@{}];
	
	[self updatePreviewText];
}

- (void)updatePreviewText
{
	NSLog(@"[self lineWithoutResultsFont]: %@", [self lineWithoutResultsFont]);

	NSMutableAttributedString *attributedString = [self.previewTextField.attributedStringValue mutableCopy];

	// line without search result
	NSFont *font = [self lineWithoutResultsFont];
	if (font)
	{
		NSDictionary	*lineWithoutSearchStringAttributesDictionary;
		if (self.linesWithoutResultsHidden)
		{
			lineWithoutSearchStringAttributesDictionary= @{NSFontAttributeName: [NSFont systemFontOfSize:0.01], NSForegroundColorAttributeName: [NSColor clearColor]};
		}
		else
		{
			NSFont			*lineWithoutSearchStringFont				= self.lineWithoutResultsFont;
			NSColor			*lineWithoutSearchStringColor				= self.lineWithoutResultsColor;
			lineWithoutSearchStringAttributesDictionary= @{NSFontAttributeName: lineWithoutSearchStringFont, NSForegroundColorAttributeName: lineWithoutSearchStringColor};
		}

		[self.linesWithoutResultsButton setTitle:[NSString stringWithFormat:@"\"%@\" %f.4pt", font.fontName, font.pointSize]];

		NSRange range = NSMakeRange(0, @"Line without search results".length);
		[attributedString addAttributes:lineWithoutSearchStringAttributesDictionary range:range];
	}
	
	// line with search result
	NSFont *font1 = [self lineWithResultsFont];
	if (font1)
	{
		[self.linesWithResultsButton setTitle:[NSString stringWithFormat:@"\"%@\" %fpt", font1.fontName, font1.pointSize]];
		NSDictionary	*selectedFontAttributesDictionary	= [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
		
		NSRange range = NSMakeRange(@"Line without search results\n".length, @"Line with search".length);
		[attributedString addAttributes:selectedFontAttributesDictionary range:range];
		[attributedString addAttribute:NSForegroundColorAttributeName value:[self lineWithResultsColor] range:range];
	}
	
	// search results
	NSFont *font2 = [self searchStringResultsFont];
	if (font2)
	{
		[self.searchStringResultsButton setTitle:[NSString stringWithFormat:@"\"%@\" %fpt", font2.fontName, font2.pointSize]];
		NSDictionary	*selectedFontAttributesDictionary	= [NSDictionary dictionaryWithObject:font2 forKey:NSFontAttributeName];
		
		NSRange range = NSMakeRange(@"Line without search results\n Line with search".length, @"result".length);
		[attributedString addAttributes:selectedFontAttributesDictionary range:range];
		[attributedString addAttribute:NSForegroundColorAttributeName value:[self searchStringResultsColor] range:range];
	}
	
	self.previewTextField.attributedStringValue = attributedString;
}



#pragma mark - getter

- (NSFont *)lineWithResultsFont;
{
	NSLog(@"configWindow: lineWithResultsFont: ppp=> \"-%@-\"", [[NSUserDefaults standardUserDefaults] objectForKey:@"ppp"]);

	NSString *fontName = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithResultsFontName];
	NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithResultsFontSize];
	NSLog(@"configWindow: fontName: %@", fontName);
	NSLog(@"configWindow: fontSize: %@", fontSize);

	if (!fontName.length)
	{
		fontName = @"Menlo";
		fontSize = @(11);
		[[NSUserDefaults standardUserDefaults] setObject:fontName forKey:linesWithResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:linesWithResultsFontSize];
	}
	NSFont *font = [NSFont fontWithName:fontName size:fontSize.floatValue];
	
	return font;
}

- (NSFont *)lineWithoutResultsFont;
{
	NSString *fontName = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithoutResultsFontName];
	NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithoutResultsFontSize];
	NSLog(@"configWindow: fontName: %@", fontName);
	NSLog(@"configWindow: fontSize: %@", fontSize);
	
	if (!fontName.length)
	{
		fontName = @"Menlo";
		fontSize = @(11);
		[[NSUserDefaults standardUserDefaults] setObject:fontName forKey:linesWithoutResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:linesWithoutResultsFontSize];
	}
	NSFont *font = [NSFont fontWithName:fontName size:fontSize.floatValue];
	
	return font;
}

- (NSFont *)searchStringResultsFont;
{
	NSString *fontName = [[NSUserDefaults standardUserDefaults] objectForKey:searchStringResultsFontName];
	NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:searchStringResultsFontSize];
	NSLog(@"configWindow: searchStringResultsColor: fontName: %@", fontName);
	NSLog(@"configWindow: searchStringResultsColor: fontSize: %@", fontSize);

	if (!fontName.length)
	{
		fontName = @"Menlo-Bold";
		fontSize = @(11);
		[[NSUserDefaults standardUserDefaults] setObject:fontName forKey:searchStringResultsFontName];
		[[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:searchStringResultsFontSize];
	}
	NSFont *font = [NSFont fontWithName:fontName size:fontSize.floatValue];
	
	return font;
}

- (NSColor *)lineWithResultsColor;
{
	NSColor *color;
	NSData *colorAsData = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithResultsColor];
	if (colorAsData)
	{
		color = [NSUnarchiver unarchiveObjectWithData:colorAsData];
	}
	else
	{
		color = [NSColor blackColor];
	}
	
	return color;
}

- (NSColor *)lineWithoutResultsColor;
{
	NSColor *color;
	NSData *colorAsData = [[NSUserDefaults standardUserDefaults] objectForKey:linesWithoutResultsColor];
	if (colorAsData)
	{
		color = [NSUnarchiver unarchiveObjectWithData:colorAsData];
	}
	else
	{
		color = [NSColor lightGrayColor];
	}
	
	return color;
}

- (NSColor *)searchStringResultsColor;
{
	NSColor *color;
	NSData *colorAsData = [[NSUserDefaults standardUserDefaults] objectForKey:searchStringsResultsColor];
	if (colorAsData)
	{
		color = [NSUnarchiver unarchiveObjectWithData:colorAsData];
	}
	else
	{
		color = [NSColor blackColor];
	}
	
	return color;
}

- (IBAction)hideLinesWithoutResultsButtonUp:(NSButton *)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:sender.state forKey:hideLinesWithoutResults];
    [self updatePreviewText];
}

- (BOOL)linesWithoutResultsHidden;
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:hideLinesWithoutResults];
}

@end
