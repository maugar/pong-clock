//
//  CustomView.m
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import "CustomView.h"
#import "AppController.h"
#import <QuartzCore/QuartzCore.h>

#define HEIGHT 20
#define WIDTH 60

#define PADDLE_HEIGHT 8
#define PADDLE_WIDTH 2

#define BALL_SIZE 3

#define WINDOW_OFFSET 3

#define FPS (24.0)

@implementation CustomView

- (id)initWithFrame:(NSRect)frame controller:(AppController *)ctrlr{
    if (self = [super initWithFrame:frame]) {
        controller = ctrlr; // deliberately weak reference.
        [self startMatchAndP1HasBall:YES];
    }
    return self;
}

- (void)dealloc{
    controller = nil;
}

- (void)drawRect:(NSRect)rect {
   

    [[NSColor blackColor] setFill];

    NSRect bg =NSMakeRect(0, 0, WIDTH, HEIGHT+WINDOW_OFFSET);
    NSRectFill(bg);
    
    [[NSColor whiteColor] setFill];

    NSRect middle =NSMakeRect(30, 0, 0.5, HEIGHT+WINDOW_OFFSET);
    NSRectFill(middle);
    
    NSRect p1 =NSMakeRect(2, p1Y, PADDLE_WIDTH, PADDLE_HEIGHT);
    NSRectFill(p1);
    
    NSRect p2 =NSMakeRect(WIDTH-PADDLE_WIDTH-2, p2Y, PADDLE_WIDTH, PADDLE_HEIGHT);
    NSRectFill(p2);
    
    NSRect ball =NSMakeRect(ballX, ballY, BALL_SIZE, BALL_SIZE);
    NSRectFill(ball);
    
    NSMutableParagraphStyle * paragraphStyleH = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyleH setAlignment:NSRightTextAlignment];
    
    NSFont * font = [NSFont fontWithName:@"04b03" size:12];

    if (font==nil) {
        NSLog(@"Please install 04b03 font!");
        [NSApp terminate:self];
    }
    
    
    NSDictionary* attributesH = @{NSParagraphStyleAttributeName: paragraphStyleH,
                                NSForegroundColorAttributeName: [NSColor whiteColor],
                                NSFontAttributeName: font};
    
    NSString * Hstr = [[NSString alloc] initWithFormat:@"%d", h];
    [Hstr drawAtPoint:NSMakePoint(17, 10) withAttributes:attributesH];
    
    NSMutableParagraphStyle * paragraphStyleM = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyleM setAlignment:NSLeftTextAlignment];
        
    NSDictionary* attributesM = @{NSParagraphStyleAttributeName: paragraphStyleM,
                                 NSForegroundColorAttributeName: [NSColor whiteColor],
                                 NSFontAttributeName: font};
    
    NSString * Mstr = [[NSString alloc] initWithFormat:@"%d", m];
    [Mstr drawAtPoint:NSMakePoint(33, 10) withAttributes:attributesM];
}

-(void)refresh{
    [self moveBall];
    [self moveP1:p1ShouldLose];
    [self moveP2:p2ShouldLose];
    
    if(someoneScored) {
        [timer invalidate];
        h=[[self getCurrentDateTime] hour];
        m=[[self getCurrentDateTime] minute];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self startMatchAndP1HasBall:p1ShouldLose];
        });
    }
    
    [self setNeedsDisplay:YES];    
}


- (void) moveBall{
    ballX+=ballDeltaX;
    ballY+=ballDeltaY;
    
    if(p1ShouldLose){
        if(ballX<0){
            //NSLog(@"GAME OVER");
            someoneScored=YES;
            ballDeltaX=0;
        }else{
            if(ballX>WIDTH-BALL_SIZE-PADDLE_WIDTH-2){
                ballX=WIDTH-BALL_SIZE-PADDLE_WIDTH-2;
                ballDeltaX=-ballDeltaX;
            }
        }
    }else if(p2ShouldLose) {
        if(ballX>WIDTH-BALL_SIZE){
            //NSLog(@"GAME OVER");
            someoneScored=YES;
            ballDeltaX=0;
        }else{
            if(ballX<PADDLE_WIDTH+2){
                ballX=PADDLE_WIDTH+2;
                ballDeltaX=-ballDeltaX;
            }
        }
    }else{
        if(ballX>WIDTH-BALL_SIZE-PADDLE_WIDTH-2){
            ballX=WIDTH-BALL_SIZE-PADDLE_WIDTH-2;
            ballDeltaX=-ballDeltaX;
            [self checkClock];        
        }
        
        if(ballX<PADDLE_WIDTH+2){
            ballX=PADDLE_WIDTH+2;
            ballDeltaX=-ballDeltaX;
            [self checkClock];            
        }
    }

    
    if(ballY+BALL_SIZE>HEIGHT+WINDOW_OFFSET){
        ballY=HEIGHT+WINDOW_OFFSET-BALL_SIZE;
        ballDeltaY=-ballDeltaY;
    }
    
    if(ballY<0){
        ballY=0;
        ballDeltaY=-ballDeltaY;
    }
}


