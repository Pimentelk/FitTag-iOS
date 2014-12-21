//
//  UIToolbar+rgarg.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/8/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileHeaderView.h"

// Widget bar Images
#define GETTHERE_IMAGE @"business_getthere"
#define CALL_IMAGE @"business_call"
#define VIDEO_IMAGE @"business_video"
#define EMAIL_IMAGE @"business_email"
#define FOLLOW_IMAGE @"business_follow"

// Collection Filters
#define GRID_IMAGE @"grid_button"
#define GRID_IMAGE_ACTIVE @"grid_button_active"
#define TAGGED_IMAGE @"tagged_button"
#define TAGGED_IMAGE_ACTIVE @"tagged_button_active"
#define POSTS_IMAGE @"posts"
#define POSTS_IMAGE_ACTIVE @"posts_active"

@interface FTBusinessProfileHeaderView()
@property (nonatomic, strong) UIView *profileFilter;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *profilePictureBackgroundView;
@property (nonatomic, strong) UIView *businessMenuBackground;

@property (nonatomic, strong) UILabel *followerCountLabel;
@property (nonatomic, strong) UILabel *followingCountLabel;
@property (nonatomic, strong) UILabel *userDisplay;

@property (nonatomic, strong) UIImageView *photoCountIconImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) PFImageView *profilePictureImageView;

@property (nonatomic, strong) UITextView *profileBiography;

@property (nonatomic, strong) UIButton *gridViewButton;
@property (nonatomic, strong) UIButton *businessButton;
@property (nonatomic, strong) UIButton *taggedInButton;

@property (nonatomic, strong) UIButton *unfollowButton;
@property (nonatomic, strong) UIButton *followButton;

@property (nonatomic, strong) PFImageView *coverPhotoImageView;
@end

