//
//  UITableView+FTProfileCollectionHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTUserProfileHeaderView.h"
#import "UIImage+ImageEffects.h"

// Collection Filters
#define GRID_IMAGE @"grid_button"
#define GRID_IMAGE_ACTIVE @"grid_button_active"
#define TAGGED_IMAGE @"tagged_button"
#define TAGGED_IMAGE_ACTIVE @"tagged_button_active"
#define POSTS_IMAGE @"posts"
#define POSTS_IMAGE_ACTIVE @"posts_active"

@interface FTUserProfileHeaderView() {
    BOOL isFollowingUser;
}
@property (nonatomic, strong) UIView *profileFilter;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *headerPhotosContainer;

@property (nonatomic, strong) UILabel *followerCountLabel;
@property (nonatomic, strong) UILabel *followingCountLabel;
//@property (nonatomic, strong) UILabel *userSettingsLabel;
@property (nonatomic, strong) UILabel *userDisplay;

@property (nonatomic, strong) UIImageView *photoCountIconImageView;
@property (nonatomic, strong) PFImageView *profilePictureImageView;
@property (nonatomic, strong) PFImageView *coverPhotoImageView;

//@property (nonatomic, strong) UITextView *profileBiography;
@property (nonatomic, strong) STTweetLabel *profileBiography;

@property (nonatomic, strong) UIButton *gridViewButton;
@property (nonatomic, strong) UIButton *userSettingsButton;
@property (nonatomic, strong) UIButton *followStatusButton;
//@property (nonatomic, strong) UIButton *businessButton;
//@property (nonatomic, strong) UIButton *taggedInButton;
@end