-(void)moveP1:(bool)shouldLose{
    float err;
    
    if (ballDeltaX<0) {
        if(shouldLose){
            err=ballY+1.5-p1Y-(PADDLE_HEIGHT/2.0);
            if(abs(err)>0.1){
                if(ballX< WIDTH/3.0){
                    err*=0.1;
                }else if(ballX< WIDTH/3.0*2.0){
                    err*=0.05;
                }else{
                    err*=0.01;
                }
                p1Y+=err;
            }
        }else{
            err=ballY+1.5-p1Y-(PADDLE_HEIGHT/2.0);
            if(abs(err)>0.1){
                if(ballX< WIDTH/3.0){
                    err*=0.4;
                }else if(ballX< WIDTH/3.0*2.0){
                    err*=0.2;
                }else{
                    err*=0.08;
                }
                p1Y+=err;
            }
        }
    }else{
        err=ballY+1.5-p1Y-(PADDLE_HEIGHT/2.0);
        if(abs(err)>0.1){
            if(ballX>=WIDTH/3.0*2.0){
                err*=0.02;
                p1Y+=err;
            }
        }
    }
    if (p1Y<0) p1Y=0;
    if (p1Y+PADDLE_HEIGHT>HEIGHT+WINDOW_OFFSET) p1Y=HEIGHT-PADDLE_HEIGHT+WINDOW_OFFSET;
}

-(void)moveP2:(bool)shouldLose{
    float err;
    if (ballDeltaX>0) {
        if(shouldLose){
            err=ballY+1.5-p2Y-(PADDLE_HEIGHT/2.0);
            if(abs(err)>0.1){
                if(ballX< WIDTH/3.0){
                    err*=0.1;
                }else if(ballX< WIDTH/3.0*2.0){
                    err*=0.05;
                }else{
                    err*=0.01;
                }
                p2Y+=err;
            }
        }else{
            err=ballY-p2Y-(PADDLE_HEIGHT/2.0);
            if(abs(err)>0.1){
                if(ballX> WIDTH/3.0*2){
                    err*=0.4;
                }else if(ballX> WIDTH/3.0){
                    err*=0.2;
                }else{
                    err*=0.08;
                }
                p2Y+=err;
            }
        }
    }else{
        err=ballY+1.5-p2Y-(PADDLE_HEIGHT/2.0);
        if(abs(err)>0.1){
            if(ballX>=WIDTH<3.0){
                err*=0.02;
                p2Y+=err;
            }
        }
    }
    if (p2Y<0) p2Y=0;
    if (p2Y+PADDLE_HEIGHT>HEIGHT+WINDOW_OFFSET) p2Y=HEIGHT-PADDLE_HEIGHT+WINDOW_OFFSET;
}


- (void) startMatchAndP1HasBall:(bool)p1Starting{
    p1Y=0;
    p2Y=HEIGHT-PADDLE_HEIGHT+WINDOW_OFFSET;
    
    if(p1Starting){
        ballX=PADDLE_WIDTH+BALL_SIZE+1;
    }else{
        ballX=WIDTH-PADDLE_WIDTH-BALL_SIZE-1;
    }
    
    ballY=PADDLE_WIDTH/2.0;
    
    ballDeltaX=1.0+ (arc4random()%20)/20.0;
    ballDeltaY=0.5+ (arc4random()%15)/15.0;
    
    h=[[self getCurrentDateTime] hour];
    m=[[self getCurrentDateTime] minute];
    
    p1ShouldLose=NO;
    p2ShouldLose=NO;
    
    someoneScored=NO;
    
    //NSLog(@"%d:%d",  h ,m);
    //[self performSelector:@selector(refresh) withObject:nil afterDelay:1];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:1.0/FPS
                                     target:self
                                   selector:@selector(refresh)
                                   userInfo:nil
                                    repeats:YES];

}

- (void) checkClock{
    int newH;
    int newM;
    
    if(p1ShouldLose || p2ShouldLose){
        return;
    }
    
    newH=[[self getCurrentDateTime] hour];
    newM=[[self getCurrentDateTime] minute];
    
    if (m!=newM) {
        //m=newM;
        p1ShouldLose=YES;
        //NSLog(@"P2 IS GONNA LOSE!");
        if(h!=newH){
            //h=newH;
            //NSLog(@"P1 IS GONNA LOSE!");
            p2ShouldLose=YES;
        }
    }
}

-(NSDateComponents *)getCurrentDateTime{
    return [ [NSCalendar currentCalendar] components:NSHourCalendarUnit + NSMinuteCalendarUnit + NSSecondCalendarUnit fromDate:[NSDate date]];
}


@end
