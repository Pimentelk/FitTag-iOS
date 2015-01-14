//
//  UITableViewCell+FTInviteTableHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/29/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInviteTableHeaderView.h"

#define TAB_HEIGHT 40
#define TAB_PADDING 20

@interface FTInviteTableHeaderView() {
    UIColor *baseRedColor;
}
@end

@implementation FTInviteTableHeaderView
@synthesize delegate;
@synthesize locationButton;
@synthesize interestButton;

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        baseRedColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                       green:FT_RED_COLOR_GREEN
                                        blue:FT_RED_COLOR_BLUE
                                       alpha:1.0f];
        
        [self setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                                 green:FT_GRAY_COLOR_GREEN
                                                  blue:FT_GRAY_COLOR_BLUE
                                                 alpha:1.0f]];
        
        CGFloat locationButtonWidth = self.frame.size.width / 2;

        UITapGestureRecognizer *locationTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(didTapLocationButtonAction:)];
        [locationTapGesture setNumberOfTapsRequired:1];

        locationButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, locationButtonWidth, TAB_HEIGHT)];
        [locationButton setText:@"Nearby"];
        [locationButton setTextAlignment:NSTextAlignmentCenter];
        [locationButton setTextColor:[UIColor blackColor]];
        [locationButton setBackgroundColor:[UIColor lightGrayColor]];
        [locationButton setUserInteractionEnabled:YES];
        [locationButton setFont:MULIREGULAR(16)];
        [locationButton addGestureRecognizer:locationTapGesture];
        
        [self addSubview:locationButton];
        
        UITapGestureRecognizer *interestTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(didTapInterestButtonAction:)];
        [interestTapGesture setNumberOfTapsRequired:1];
        
        interestButton = [[UILabel alloc] initWithFrame:CGRectMake(locationButton.frame.size.width, 0, locationButtonWidth, TAB_HEIGHT)];
        [interestButton setText:@"Interest"];
        [interestButton setTextAlignment:NSTextAlignmentCenter];
        [interestButton setTextColor:[UIColor blackColor]];
        [interestButton setBackgroundColor:[UIColor lightGrayColor]];
        [interestButton setUserInteractionEnabled:YES];
        [interestButton setFont:MULIREGULAR(16)];
        [interestButton addGestureRecognizer:interestTapGesture];
        
        [self addSubview:interestButton];
    }
    return self;
}

#pragma mark - ()

- (void)setLocationSelected {
    [locationButton setTextColor:[UIColor whiteColor]];
    [locationButton setBackgroundColor:baseRedColor];
    [interestButton setTextColor:[UIColor blackColor]];
    [interestButton setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)setInterestSelected {
    [locationButton setTextColor:[UIColor blackColor]];
    [locationButton setBackgroundColor:[UIColor lightGrayColor]];
    [interestButton setTextColor:[UIColor whiteColor]];
    [interestButton setBackgroundColor:baseRedColor];
}

- (void)didTapLocationButtonAction:(UIButton *)button {
    [self setLocationSelected];
    if (delegate && [delegate respondsToSelector:@selector(inviteTableHeaderView:didTapLocationButton:)]) {
        [delegate inviteTableHeaderView:self didTapLocationButton:button];
    }
}

- (void)didTapInterestButtonAction:(UIButton *)button {
    [self setInterestSelected];
    if (delegate && [delegate respondsToSelector:@selector(inviteTableHeaderView:didTapInterestButton:)]) {
        [delegate inviteTableHeaderView:self didTapInterestButton:button];
    }
}

@end
