//
//  ToviAboutWindowController.h
//  Tovi
//
//  Created by ideawu on 13-4-5.
//  Copyright (c) 2013年 udpwork.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToviAboutWindowController : NSWindowController<NSWindowDelegate>{
	id eventMonitor;
}
@property (weak) IBOutlet NSImageView *icon;
@property (weak) IBOutlet NSTextField *text1;
@property (weak) IBOutlet NSTextField *text2;

@end
