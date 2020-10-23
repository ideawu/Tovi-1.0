//
//  ToviAboutWindowController.m
//  Tovi
//
//  Created by ideawu on 13-4-5.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import "ToviAboutWindowController.h"

@interface ToviAboutWindowController ()

@end

@implementation ToviAboutWindowController

- (id)init{
	self = [super initWithWindowNibName:@"AboutWindow"];
	return self;
}

- (void)awakeFromNib{
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSImage *iconImage;
	iconImage = [NSApp applicationIconImage];
	[self.icon setImage:iconImage];

	[self.text1 setStringValue:[info objectForKey:@"CFBundleName"]];

	NSString *str = [NSString stringWithFormat:@"Version %@ (%@)\n\n%@",
					 [info objectForKey:@"CFBundleShortVersionString"],
					 [info objectForKey:@"CFBundleVersion"],
					 [info objectForKey:@"NSHumanReadableCopyright"],
					 nil];
	[self.text2 setStringValue:str];
}

- (void)windowDidLoad{
    [super windowDidLoad];

	// monitor ESC key
	NSEvent* (^handler)(NSEvent*) = ^(NSEvent *theEvent) {
		NSWindow *targetWindow = [theEvent window];
        if (targetWindow != self.window) {
			NSLog(@"on other window: %@", targetWindow);
            return theEvent;
        }

		NSEvent *result = theEvent;
 		NSLog(@"event monitor: %@", theEvent);
		if (theEvent.keyCode == 53) {
			[self cancelOperation: self];
			result = nil;
		}
        return result;
    };
    eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:handler];
}

- (IBAction)showWindow:(id)sender{
	[super showWindow:sender];
	//[NSApp runModalForWindow:self.window];
}

- (void)windowWillClose:(NSNotification *)notification{
	//[NSApp stopModal];
	[NSEvent removeMonitor:eventMonitor];
}

- (void)cancelOperation:(id)sender{
	[self.window performClose:self];
}

- (void)keyDown:(NSEvent *)theEvent{
	//[super keyDown:theEvent];
}

@end
