//
//  FTAccountHeaderView+FTMapScrollViewItem.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTMapScrollViewItem.h"

@interface FTMapScrollViewItem() {
    
}
@end

@implementation FTMapScrollViewItem
@synthesize containerView;
@synthesize itemImageView;
@synthesize titleLabel;
@synthesize locationLabel;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        containerView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:containerView];
        
        itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, self.frame.size.height)];
        [itemImageView setContentMode: UIViewContentModeScaleAspectFill];
        [itemImageView setBackgroundColor:[UIColor clearColor]];
        [itemImageView setClipsToBounds:YES];
        [self.containerView addSubview:itemImageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemImageView.frame.size.width + 5, 5, self.frame.size.width - 120 - 5, 30)];
        [titleLabel setText:@"test"];
        [self.containerView addSubview:titleLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemImageView.frame.size.width + 5, titleLabel.frame.size.height + 5, self.frame.size.width - 120 - 5, 30)];
        [locationLabel setText:@"test"];
        [self.containerView addSubview:locationLabel];
    }
    return self;
}

@end
