//
//  UITableViewCell+FTSocialCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSocialCell.h"

@implementation FTSocialCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)setType:(FTSocialMediaType)type {
    if (type & FTSocialMediaTypeFacebook) {
        UISwitch *facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 5, 0, 0)];
        [facebookSwitch addTarget:self action:@selector(didChangeFacebookSwitchAction:) forControlEvents:UIControlEventTouchUpInside];

        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            [facebookSwitch setOn:YES animated:YES];
        } else {
            [facebookSwitch setOn:NO animated:YES];
        }
        
        [self.contentView addSubview:facebookSwitch];
    } else if (type & FTSocialMediaTypeTwitter) {
        UISwitch *twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 5, 0, 0)];
        [twitterSwitch addTarget:self action:@selector(didChangeTwitterSwitchAction:) forControlEvents:UIControlEventTouchUpInside];

        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            [twitterSwitch setOn:YES animated:YES];
        } else {
            [twitterSwitch setOn:NO animated:YES];
        }
        
        [self.contentView addSubview:twitterSwitch];
    }
}

- (void)didChangeFacebookSwitchAction:(UISwitch *)lever {
    if (delegate && [delegate respondsToSelector:@selector(socialCell:didChangeFacebookSwitch:)]) {
        [delegate socialCell:self didChangeFacebookSwitch:lever];
    }
}

- (void)didChangeTwitterSwitchAction:(UISwitch *)lever {
    if (delegate && [delegate respondsToSelector:@selector(socialCell:didChangeTwitterSwitch:)]) {
        [delegate socialCell:self didChangeTwitterSwitch:lever];
    }
}

@end
