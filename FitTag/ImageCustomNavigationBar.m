//
//  CustomNavigationViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/27/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "ImageCustomNavigationBar.h"

@interface ImageCustomNavigationBar ()
@end

@implementation ImageCustomNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"CustomNavigationBar::initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [self setBarTintColor:[UIColor redColor]];
        [self setBackIndicatorImage:[UIImage imageNamed: @"navigate_back"]];
        [self setBackIndicatorTransitionMaskImage:[UIImage imageNamed: @"navigate_back"]];
        
    
    }
    return self;
}

@end