@implementation FTUserProfileHeaderView
@synthesize userSettingsButton;
@synthesize profileFilter;
@synthesize followerCountLabel;
@synthesize photoCountIconImageView;
@synthesize followingCountLabel;
@synthesize followStatusButton;
//@synthesize userSettingsLabel;
@synthesize profilePictureImageView;
@synthesize headerPhotosContainer;
@synthesize profileBiography;
@synthesize gridViewButton;
//@synthesize businessButton;
//@synthesize taggedInButton;
@synthesize userDisplay;
@synthesize delegate;
@synthesize coverPhotoImageView;
@synthesize user;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.containerView.clipsToBounds = YES;
        self.superview.clipsToBounds = YES;
    
        self.containerView = [[UIView alloc] initWithFrame:frame];
        [self.containerView setBackgroundColor:FT_GRAY];
        [self setBackgroundColor:FT_GRAY];
        
        CGSize size = self.containerView.frame.size;
        CGFloat offsetY = 0;
        
        // Profile Picture & cover photo container
        headerPhotosContainer = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, size.width, size.width / 2)];
        [headerPhotosContainer setBackgroundColor:FT_GRAY];
        [headerPhotosContainer setAlpha:0.0f];
        [headerPhotosContainer setClipsToBounds:YES];
        [self.containerView addSubview:headerPhotosContainer];
        
        // Profile Picture Image
        profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, 20, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        [profilePictureImageView setBackgroundColor:FT_RED];
        [profilePictureImageView setClipsToBounds: YES];
        [profilePictureImageView setAlpha:0.0f];
        [profilePictureImageView.layer setCornerRadius:CORNERRADIUS(PROFILE_IMAGE_WIDTH)];
        [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.containerView addSubview:profilePictureImageView];
        
        // Cover Photo
        coverPhotoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width / 2)];
        [coverPhotoImageView setClipsToBounds:YES];
        [coverPhotoImageView setBackgroundColor:FT_GRAY];        
        [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.headerPhotosContainer addSubview:coverPhotoImageView];
        
        // User settings UILabel
        CGFloat userSettingsLabelY = headerPhotosContainer.frame.size.height + offsetY;
        
        // Settings button
        userSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [userSettingsButton addTarget:self action:@selector(didTapSettingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [userSettingsButton setFrame:CGRectMake(0, userSettingsLabelY, self.containerView.bounds.size.width, 30)];
        [userSettingsButton setBackgroundImage:[UIImage imageNamed:@"settings_button"] forState:UIControlStateNormal];
        [userSettingsButton setHidden:YES];
        [self.containerView addSubview:userSettingsButton];
        
        // Follow/Unfollow Label
        followStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followStatusButton setFrame:CGRectMake(0, userSettingsLabelY, self.containerView.bounds.size.width, 30)];
        [followStatusButton setBackgroundColor:FT_RED];
        [followStatusButton setHidden:YES];
        [self.containerView addSubview:followStatusButton];
        
        // Followers count UILabel
        CGFloat followLabelsY = headerPhotosContainer.frame.size.height + offsetY + 30;
        CGFloat followLabelsWidth = self.containerView.bounds.size.width / 2;
        
        UITapGestureRecognizer *followedTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFollowerAction:)];
        [followedTapGesture setNumberOfTapsRequired:1];
        
        followerCountLabel = [[UILabel alloc] init];
        [followerCountLabel setFrame:CGRectMake(0, followLabelsY, followLabelsWidth, 30)];
        [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followerCountLabel setBackgroundColor:[UIColor whiteColor]];
        [followerCountLabel setTextColor:[UIColor blackColor]];
        [followerCountLabel setFont:MULIREGULAR(14)];
        [followerCountLabel.layer setBorderColor:FT_GRAY.CGColor];
        [followerCountLabel.layer setBorderWidth:1.0f];
        [followerCountLabel setUserInteractionEnabled:YES];
        [followerCountLabel addGestureRecognizer:followedTapGesture];
        [followerCountLabel setText:@"0 FOLLOWERS"];
        [self.containerView addSubview:followerCountLabel];
        
        UITapGestureRecognizer *followTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFollowingAction:)];
        [followTapGesture setNumberOfTapsRequired:1];
        
        CGSize followerLabelSize = followerCountLabel.frame.size;
        
        // Following count UILabel
        followingCountLabel = [[UILabel alloc] init];
        [followingCountLabel setFrame:CGRectMake(followerLabelSize.width, followLabelsY, followLabelsWidth, 30)];
        [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followingCountLabel setBackgroundColor:[UIColor whiteColor]];
        [followingCountLabel setTextColor:[UIColor blackColor]];
        [followingCountLabel setFont:MULIREGULAR(14)];
        [followingCountLabel.layer setBorderColor:FT_GRAY.CGColor];
        [followingCountLabel.layer setBorderWidth:1.0f];
        [followingCountLabel setUserInteractionEnabled:YES];
        [followingCountLabel addGestureRecognizer:followTapGesture];
        [followingCountLabel setText:@"0 FOLLOWING"];
        [self.containerView addSubview:followingCountLabel];
        
        // User bio text view
        CGSize settingsLabelSize = followerCountLabel.frame.size;
        CGPoint settingsLabelOrgin = followerCountLabel.frame.origin;
        CGFloat bioHeight = self.frame.size.height - (settingsLabelOrgin.y + settingsLabelSize.height);
        
        profileBiography = [[STTweetLabel alloc] init];
        [profileBiography setFrame:CGRectMake(10, settingsLabelOrgin.y + settingsLabelSize.height, size.width-5, bioHeight)];
        [profileBiography setTextColor:[UIColor blackColor]];
        [profileBiography setBackgroundColor:FT_GRAY];
        [profileBiography setFont:SYSTEMFONTBOLD(14)];
        [profileBiography setText:EMPTY_STRING];
        [profileBiography setUserInteractionEnabled:NO];
        
        [self.containerView addSubview:profileBiography];
        [self addSubview:self.containerView]; // Add the view
    }
    return self;
}

#pragma mark - ()

- (void)didTapFollowerAction:(id)sender {
    //NSLog(@"- (void)didTapFollowerAction:(id)sender;");
    if(delegate && [delegate respondsToSelector:@selector(userProfileHeaderView:didTapFollowersButton:)]){
        [delegate userProfileHeaderView:self didTapFollowersButton:sender];
    }
}

