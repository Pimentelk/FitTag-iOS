//
//  FTAccountHeaderView+FTMapScrollView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapScrollView.h"

@implementation FTMapScrollView
@synthesize items;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

@end
