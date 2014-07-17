//
//  FitTagNavigationBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FitTagNavigationBar.h"

@implementation FitTagNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"FitTagNavigationBar::initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [self setBarTintColor:[UIColor redColor]];
    }
    return self;
}
@end
