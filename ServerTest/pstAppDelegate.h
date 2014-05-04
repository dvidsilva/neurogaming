//
//  pstAppDelegate.h
//  ServerTest
//
//  Created by Dvid Silva on 5/3/14.
//  Copyright (c) 2014 postatlantic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pstAppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property IBOutlet NSSlider *slider; 
@property IBOutlet NSTextField *username, *action, *multiplier;

@end