@implementation FTBusinessProfileHeaderView
@synthesize profileFilter;
@synthesize followerCountLabel;
@synthesize followingCountLabel;
@synthesize photoCountIconImageView;
@synthesize businessMenuBackground;
@synthesize profilePictureImageView;
@synthesize profilePictureBackgroundView;
@synthesize profileBiography;
@synthesize gridViewButton;
@synthesize businessButton;
@synthesize taggedInButton;
@synthesize backgroundImageView;
@synthesize userDisplay;
@synthesize delegate;
@synthesize coverPhotoImageView;
@synthesize unfollowButton;
@synthesize followButton;
@synthesize isFollowing;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.containerView.clipsToBounds = YES;
        self.superview.clipsToBounds = YES;
        
        self.containerView = [[UIView alloc] initWithFrame:frame];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];
        
        // Profile Picture Backgroudn
        profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        [profilePictureBackgroundView setBackgroundColor:[UIColor clearColor]];
        [profilePictureBackgroundView setAlpha: 0.0f];
        [profilePictureBackgroundView setClipsToBounds: YES];
        [self.containerView addSubview:profilePictureBackgroundView];
        
        // Profile Picture Image
        profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        [profilePictureImageView setClipsToBounds: YES];
        //[profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.containerView addSubview:profilePictureImageView];
        
        // Cover Photo
        coverPhotoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
        [coverPhotoImageView setClipsToBounds: YES];
        [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.containerView addSubview:coverPhotoImageView];
        
        //UIImageView *profileHexagon = [FTUtility getProfileHexagonWithX:5 Y:40 width:100 hegiht:115];
        //[profileHexagon setCenter:CGPointMake((self.frame.size.width / 2), 10 + (profileHexagon.frame.size.height / 2))];
        [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        //profilePictureImageView.frame = profileHexagon.frame;
        //profilePictureImageView.layer.mask = profileHexagon.layer.mask;
        profilePictureImageView.frame = CGRectMake(5, 40, 100, 100);
        profilePictureImageView.layer.cornerRadius = CORNERRADIUS(100);
        profilePictureImageView.clipsToBounds = YES;
        profilePictureImageView.alpha = 0.0;
        
        // Followers count UILabel
        CGFloat followLabelsY = profilePictureBackgroundView.frame.size.height;
        CGFloat followLabelsWidth = self.containerView.bounds.size.width / 2;
        
        UITapGestureRecognizer *followerLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(didTapFollowerAction:)];
        [followerLabelTapGesture setNumberOfTapsRequired:1];
        
        followerCountLabel = [[UILabel alloc] init];
        [followerCountLabel setFrame:CGRectMake(0, followLabelsY, followLabelsWidth, 30)];
        [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followerCountLabel setBackgroundColor:[UIColor whiteColor]];
        [followerCountLabel setTextColor:[UIColor blackColor]];
        [followerCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [followerCountLabel.layer setBorderColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1].CGColor];
        [followerCountLabel.layer setBorderWidth:1.0f];
        [followerCountLabel setUserInteractionEnabled:YES];
        [followerCountLabel addGestureRecognizer:followerLabelTapGesture];
        [followerCountLabel setText:@"0 FOLLOWERS"];
        [self.containerView addSubview:followerCountLabel];
        
        UITapGestureRecognizer *followingLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFollowingAction:)];
        [followingLabelTapGesture setNumberOfTapsRequired:1];
        
        // Following count UILabel
        followingCountLabel = [[UILabel alloc] init];
        [followingCountLabel setFrame:CGRectMake(followerCountLabel.frame.size.width, followLabelsY, followLabelsWidth, 30)];
        [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followingCountLabel setBackgroundColor:[UIColor whiteColor]];
        [followingCountLabel setTextColor:[UIColor blackColor]];
        [followingCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [followingCountLabel.layer setBorderColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1].CGColor];
        [followingCountLabel.layer setBorderWidth:1.0f];
        [followingCountLabel setUserInteractionEnabled:YES];
        [followingCountLabel addGestureRecognizer:followingLabelTapGesture];
        [followingCountLabel setText:@"0 FOLLOWING"];
        [self.containerView addSubview:followingCountLabel];
        
        // User menu background
        businessMenuBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, followingCountLabel.frame.size.height + profilePictureBackgroundView.frame.size.height,
                                                                          self.frame.size.width, 51)];
        [businessMenuBackground setBackgroundColor:[UIColor redColor]];
        
        // User menu buttons
        UIButton *gethereButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [gethereButton setBackgroundImage:[UIImage imageNamed:GETTHERE_IMAGE] forState:UIControlStateNormal];
        [gethereButton addTarget:self action:@selector(didTapGetThereButtonAction:) forControlEvents:UIControlEventTouchDown];
        [gethereButton setFrame:CGRectMake(0, 0, 60, self.businessMenuBackground.frame.size.height)];
        [businessMenuBackground addSubview:gethereButton];
        
        UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [callButton setBackgroundImage:[UIImage imageNamed:CALL_IMAGE] forState:UIControlStateNormal];
        [callButton addTarget:self action:@selector(didTapCallButtonAction:) forControlEvents:UIControlEventTouchDown];
        [callButton setFrame:CGRectMake(gethereButton.frame.size.width + gethereButton.frame.origin.x, 0, 60, self.businessMenuBackground.frame.size.height)];
        [businessMenuBackground addSubview:callButton];
        
        UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton setBackgroundImage:[UIImage imageNamed:VIDEO_IMAGE] forState:UIControlStateNormal];
        [videoButton addTarget:self action:@selector(didTapVideoButtonAction:) forControlEvents:UIControlEventTouchDown];
        [videoButton setFrame:CGRectMake(callButton.frame.size.width + callButton.frame.origin.x, 0, 80, self.businessMenuBackground.frame.size.height)];
        [businessMenuBackground addSubview:videoButton];
        
        UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emailButton setBackgroundImage:[UIImage imageNamed:EMAIL_IMAGE] forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(didTapEmailButtonAction:) forControlEvents:UIControlEventTouchDown];
        [emailButton setFrame:CGRectMake(videoButton.frame.size.width + videoButton.frame.origin.x, 0, 67, self.businessMenuBackground.frame.size.height)];
        [businessMenuBackground addSubview:emailButton];
        
        unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [unfollowButton setBackgroundImage:IMAGE_BUSINESS_UNFOLLOW forState:UIControlStateNormal];
        [unfollowButton addTarget:self action:@selector(didTapUnfollowButtonAction:) forControlEvents:UIControlEventTouchDown];
        [unfollowButton setFrame:CGRectMake(emailButton.frame.size.width + emailButton.frame.origin.x, 0, 53, self.businessMenuBackground.frame.size.height)];
        [unfollowButton setHidden:YES];
        [businessMenuBackground addSubview:unfollowButton];
        
        followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [followButton setBackgroundImage:[UIImage imageNamed:FOLLOW_IMAGE] forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchDown];
        [followButton setFrame:CGRectMake(emailButton.frame.size.width + emailButton.frame.origin.x, 0, 53, self.businessMenuBackground.frame.size.height)];
        [followButton setHidden:YES];
        [businessMenuBackground addSubview:followButton];
        
        [self.containerView addSubview:businessMenuBackground];
        [self.containerView bringSubviewToFront:businessMenuBackground];
        
        CGFloat bioY = businessMenuBackground.frame.origin.y + businessMenuBackground.frame.size.height;
        CGFloat bioHeight = self.frame.size.height - bioY;
        
        // User bio text view
        profileBiography = [[UITextView alloc] initWithFrame:CGRectMake(0, bioY, self.frame.size.width, bioHeight)];
        [profileBiography setBackgroundColor:FT_GRAY];
        [profileBiography setTextColor:[UIColor blackColor]];
        [profileBiography setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [profileBiography setText:DEFAULT_BIO_TEXT_B];
        [profileBiography setUserInteractionEnabled:NO];
        [self.containerView addSubview:profileBiography];
        
        /*
        // Image filter
        profileFilter = [[UIView alloc] initWithFrame:CGRectMake(0, profileBiography.frame.size.height + profileBiography.frame.origin.y,self.frame.size.width, 60)];
        [profileFilter setBackgroundColor:[UIColor whiteColor]];
        
        gridViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [gridViewButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [gridViewButton setBackgroundImage:[UIImage imageNamed:GRID_IMAGE] forState:UIControlStateNormal];
        [gridViewButton setBackgroundImage:[UIImage imageNamed:GRID_IMAGE_ACTIVE] forState:UIControlStateSelected];
        [gridViewButton setFrame:CGRectMake(0, 0, 35, 35)];
        [gridViewButton setCenter:CGPointMake( 20 + gridViewButton.frame.size.width, profileFilter.frame.size.height / 2)];
        [gridViewButton addTarget:self action:@selector(didTapGridButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [gridViewButton setSelected:YES];
        [profileFilter addSubview:gridViewButton];
        
        businessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [businessButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [businessButton setBackgroundImage:[UIImage imageNamed:POSTS_IMAGE] forState:UIControlStateNormal];
        [businessButton setBackgroundImage:[UIImage imageNamed:POSTS_IMAGE_ACTIVE] forState:UIControlStateSelected];
        [businessButton setFrame:CGRectMake(0, 0, 30, 35)];
        [businessButton setCenter:CGPointMake(self.frame.size.width / 2, profileFilter.frame.size.height / 2)];
        [businessButton addTarget:self action:@selector(didTapBusinessButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [businessButton setSelected:NO];
        [profileFilter addSubview:businessButton];
        
        taggedInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [taggedInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [taggedInButton setBackgroundImage:[UIImage imageNamed:TAGGED_IMAGE] forState:UIControlStateNormal];
        [taggedInButton setBackgroundImage:[UIImage imageNamed:TAGGED_IMAGE_ACTIVE] forState:UIControlStateSelected];
        [taggedInButton setFrame:CGRectMake(0, 0, 30, 35)];
        [taggedInButton setCenter:CGPointMake(self.frame.size.width - taggedInButton.frame.size.width - 20, profileFilter.frame.size.height / 2)];
        [taggedInButton addTarget:self action:@selector(didTapTaggedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [taggedInButton setSelected:NO];
        [profileFilter addSubview:taggedInButton];
        
        
        [self.containerView addSubview:profileFilter];
         */
        
        [self addSubview:self.containerView]; // Add the view
    }
    return self;
}

