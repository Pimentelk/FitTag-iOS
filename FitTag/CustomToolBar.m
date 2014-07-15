//
//  CustomToolBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/29/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "CustomToolBar.h"

@implementation CustomToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBarTintColor:[UIColor redColor]];
        [self setTranslucent:YES];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