- (void)didTapFollowingAction:(id)sender {
    //NSLog(@"- (void)didTapFollowingAction:(id)sender;");
    if(delegate && [delegate respondsToSelector:@selector(userProfileHeaderView:didTapFollowingButton:)]){
        [delegate userProfileHeaderView:self didTapFollowingButton:sender];
    }
}
/*
- (void)didTapGridButtonAction:(UIButton *)button {
    //NSLog(@"%@::didTapGridButtonAction:",VIEWCONTROLLER_USER_HEADER);
    if (![gridViewButton isSelected]) {
        [self resetSelectedProfileFilterButtons];
        [gridViewButton setSelected:YES];
        if(delegate && [delegate respondsToSelector:@selector(userProfileCollectionHeaderView:didTapGridButton:)]){
            [delegate userProfileCollectionHeaderView:self didTapGridButton:button];
        }
    }
}
*/
- (void)didTapSettingsButtonAction:(id)sender {
    //NSLog(@"%@::didTapTaggedButtonAction:",VIEWCONTROLLER_USER_HEADER);
    if(delegate && [delegate respondsToSelector:@selector(userProfileHeaderView:didTapSettingsButton:)]){
        [delegate userProfileHeaderView:self didTapSettingsButton:sender];
    }
}
 
- (void)resetSelectedProfileFilterButtons {
    [gridViewButton setSelected:NO];
    //[taggedInButton setSelected:NO];
    //[businessButton setSelected:NO];
}

- (void)fetchUserProfileData:(PFUser *)aUser {
    //NSLog(@"::- (void)fetchUserProfileData:(PFUser *)aUser: %@",aUser);
    
    if (!aUser) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
        return;
    }
    
    user = aUser;
    
    [self updateFollowerCount];
    [self updateFollowingCount];
    [self updateBiography:[self.user objectForKey:kFTUserBioKey]];
    
    // Set cover photo
    PFFile *coverPhotoFile = [self.user objectForKey:kFTUserCoverPhotoKey];    
    if (coverPhotoFile && ![coverPhotoFile isEqual:[NSNull null]]) {
        [coverPhotoImageView setFile:coverPhotoFile];
        [coverPhotoImageView loadInBackground];
        [coverPhotoImageView setAlpha:1];
        [headerPhotosContainer setAlpha:1];
    } else {
        UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverPhotoImageView.frame];
        [coverImageView setImage:nil];
        [coverImageView setClipsToBounds:YES];
        [coverImageView setBackgroundColor:FT_GRAY];
        [self.coverPhotoImageView addSubview:coverImageView];
    }
    
    // Set profile photo
    PFFile *imageFile = [self.user objectForKey:kFTUserProfilePicMediumKey];
    if (imageFile && ![imageFile isEqual:[NSNull null]]) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.3f animations:^{
                    headerPhotosContainer.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
    } else {
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:profilePictureImageView.frame];
        [profileImageView setImage:[UIImage imageNamed:IMAGE_PROFILE_EMPTY]];
        [profileImageView setClipsToBounds:YES];
        [profileImageView.layer setCornerRadius:CORNERRADIUS(profileImageView.frame.size.width)];
        [self addSubview:profileImageView];
    }
    
    // check to see if it is not current users profile
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        
        [userSettingsButton setHidden:YES];
        [followStatusButton setHidden:NO];
        
        //NSLog(@"Viewing someone elses profile.");
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // Clear the button
        //[userSettingsLabel setText:EMPTY_STRING];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kFTActivityClassKey];
        [queryIsFollowing whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
        [queryIsFollowing whereKey:kFTActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                //NSLog(@"Couldn't determine follow relationship: %@", error);
                //self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    } else {
        [userSettingsButton setHidden:NO];
    }
}

