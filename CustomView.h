//
//  CustomView.h
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppController;
@interface CustomView : NSView {
    __weak AppController *controller;
    BOOL clicked;
    
    float p1Y;
    float p2Y;
    float ballX;
    float ballY;
    float ballDeltaX;
    float ballDeltaY;
    
    bool p1ShouldLose;
    bool p2ShouldLose;
    
    bool someoneScored;
    int h;
    int m;
    NSTimer *timer;
}
- (NSDateComponents *)getCurrentDateTime;

- (id)initWithFrame:(NSRect)frame controller:(AppController *)ctrlr;
- (void)refresh;
@end
