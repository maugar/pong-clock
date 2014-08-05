//
//  AppController.m
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import "AppController.h"
#import "CustomView.h"
#import "MAAttachedWindow.h"


@implementation AppController


- (void)awakeFromNib
{
    [NSApp setActivationPolicy: NSApplicationActivationPolicyProhibited];

    // Create an NSStatusItem.
    float width = 30.0;
    float height = [[NSStatusBar systemStatusBar] thickness];
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
    [statusItem setView:[[CustomView alloc] initWithFrame:viewFrame controller:self]];
    [statusItem setLength:60];
    //NSLog(@"%f", statusItem.length);
}


- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}




@end
