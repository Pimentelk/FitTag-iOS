//
//  FTFollowCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/28/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFollowCell.h"

#define LABEL_PADDING_TOP 15.0f
#define LABEL_PADDING 5.0f
#define FOLLOW_IMAGE_WIDTH 56.0f
#define FOLLOW_IMAGE_HEIGHT 56.0f
#define LABEL_HEIGHT 15.0f
#define FOLLOW_BUTTON_WIDTH 64.0f
#define PROFILE_IMAGE_X 10.0f

@interface FTFollowCell()
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *handleLabel;
@property (nonatomic, strong) UIButton *followUserButton;
@end

@implementation FTFollowCell
@synthesize user;
@synthesize delegate;
@synthesize profileImageView;
@synthesize titleLabel;
@synthesize handleLabel;
@synthesize followUserButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setClipsToBounds:YES];
        [self.imageView setClipsToBounds:YES];
        [self.contentView setBackgroundColor:FT_GRAY];
        self.imageView.image = nil;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProfileImageAction:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        
        // ImageView Placeholder
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_IMAGE_X, 4, FOLLOW_IMAGE_WIDTH, FOLLOW_IMAGE_HEIGHT)];
        self.profileImageView.backgroundColor = FT_RED;
        self.profileImageView.userInteractionEnabled = YES;
        self.profileImageView.layer.cornerRadius = CORNERRADIUS(profileImageView.frame.size.width);
        self.profileImageView.clipsToBounds = YES;
        [self.profileImageView addGestureRecognizer:tapGestureRecognizer];
        
        [self.contentView addSubview:profileImageView];
        
        CGFloat labelX = self.profileImageView.frame.size.width + self.profileImageView.frame.origin.x + LABEL_PADDING;
        CGFloat labelWidth = self.frame.size.width - self.profileImageView.frame.size.width - FOLLOW_BUTTON_WIDTH;
        
        // ImageView Title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, LABEL_PADDING_TOP + profileImageView.frame.origin.y,
                                                                    labelWidth, LABEL_HEIGHT)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:self.titleLabel];
        
        CGFloat handleLabelY = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 1;
        
        // ImageView sub title
        self.handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, handleLabelY, labelWidth, LABEL_HEIGHT)];
        self.handleLabel.backgroundColor = [UIColor clearColor];
        self.handleLabel.textAlignment = NSTextAlignmentLeft;
        self.handleLabel.textColor = [UIColor colorWithRed:91/255.0f green:91/255.0f blue:91/255.0f alpha:1.0f];
        self.handleLabel.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:self.handleLabel];
        
        // Follow/Unfollow Button
        self.followUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_UNSELECTED] forState:UIControlStateNormal];
        [self.followUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_SELECTED] forState:UIControlStateSelected];
        [self.followUserButton setBackgroundImage:[UIImage imageNamed:IMAGE_FOLLOW_SELECTED] forState:UIControlStateHighlighted];
        [self.followUserButton setFrame:CGRectMake(self.frame.size.width - 60, 17, 30, 30)];
        [self.followUserButton addTarget:self action:@selector(didTapFollowUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.followUserButton];
    }
    return self;
}

#pragma mark - ()

- (void)setUser:(PFUser *)aUser {
    
    user = aUser;
    
    [self.followUserButton setSelected:NO];
    [self.followUserButton setEnabled:NO];
    [self.followUserButton setHidden:YES];
    
    // If the user has a profile picture available load it
    if ([self.user objectForKey:kFTUserProfilePicSmallKey]) {
        PFFile *file = [self.user objectForKey:kFTUserProfilePicSmallKey];
        if (file && ![file isEqual:[NSNull null]]) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    self.profileImageView.image = [UIImage imageWithData:data];
                }
            }];
        } else {
            self.profileImageView.image = [UIImage imageNamed:IMAGE_PROFILE_EMPTY];
        }
    } else {
        self.profileImageView.image = [UIImage imageNamed:IMAGE_PROFILE_EMPTY];
    }
    
    NSString *firstname = EMPTY_STRING;
    if ([self.user objectForKey:kFTUserFirstnameKey]) {
        if (![[self.user objectForKey:kFTUserFirstnameKey] isEqualToString:EMPTY_STRING]) {
            firstname = [self.user objectForKey:kFTUserFirstnameKey];
        }
    }
    
    NSString *lastname = EMPTY_STRING;
    if ([self.user objectForKey:kFTUserLastnameKey]) {
        if (![[self.user objectForKey:kFTUserLastnameKey] isEqualToString:EMPTY_STRING]) {
            lastname = [self.user objectForKey:kFTUserLastnameKey];
        }
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",firstname,lastname];
    self.handleLabel.text = [NSString stringWithFormat:@"%@",[self.user objectForKey:kFTUserDisplayNameKey]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCellAction:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    
    [self.contentView setUserInteractionEnabled:YES];
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
    
    if ([[PFUser currentUser].objectId isEqual:[self.user objectId]]) {
        [followUserButton setHidden:YES];
        return;
    }
    
    // check if the currentUser is following this user
    PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryIsFollowing whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryIsFollowing whereKey:kFTActivityToUserKey equalTo:self.user];
    [queryIsFollowing whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
    __block BOOL cachedResults = YES;
    [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error && [error code] != kPFErrorCacheMiss) {
            NSLog(@"Couldn't determine follow relationship: %@", error);
        } else {
            
            // Not following
            if (number == 0) {
                [self.followUserButton setSelected:NO];
                [[FTCache sharedCache] setFollowStatus:NO user:self.user];
            } else { // Following user
                [self.followUserButton setSelected:YES];
                [[FTCache sharedCache] setFollowStatus:YES user:self.user];
            }
            
            if (cachedResults) {
                cachedResults = NO;
            } else {
                [self.followUserButton setEnabled:YES];
                [self.followUserButton setHidden:NO];
            }
        }
    }];
}

#pragma mark - FTFollowCellDelegate

- (void)didTapFollowUserButtonAction:(UIButton *)button {
    NSLog(@"FTFollow::didTapFollowUserButtonAction:");
    [button setEnabled:NO];
    
    if ([button isSelected]) {
        [FTUtility unfollowUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
            if (error) {
                [button setSelected:YES];
            } else {
                //NSLog(@"unfollowed user..");
                [button setSelected:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
                
                if ([[self.user objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
                }
            }
            [button setEnabled:YES];
        }];
    } else {
        [FTUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
            if (error) {
                [button setSelected:NO];
            } else {
                //NSLog(@"followed user..");
                [button setSelected:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
                
                if ([[self.user objectForKey:kFTUserTypeKey] isEqualToString:kFTUserTypeBusiness]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
                }
            }
            [button setEnabled:YES];
        }];
    }
}

- (void)didTapCellAction:(id)sender {
    //NSLog(@"%@::didTapProfileImageAction:",VIEWCONTROLLER_FOLLOW_CELL);
    if (delegate && [delegate respondsToSelector:@selector(followCell:didTapProfileImage:user:)]) {
        [delegate followCell:self didTapProfileImage:sender user:user];
    }
}

- (void)didTapProfileImageAction:(id)sender {
    //NSLog(@"%@::didTapProfileImageAction:",VIEWCONTROLLER_FOLLOW_CELL);
    if (delegate && [delegate respondsToSelector:@selector(followCell:didTapProfileImage:user:)]) {
        [delegate followCell:self didTapProfileImage:sender user:user];
    }
}

@end