#pragma mark - FTBusinessProfileHeaderViewDelegate

- (void)didTapGridButtonAction:(UIButton *)button {
    //NSLog(@"didTapGridButtonAction");
    if (![gridViewButton isSelected]) {
        [self resetSelectedProfileFilterButtons];
        [gridViewButton setSelected:YES];
        if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapGridButton:)]){
            [delegate businessProfileHeaderView:self didTapGridButton:button];
        }
    }
}

- (void)didTapBusinessButtonAction:(UIButton *)button {
    NSLog(@"didTapBusinessButtonAction");
    if (![businessButton isSelected]) {
        [self resetSelectedProfileFilterButtons];
        [businessButton setSelected:YES];
        if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapBusinessButton:)]){
            [delegate businessProfileHeaderView:self didTapBusinessButton:button];
        }
    }
}

- (void)didTapTaggedButtonAction:(UIButton *)button {
    NSLog(@"didTapTaggedButtonAction");
    if (![taggedInButton isSelected]) {
        [self resetSelectedProfileFilterButtons];
        [taggedInButton setSelected:YES];
        if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapTaggedButton:)]){
            [delegate businessProfileHeaderView:self didTapTaggedButton:button];
        }
    }
}

- (void)didTapSettingsButtonAction:(id)sender {
    NSLog(@"didTapSettingsButtonAction");
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapSettingsButton:)]){
        [delegate businessProfileHeaderView:self didTapSettingsButton:sender];
    }
}

