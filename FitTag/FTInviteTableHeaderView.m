//
//  UITableViewCell+FTInviteTableHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/29/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInviteTableHeaderView.h"

#define LOCATION_BUTTON_HEIGHT 40
#define BUTTON_PADDING 20

@implementation FTInviteTableHeaderView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        [self setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                                 green:FT_GRAY_COLOR_GREEN
                                                  blue:FT_GRAY_COLOR_BLUE
                                                 alpha:1.0f]];
        
        CGFloat locationButtonY = (self.frame.size.height - LOCATION_BUTTON_HEIGHT) / 2;
        CGFloat locationButtonWidth = ((self.frame.size.width/2) - BUTTON_PADDING);
        CGFloat locationButtonX = ((self.frame.size.width/2) - locationButtonWidth) / 2;
        
        UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton addTarget:self action:@selector(didTapLocationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [locationButton setFrame:CGRectMake(locationButtonX, locationButtonY, locationButtonWidth, LOCATION_BUTTON_HEIGHT)];
        [locationButton setTitle:@"Location" forState:UIControlStateNormal];
        [locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [locationButton setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:locationButton];
        
        CGFloat interestButtonY = locationButtonY;
        CGFloat interestButtonWidth = locationButtonWidth;
        CGFloat interestButtonX = (self.frame.size.width / 2) + locationButtonX;
        
        UIButton *interestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [interestButton addTarget:self action:@selector(didTapInterestButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [interestButton setFrame:CGRectMake(interestButtonX, interestButtonY, interestButtonWidth, LOCATION_BUTTON_HEIGHT)];
        [interestButton setTitle:@"Interest" forState:UIControlStateNormal];
        [interestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [interestButton setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:interestButton];
    }
    return self;
}

#pragma mark - ()

- (void)didTapLocationButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(inviteTableHeaderView:didTapLocationButton:)]) {
        [delegate inviteTableHeaderView:self didTapLocationButton:button];
    }
}

- (void)didTapInterestButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(inviteTableHeaderView:didTapInterestButton:)]) {
        [delegate inviteTableHeaderView:self didTapInterestButton:button];
    }
}

@end
