//
//  FitTagNavigationBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTNavigationBar.h"

@implementation FTNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"FTNavigationBar");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [self setBarTintColor:[UIColor redColor]];
    }
    return self;
}
@end