- (void)configureFollowButton {
    
    [followStatusButton removeTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [followStatusButton removeTarget:self action:@selector(didTapUnfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *titleString = [NSString stringWithFormat:@"FOLLOW %@",[self.user objectForKey: kFTUserDisplayNameKey]];
    
    [[FTCache sharedCache] setFollowStatus:NO user:self.user];
    [followStatusButton setBackgroundColor:FT_RED];
    [followStatusButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [followStatusButton.titleLabel setTextColor:[UIColor whiteColor]];
    [followStatusButton setTitle:titleString forState:UIControlStateNormal];
}

- (void)configureUnfollowButton {
    
    [followStatusButton removeTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [followStatusButton removeTarget:self action:@selector(didTapUnfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *titleString = [NSString stringWithFormat:@"FOLLOWING %@",[self.user objectForKey: kFTUserDisplayNameKey]];
    
    [[FTCache sharedCache] setFollowStatus:YES user:self.user];
    [followStatusButton setBackgroundColor:FT_RED];
    [followStatusButton addTarget:self action:@selector(didTapUnfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [followStatusButton.titleLabel setTextColor:[UIColor whiteColor]];
    [followStatusButton setTitle:titleString forState:UIControlStateNormal];
}

- (void)didTapFollowButtonAction:(id)sender {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    [self configureUnfollowButton];
    [FTUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            NSLog(@"followButtonAction::succeeded");
            [self updateFollowingCount];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
        }
        
        if (error) {
            NSLog(@"followButtonAction::error");
            [self configureFollowButton];
        }
    }];
}

- (void)didTapUnfollowButtonAction:(id)sender {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    [self configureFollowButton];
    [FTUtility unfollowUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            NSLog(@"unfollowButtonAction::succeeded");
            [self updateFollowingCount];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
        }
        
        if (error) {
            NSLog(@"unfollowButtonAction::error");
            [self configureUnfollowButton];
        }
    }];
}

- (void)updateFollowerCount {
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryFollowerCount whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryFollowerCount whereKey:kFTActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            //NSLog(@"number %d",number);
            [followerCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWER%@", number, number==1?@"":@"S"]];
        }
    }];
}

- (void)updateFollowingCount {
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"FOLLOWING"];
    if (followingDictionary) {
        [followingCountLabel setText:[NSString stringWithFormat:@"%lu FOLLOWING", (unsigned long)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryFollowingCount whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryFollowingCount whereKey:kFTActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryFollowingCount whereKeyExists:kFTActivityToUserKey];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            //NSLog(@"number %d",number);
            [followingCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWING", number]];
        }
    }];
}

- (void)updateCoverPhoto:(UIImage *)photo {
    
    //NSLog(@"coverPhoto:%@",photo);
    
    for (UIView *subView in self.coverPhotoImageView.subviews) {
        [subView removeFromSuperview];
    }
    
    PFFile *coverPhotoFile = [self.user objectForKey:kFTUserCoverPhotoKey];
    if (coverPhotoFile && ![coverPhotoFile isEqual:[NSNull null]]) {
        [coverPhotoImageView setFile:coverPhotoFile];
        [coverPhotoImageView loadInBackground];
    }
}

- (void)updateProfilePicture:(UIImage *)photo {
    
    for (UIView *subView in self.profilePictureImageView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:profilePictureImageView.frame];
    [profileImageView setImage:photo];
    [profileImageView setClipsToBounds:YES];
    [profileImageView.layer setCornerRadius:CORNERRADIUS(profileImageView.frame.size.width)];
    [self addSubview:profileImageView];
}

- (void)updateBiography:(NSString *)bio {
    
    // Biography
    CGFloat width = self.frame.size.width;    
    CGSize settingsLabelSize = followerCountLabel.frame.size;
    CGPoint settingsLabelOrgin = followerCountLabel.frame.origin;
    CGFloat bioHeight = self.frame.size.height - (settingsLabelOrgin.y + settingsLabelSize.height);
    
    [profileBiography setFrame:CGRectMake(5, settingsLabelOrgin.y + settingsLabelSize.height, width-10, bioHeight)];
    [profileBiography setText:bio];
    
    NSString *website = [self.user objectForKey:kFTUserWebsiteKey];
    if (website) {
        // Website
        [profileBiography setText:[NSString stringWithFormat:@"%@\n%@",profileBiography.text,website]];
    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [profileBiography setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        NSArray *hotWords = @[ HOTWORD_HANDLE, HOTWORD_HASHTAG, HOTWORD_LINK ];
        /*
         NSString *detectionString = [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""];
         */
                
        if ([hotWords[hotWord] isEqualToString:HOTWORD_HANDLE]) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userProfileHeaderView:didTapUserMention:)]) {
                [weakSelf.delegate userProfileHeaderView:weakSelf didTapUserMention:string];
            }
        } else if ([hotWords[hotWord] isEqualToString:HOTWORD_HASHTAG]) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userProfileHeaderView:didTapHashtag:)]) {
                [weakSelf.delegate userProfileHeaderView:weakSelf didTapHashtag:string];
            }
        } else if ([hotWords[hotWord] isEqualToString:HOTWORD_LINK]) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userProfileHeaderView:didTapLink:)]) {
                [weakSelf.delegate userProfileHeaderView:weakSelf didTapLink:string];
            }
        }
    }];
}

@end
