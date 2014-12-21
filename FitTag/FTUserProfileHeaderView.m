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
@property (nonatomic, strong) UIView *profilePictureBackgroundView;

@property (nonatomic, strong) UILabel *followerCountLabel;
@property (nonatomic, strong) UILabel *followingCountLabel;
@property (nonatomic, strong) UILabel *userSettingsLabel;
@property (nonatomic, strong) UILabel *userDisplay;

@property (nonatomic, strong) UIImageView *photoCountIconImageView;
@property (nonatomic, strong) PFImageView *profilePictureImageView;
@property (nonatomic, strong) PFImageView *coverPhotoImageView;

//@property (nonatomic, strong) UITextView *profileBiography;
@property (nonatomic, strong) STTweetLabel *profileBiography;

@property (nonatomic, strong) UIButton *gridViewButton;
//@property (nonatomic, strong) UIButton *businessButton;
//@property (nonatomic, strong) UIButton *taggedInButton;
@end

@implementation FTUserProfileHeaderView
@synthesize profileFilter;
@synthesize followerCountLabel;
@synthesize photoCountIconImageView;
@synthesize followingCountLabel;
@synthesize userSettingsLabel;
@synthesize profilePictureImageView;
@synthesize profilePictureBackgroundView;
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
        profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, size.width, size.width / 2)];
        [profilePictureBackgroundView setBackgroundColor:FT_GRAY];
        [profilePictureBackgroundView setAlpha:0.0f];
        [profilePictureBackgroundView setClipsToBounds:YES];
        [self.containerView addSubview:profilePictureBackgroundView];
        
        // Profile Picture Image
        profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, (((size.height / 2) - PROFILE_IMAGE_HEIGHT)/2), PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        [profilePictureImageView setBackgroundColor:FT_RED];
        [profilePictureImageView setClipsToBounds: YES];
        [profilePictureImageView setAlpha:0.0f];
        [profilePictureImageView.layer setCornerRadius:CORNERRADIUS(PROFILE_IMAGE_WIDTH)];
        [self.containerView addSubview:profilePictureImageView];
        
        NSLog(@"coverPhoto width:%f height:%f", size.width, size.width / 2);
        
        // Cover Photo
        coverPhotoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width / 2)];
        [coverPhotoImageView setClipsToBounds:YES];
        [coverPhotoImageView setBackgroundColor:FT_GRAY];        
        [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.profilePictureBackgroundView addSubview:coverPhotoImageView];
        
        // User settings UILabel
        CGFloat userSettingsLabelY = profilePictureBackgroundView.frame.size.height + offsetY;
        userSettingsLabel = [[UILabel alloc] init];
        [userSettingsLabel setFrame:CGRectMake(0, userSettingsLabelY, self.containerView.bounds.size.width, 30)];
        [userSettingsLabel setTextAlignment:NSTextAlignmentCenter];
        [userSettingsLabel setFont:BENDERSOLID(18)];
        [userSettingsLabel setBackgroundColor:[UIColor whiteColor]];
        [userSettingsLabel setTextColor:[UIColor whiteColor]];
        [userSettingsLabel setAlpha:1.0f];
        
        [self.containerView addSubview:userSettingsLabel];
        
        // Followers count UILabel
        CGFloat followLabelsY = profilePictureBackgroundView.frame.size.height + offsetY + 30;
        CGFloat followLabelsWidth = self.containerView.bounds.size.width / 2;
        
        UITapGestureRecognizer *followedTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFollowerAction:)];
        [followedTapGesture setNumberOfTapsRequired:1];
        
        followerCountLabel = [[UILabel alloc] init];
        [followerCountLabel setFrame:CGRectMake(0, followLabelsY, followLabelsWidth, 30)];
        [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followerCountLabel setBackgroundColor:[UIColor whiteColor]];
        [followerCountLabel setTextColor:[UIColor blackColor]];
        [followerCountLabel setFont:BENDERSOLID(14)];
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
        [followingCountLabel setFont:BENDERSOLID(14)];
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
        
        //profileBiography = [[UITextView alloc] init];
        profileBiography = [[STTweetLabel alloc] init];
        [profileBiography setFrame:CGRectMake(10, settingsLabelOrgin.y + settingsLabelSize.height, size.width-5, bioHeight)];
        [profileBiography setTextColor:[UIColor blackColor]];
        [profileBiography setBackgroundColor:FT_GRAY];
        [profileBiography setFont:SYSTEMFONTBOLD(14)];
        [profileBiography setText:EMPTY_STRING];
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
        */
        
        /*
        businessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [businessButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [businessButton setBackgroundImage:[UIImage imageNamed:POSTS_IMAGE] forState:UIControlStateNormal];
        [businessButton setBackgroundImage:[UIImage imageNamed:POSTS_IMAGE_ACTIVE] forState:UIControlStateSelected];
        [businessButton setFrame:CGRectMake(0, 0, 30, 35)];
        [businessButton setCenter:CGPointMake(self.frame.size.width / 2, profileFilter.frame.size.height / 2)];
        [businessButton addTarget:self action:@selector(didTapBusinessButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [businessButton setSelected:NO];
        [profileFilter addSubview:businessButton];
        */
        
        /*
        taggedInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [taggedInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [taggedInButton setBackgroundImage:[UIImage imageNamed:TAGGED_IMAGE] forState:UIControlStateNormal];
        [taggedInButton setBackgroundImage:[UIImage imageNamed:TAGGED_IMAGE_ACTIVE] forState:UIControlStateSelected];
        [taggedInButton setFrame:CGRectMake(0, 0, 30, 35)];
        [taggedInButton setCenter:CGPointMake(self.frame.size.width - taggedInButton.frame.size.width - 20, profileFilter.frame.size.height / 2)];
        [taggedInButton addTarget:self action:@selector(didTapTaggedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [taggedInButton setSelected:NO];
        [profileFilter addSubview:taggedInButton];
        */
        
        /* // User display label
        userDisplay = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,30)];
        [userDisplay setTextAlignment:NSTextAlignmentCenter];
        [userDisplay setBackgroundColor:[UIColor clearColor]];
        [userDisplay setTextColor:[UIColor whiteColor]];
        [userDisplay setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [userDisplay setText:@"Test"];
        [userDisplay setCenter:CGPointMake((self.containerView.frame.size.width / 2),130)];
        [self.containerView addSubview:userDisplay];
        */
        
        //[self.containerView addSubview:profileFilter];
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
    NSLog(@"::- (void)fetchUserProfileData:(PFUser *)aUser: %@",aUser);
    
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
    if (coverPhotoFile) {
        [coverPhotoImageView setFile:coverPhotoFile];
        [coverPhotoImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                UIImageView *coverPhoto = [[UIImageView alloc] initWithImage:image];
                coverPhoto.frame = self.coverPhotoImageView.bounds;
                coverPhoto.alpha = 0.0f;
                coverPhoto.clipsToBounds = YES;
                
                [self.profilePictureBackgroundView addSubview:coverPhoto];
                
                [UIView animateWithDuration:0.3f animations:^{
                    coverPhoto.alpha = 1.0f;
                }];
            }
        }];
    } else {
        UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverPhotoImageView.frame];
        [coverImageView setImage:nil];
        [coverImageView setClipsToBounds:YES];
        [coverImageView setBackgroundColor:FT_GRAY];
        [self.profilePictureBackgroundView addSubview:coverImageView];
    }
    
    // Set profile photo
    PFFile *imageFile = [self.user objectForKey:kFTUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.3f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
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
        //NSLog(@"Viewing someone elses profile.");
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // Clear the button
        [userSettingsLabel setText:EMPTY_STRING];
        
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
        
        //NSLog(@"Vieweing own profile.");
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSettingsButtonAction:)];
        tap.numberOfTapsRequired = 1;
        
        [userSettingsLabel setBackgroundColor:[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:1]];
        [userSettingsLabel setTextColor:[UIColor colorWithRed:234/255.0f green:37/255.0f blue:37/255.0f alpha:1]];
        [userSettingsLabel setText:NAVIGATION_TITLE_SETTINGS];
        [userSettingsLabel addGestureRecognizer:tap];
        [userSettingsLabel setUserInteractionEnabled:YES];
        [userSettingsLabel setAlpha:1.0f];
    }
    
}