- (void)didTapGetThereButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapGetThereButton:)]){
        [delegate businessProfileHeaderView:self didTapGetThereButton:button];
    }
}

- (void)didTapCallButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapCallButton:)]){
        [delegate businessProfileHeaderView:self didTapCallButton:button];
    }
}

- (void)didTapVideoButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapVideoButton:)]){
        [delegate businessProfileHeaderView:self didTapVideoButton:button];
    }
}

- (void)didTapEmailButtonAction:(UIButton *)button {
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapEmailButton:)]){
        [delegate businessProfileHeaderView:self didTapEmailButton:button];
    }
}

/*
- (void)didTapUnfollowButtonAction:(UIButton *)button {
    NSLog(@"didTapFollowButtonAction:");
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapUnfollowButton:)]){
        [delegate businessProfileHeaderView:self didTapUnfollowButton:button];
    }
}

- (void)didTapFollowButtonAction:(UIButton *)button {
    NSLog(@"didTapFollowButtonAction:");
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapFollowButton:)]){
        [delegate businessProfileHeaderView:self didTapFollowButton:button];
    }
}
*/

#pragma mark - ()

- (void)didTapFollowerAction:(id)sender {
    //NSLog(@"- (void)didTapFollowerAction:(id)sender;");
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapFollowersButton:)]){
        [delegate businessProfileHeaderView:self didTapFollowersButton:sender];
    }
}

- (void)didTapFollowingAction:(id)sender {
    //NSLog(@"- (void)didTapFollowingAction:(id)sender;");
    if(delegate && [delegate respondsToSelector:@selector(businessProfileHeaderView:didTapFollowingButton:)]){
        [delegate businessProfileHeaderView:self didTapFollowingButton:sender];
    }
}

- (void)resetSelectedProfileFilterButtons {
    [gridViewButton setSelected:NO];
    [taggedInButton setSelected:NO];
    [businessButton setSelected:NO];
}

