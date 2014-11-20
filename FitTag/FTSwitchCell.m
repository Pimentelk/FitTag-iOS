//
//  UITableViewCell+FTSocialCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSwitchCell.h"

@interface FTSwitchCell () {
    UISwitch *settingSwitch;
}
@end

@implementation FTSwitchCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        settingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 5, 0, 0)];
    }
    return self;
}

- (void)setType:(FTSwitchType)type {
    
    // Remove target
    [settingSwitch removeTarget:self action:@selector(didChangeFacebookSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [settingSwitch removeTarget:self action:@selector(didChangeTwitterSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [settingSwitch removeTarget:self action:@selector(didChangeCommentSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [settingSwitch removeTarget:self action:@selector(didChangeLikeSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [settingSwitch removeTarget:self action:@selector(didChangeFollowSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [settingSwitch removeTarget:self action:@selector(didChangeMentionSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    // Set target
    switch (type) {
        case FTSwitchTypeFacebook: {
            if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                [settingSwitch setOn:YES animated:YES];
            } else {
                [settingSwitch setOn:NO animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeFacebookSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeTwitter: {
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                [settingSwitch setOn:YES animated:YES];
            } else {
                [settingSwitch setOn:NO animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeTwitterSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeComment: {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushCommentsKey]) {
                [settingSwitch setOn:NO animated:YES];
            } else {
                [settingSwitch setOn:YES animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeCommentSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeLike: {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushLikesKey]) {
                [settingSwitch setOn:NO animated:YES];
            } else {
                [settingSwitch setOn:YES animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeLikeSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeFollow: {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey]) {
                [settingSwitch setOn:NO animated:YES];
            } else {
                [settingSwitch setOn:YES animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeFollowSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeMention: {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushMentionsKey]) {
                [settingSwitch setOn:NO animated:YES];
            } else {
                [settingSwitch setOn:YES animated:YES];
            }
            [settingSwitch addTarget:self action:@selector(didChangeMentionSwitchAction:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case FTSwitchTypeNone: {
            
        }
            break;
    }    
    [self.contentView addSubview:settingSwitch];
}

- (void)didChangeFacebookSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeFacebookSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeFacebookSwitch:)]) {
        [delegate switchCell:self didChangeFacebookSwitch:lever];
    }
}

- (void)didChangeTwitterSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeTwitterSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeTwitterSwitch:)]) {
        [delegate switchCell:self didChangeTwitterSwitch:lever];
    }
}

- (void)didChangeCommentSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeCommentSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeCommentSwitch:)]) {
        [delegate switchCell:self didChangeCommentSwitch:lever];
    }
}

- (void)didChangeLikeSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeLikeSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeLikeSwitch:)]) {
        [delegate switchCell:self didChangeLikeSwitch:lever];
    }
}

- (void)didChangeFollowSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeFollowSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeFollowSwitch:)]) {
        [delegate switchCell:self didChangeFollowSwitch:lever];
    }
}

- (void)didChangeMentionSwitchAction:(UISwitch *)lever {
    NSLog(@"didChangeMentionSwitchAction");
    if (delegate && [delegate respondsToSelector:@selector(switchCell:didChangeMentionSwitch:)]) {
        [delegate switchCell:self didChangeMentionSwitch:lever];
    }
}

@end
