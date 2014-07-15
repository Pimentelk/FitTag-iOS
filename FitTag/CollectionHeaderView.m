//
//  CollectionHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "CollectionHeaderView.h"

@implementation CollectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Top text header
        self.messageHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 15.0f)];
        self.messageHeader.numberOfLines = 0;
        self.messageHeader.text = @"WHAT INSPIRES YOU?";
        self.messageHeader.backgroundColor = [UIColor clearColor];
        self.messageHeader.textAlignment = NSTextAlignmentCenter;
        
        // Message text
        self.messageText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 23.0f, self.frame.size.width, 55.0f)];
        self.messageText.numberOfLines = 0;
        self.messageText.text = @"What inspires you to reach your fitness goals? A new healthy recipe, a muscle building exercise? Tell us and we will find content you'll love!";
        self.messageText.backgroundColor = [UIColor clearColor];
        self.messageText.textAlignment = NSTextAlignmentCenter;
        self.messageText.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:self.messageHeader];
        [self addSubview:self.messageText];
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