- (void)fetchBusinessProfileData:(PFUser *)aBusiness {
    NSLog(@"fetchBusinessProfileData");
    
    if (!aBusiness) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
    }
    
    PFFile *coverPhotoFile = [self.business objectForKey:kFTUserCoverPhotoKey];
    if (coverPhotoFile) {
        [coverPhotoImageView setFile:coverPhotoFile];
        [coverPhotoImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                UIImageView *coverPhoto = [[UIImageView alloc] initWithImage:image];
                coverPhoto.frame = self.bounds;
                coverPhoto.alpha = 0.0f;
                coverPhoto.clipsToBounds = YES;
                
                [self.containerView addSubview:coverPhoto];
                [self.containerView sendSubviewToBack:coverPhoto];
                
                [UIView animateWithDuration:0.2f animations:^{
                    coverPhoto.alpha = 1.0f;
                }];
            }
        }];
    }
    
    PFFile *imageFile = [self.business objectForKey:kFTUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.2f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
                
                backgroundImageView = [[UIImageView alloc] initWithImage:image];
                backgroundImageView.frame = self.bounds;
                backgroundImageView.alpha = 0.0f;
                backgroundImageView.clipsToBounds = YES;
                
                [self.containerView addSubview:backgroundImageView];
                [self.containerView sendSubviewToBack:backgroundImageView];
                
                [UIView animateWithDuration:0.2f animations:^{
                    backgroundImageView.alpha = 1.0f;
                }];
            }
        }];
    }
    
    [followerCountLabel setText:@"0 FOLLOWERS"];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryFollowerCount whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryFollowerCount whereKey:kFTActivityToUserKey equalTo:self.business];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWER%@", number, number==1?@"":@"S"]];
        }
    }];
    
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"FOLLOWING"];
    [followingCountLabel setText:@"0 FOLLOWING"];
    if (followingDictionary) {
        [followingCountLabel setText:[NSString stringWithFormat:@"%lu FOLLOWING", (unsigned long)[[followingDictionary allValues] count]]];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryFollowingCount whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryFollowingCount whereKey:kFTActivityFromUserKey equalTo:self.business];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWING", number]];
        }
    }];
    
    if (![[self.business objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kFTActivityClassKey];
        [queryIsFollowing whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
        [queryIsFollowing whereKey:kFTActivityToUserKey equalTo:self.business];
        [queryIsFollowing whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                //self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    isFollowing = NO;
                } else {
                    isFollowing = YES;
                }
                [self configureFollowButtons];
            }
        }];
    }    
    [profileBiography setText:[self.business objectForKey:kFTUserBioKey]];
}

- (void)configureFollowButtons {
    if (isFollowing) { // following
        //NSLog(@"configureFollowButtons: User is following this business.");
        [followButton setHidden:YES];
        [unfollowButton setHidden:NO];
    } else { // not following
        //NSLog(@"configureFollowButtons: User is not following this business.");
        [followButton setHidden:NO];
        [unfollowButton setHidden:YES];
    }
}

- (void)didTapFollowButtonAction:(UIButton *)button {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    
    [FTUtility followUserEventually:self.business block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self updateFollowingCount];
            
            isFollowing = YES;
            [self configureFollowButtons];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
        } else {
            NSLog(@"followButtonAction::error");
        }
    }];
}

- (void)didTapUnfollowButtonAction:(UIButton *)button {
    //UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //[loadingActivityIndicatorView startAnimating];
    
    [FTUtility unfollowUserEventually:self.business block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self updateFollowingCount];
            
            isFollowing = NO;
            [self configureFollowButtons];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityBusinessFollowingChangedNotification object:nil];
        } else {
            NSLog(@"unfollowButtonAction::error");
        }
    }];
}

- (void)updateFollowingCount {
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kFTActivityClassKey];
    [queryFollowerCount whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [queryFollowerCount whereKey:kFTActivityToUserKey equalTo:self.business];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWER%@", number, number==1?@"":@"S"]];
        }
    }];
}


@end