- (void)configureFollowButton {
    //NSLog(@"NOT FOLLOWING USER");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFollowButtonAction:)];
    tap.numberOfTapsRequired = 1;
    
    [[FTCache sharedCache] setFollowStatus:NO user:self.user];
    [userSettingsLabel setBackgroundColor:FT_RED];
    [userSettingsLabel setTextColor:[UIColor whiteColor]];
    [userSettingsLabel addGestureRecognizer:tap];
    [userSettingsLabel setUserInteractionEnabled:YES];
    [userSettingsLabel setText:[NSString stringWithFormat:@"FOLLOW %@",[self.user objectForKey: kFTUserDisplayNameKey]]];    
}

- (void)configureUnfollowButton {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUnfollowButtonAction:)];
    tap.numberOfTapsRequired = 1;
    
    [[FTCache sharedCache] setFollowStatus:YES user:self.user];
    [userSettingsLabel setBackgroundColor:FT_RED];
    [userSettingsLabel setTextColor:[UIColor whiteColor]];
    [userSettingsLabel addGestureRecognizer:tap];
    [userSettingsLabel setUserInteractionEnabled:YES];
    [userSettingsLabel setText:[NSString stringWithFormat:@"FOLLOWING %@",[self.user objectForKey: kFTUserDisplayNameKey]]];
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
            NSLog(@"number %d",number);
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
            NSLog(@"number %d",number);
            [followingCountLabel setText:[NSString stringWithFormat:@"%d FOLLOWING", number]];
        }
    }];
}

- (void)updateCoverPhoto:(UIImage *)photo {
    
    for (UIView *subView in self.profilePictureBackgroundView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverPhotoImageView.frame];
    [coverImageView setImage:photo];
    [coverImageView setClipsToBounds:YES];
    [coverImageView setBackgroundColor:FT_GRAY];
    [self.profilePictureBackgroundView addSubview:coverImageView];
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
