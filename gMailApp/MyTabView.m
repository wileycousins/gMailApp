//
//  MyTabView.m
//  gMailApp
//
//  Created by H. Cole Wiley on 6/16/14.
//  Copyright (c) 2014 WileyCousins. All rights reserved.
//

#import "MyTabView.h"

@implementation MyTabView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      // Initialization code here.
  }
  [self setAcceptsTouchEvents:YES];
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)swipeWithEvent:(NSEvent *)event {
  CGFloat x = [event deltaX];
  NSLog(@"gesture: %f", x);
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

@end
