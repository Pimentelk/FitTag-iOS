//
//  FTAccountHeaderView+FTSettingsDetailViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsDetailViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "AppDelegate.h"

#define LEFT_PADDING 15
#define TOP_PADDING 20
#define TABLE_CELL_HEIGHT 45

// Profile Image Options
#define PROFILE_BUTTON_HEIGHT 40
#define ROW_HEIGHT PROFILE_BUTTON_HEIGHT
#define PROFILE_BUTTON_COUNT 3
#define FACEBOOK_PHOTO @"Facebook Profile Image"
#define TWITTER_PHOTO @"Twitter Profile Image"
#define TAKE_PHOTO @"Add Photo"
#define CROP_PHOTO @"Crop Photo"
#define CLEAR_PHOTO @"Clear Photo"
#define SELECT_PHOTO @"Select Photo"
#define PROFILE_UPDATED @"Profile image updated"

#define REUSABLE_IDENTIFIER_SOCIAL @"SocialCell"


@interface FTSettingsDetailViewController () {
    CGFloat navigationBarEnd;
    UIButton *facebookImageButton;
    UIButton *twitterImageButton;
    UIButton *takePhotoButton;
    UIButton *cropPhotoButton;
    UIButton *clearPhotoButton;
    UIButton *selectPhotoButton;
    UIScrollView *scrollView;
    UILabel *missingCoverPhotoLabel;
}
@property (nonatomic, strong) UIImageView *userProfileImageView;
@property (nonatomic, strong) UIImageView *coverPhotoImageView;

@property (nonatomic, strong) UITextView *userBiography;
@property (nonatomic, strong) UITextField *userFirstname;
@property (nonatomic, strong) UITextField *userLastname;
@property (nonatomic, strong) UITextField *userHandle;
@property (nonatomic, strong) UITextField *userWebsite;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *webViewNavigationBar;
@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;

@property (nonatomic, strong) FTCropImageViewController *cropImageViewController;
@end

@implementation FTSettingsDetailViewController
@synthesize userBiography;
@synthesize webView;
@synthesize webViewNavigationBar;
@synthesize userProfileImageView;
@synthesize doneButtonItem;
@synthesize backButtonItem;
@synthesize coverPhotoImageView;
@synthesize userFirstname;
@synthesize userLastname;
@synthesize userHandle;
@synthesize userWebsite;
@synthesize cropImageViewController;

#pragma mark - Managing the detail item

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_SETTINGS_DETAIL];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        // Toolbar & Navigationbar Setup
        
        if (webViewNavigationBar) {
            [webViewNavigationBar setHidden:YES];
            [webViewNavigationBar removeFromSuperview];
            webViewNavigationBar = nil;
            self.navigationItem.titleView = nil;
        }
        
        [self.navigationItem setTitle:self.detailItem];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
        
        // Remove all subviews
        
        [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
        // Check for config type
        //NSLog(@"%@ self.detailItem: %@",VIEWCONTROLLER_SETTINGS_DETAIL, self.detailItem);
        
        if ([self.detailItem isEqualToString:PROFILE_PICTURE]) {
            [self configureProfilePicture];
        } else if ([self.detailItem isEqualToString:COVER_PHOTO]) {
            [self configureCoverPhoto];
        } else if ([self.detailItem isEqualToString:EDIT_BIO]) {
            [self configureBiography];
        } else if ([self.detailItem isEqualToString:SHARE_SETTINGS]) {
            [self configureShareSettings];
        } else if ([self.detailItem isEqualToString:NOTIFICATION_SETTINGS]) {
            [self configureNotificationsSettings];
        } else if ([self.detailItem isEqualToString:REWARD_SETTIGNS]) {
            [self configureRewardSettings];
        } else if ([self.detailItem isEqualToString:FITTAG_BLOG]) {
            [self configureBlog];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Override the back idnicator
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Back button
    backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Done button
    doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(didTapDoneButtonAction:)];
    [doneButtonItem setStyle:UIBarButtonItemStylePlain];
    [doneButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setRightBarButtonItem:doneButtonItem];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

#pragma mark - config

- (void)configureProfilePicture {
    //NSLog(@"%@::configureProfilePicture",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Navigation bar ends
    navigationBarEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    // Set current profile image
    userProfileImageView = [[UIImageView alloc] init];
    [userProfileImageView setFrame:CGRectMake(0, navigationBarEnd, self.view.frame.size.width, self.view.frame.size.width)];
    [userProfileImageView setClipsToBounds:YES];
    
    PFUser *user = [PFUser currentUser];
    PFFile *file = [user objectForKey:kFTUserProfilePicMediumKey];
    
    if (file && ![file isEqual:[NSNull null]]) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *profileImage = [UIImage imageWithData:data];
                [userProfileImageView setImage:profileImage];
                [userProfileImageView setContentMode:UIViewContentModeScaleAspectFit];
                [self.view addSubview:userProfileImageView];
            }
        }];
    }
    
    // Setup and position the profile buttons
    CGFloat profileImageViewEnd = userProfileImageView.frame.size.height + userProfileImageView.frame.origin.y;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat firstButtonPositionY = profileImageViewEnd + (((self.view.frame.size.height - profileImageViewEnd) - (PROFILE_BUTTON_HEIGHT * PROFILE_BUTTON_COUNT)) / 2);
    
    facebookImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookImageButton setFrame:CGRectMake(0, firstButtonPositionY, frameWidth, PROFILE_BUTTON_HEIGHT)];
    [facebookImageButton setBackgroundColor:[UIColor whiteColor]];
    [facebookImageButton setTitle:FACEBOOK_PHOTO forState:UIControlStateNormal];
    [facebookImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [facebookImageButton addTarget:self action:@selector(didTapFacebookImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [facebookImageButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [facebookImageButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    [self.view addSubview:facebookImageButton];
    
    CGFloat twitterButtonPosition = facebookImageButton.frame.size.height + facebookImageButton.frame.origin.y + 1;
    twitterImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterImageButton setFrame:CGRectMake(0, twitterButtonPosition, frameWidth, PROFILE_BUTTON_HEIGHT)];
    [twitterImageButton setBackgroundColor:[UIColor whiteColor]];
    [twitterImageButton setTitle:TWITTER_PHOTO forState:UIControlStateNormal];
    [twitterImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [twitterImageButton addTarget:self action:@selector(didTapTwitterImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [twitterImageButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [twitterImageButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    [self.view addSubview:twitterImageButton];
    
    CGFloat takePhotoPosition = twitterImageButton.frame.size.height + twitterImageButton.frame.origin.y + 1;
    takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton setFrame:CGRectMake(0, takePhotoPosition, frameWidth, PROFILE_BUTTON_HEIGHT)];
    [takePhotoButton setBackgroundColor:[UIColor whiteColor]];
    [takePhotoButton setTitle:TAKE_PHOTO forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(didTapTakePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [takePhotoButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    [self.view addSubview:takePhotoButton];
}

- (void)configureCoverPhoto {
   // NSLog(@"%@::configureCoverPhoto",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Navigation bar ends
    navigationBarEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    CGSize viewSize = self.view.frame.size;
    
    coverPhotoImageView = [[UIImageView alloc] init];
    [coverPhotoImageView setFrame:CGRectMake(0, navigationBarEnd, viewSize.width, viewSize.width / 2)];
    [coverPhotoImageView setClipsToBounds:YES];
    
    PFUser *user = [PFUser currentUser];
    PFFile *file = [user objectForKey:kFTUserCoverPhotoKey];
    
    if (file && ![file isEqual:[NSNull null]]) {
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *profileImage = [UIImage imageWithData:data];
                [coverPhotoImageView setImage:profileImage];
                [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFit];
                [self.view addSubview:coverPhotoImageView];
            }
        }];
        
    } else {
        
        missingCoverPhotoLabel = [[UILabel alloc] initWithFrame:coverPhotoImageView.frame];
        [missingCoverPhotoLabel setTextAlignment: NSTextAlignmentCenter];
        [missingCoverPhotoLabel setUserInteractionEnabled:NO];
        [missingCoverPhotoLabel setFont:MULIREGULAR(24)];
        [missingCoverPhotoLabel setTextColor: [UIColor blackColor]];
        [missingCoverPhotoLabel setText:@"No Cover Photo Found"];
        
        [coverPhotoImageView addSubview:missingCoverPhotoLabel];
        [self.view addSubview:coverPhotoImageView];
    }
    
    // Setup and position the take photo button
    
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat profileImageViewEnd = (frameWidth / 2) + navigationBarEnd;
    
    takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton setFrame:CGRectMake(0, profileImageViewEnd, frameWidth, PROFILE_BUTTON_HEIGHT)];
    [takePhotoButton setBackgroundColor:[UIColor whiteColor]];
    [takePhotoButton setTitle:TAKE_PHOTO forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(didTapTakeCoverPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [takePhotoButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    CGRect takePhotoFrame = takePhotoButton.frame;
    takePhotoFrame.origin.y = takePhotoFrame.size.height + takePhotoFrame.origin.y;
    /*
    cropPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cropPhotoButton setFrame:takePhotoFrame];
    [cropPhotoButton setBackgroundColor:[UIColor whiteColor]];
    [cropPhotoButton setTitle:CROP_PHOTO forState:UIControlStateNormal];
    [cropPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cropPhotoButton addTarget:self action:@selector(didTapCropCoverPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cropPhotoButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [cropPhotoButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    CGRect cropPhotoFrame = cropPhotoButton.frame;
    cropPhotoFrame.origin.y = cropPhotoFrame.size.height + cropPhotoFrame.origin.y;
    */
    clearPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[clearPhotoButton setFrame:cropPhotoFrame];
    [clearPhotoButton setFrame:takePhotoFrame];
    [clearPhotoButton setBackgroundColor:[UIColor whiteColor]];
    [clearPhotoButton setTitle:CLEAR_PHOTO forState:UIControlStateNormal];
    [clearPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearPhotoButton addTarget:self action:@selector(didTapClearCoverPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [clearPhotoButton addTarget:self action:@selector(didHighlightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [clearPhotoButton addTarget:self action:@selector(clearProfileImageButtons) forControlEvents:UIControlEventTouchDragExit];
    
    [self.view addSubview:takePhotoButton];
    [self.view bringSubviewToFront:takePhotoButton];
    
    [self.view addSubview:cropPhotoButton];
    [self.view bringSubviewToFront:cropPhotoButton];
    
    [self.view addSubview:clearPhotoButton];
    [self.view bringSubviewToFront:clearPhotoButton];
}

- (void)didGestureHideKeyboardAction {
    [userFirstname resignFirstResponder];
    [userLastname resignFirstResponder];
    [userHandle resignFirstResponder];
    [userWebsite resignFirstResponder];
    [userBiography resignFirstResponder];
}

- (void)configureBiography {
    //NSLog(@"%@::configureBiography",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Set the current user
    PFUser *user = [PFUser currentUser];
    
    // Navigation bar ends
    CGRect navFrame = self.navigationController.navigationBar.frame;
    navigationBarEnd = navFrame.size.height + navFrame.origin.y;
    
    // Navigation bar ends
    CGSize frameSize = self.view.frame.size;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navigationBarEnd, frameSize.width, frameSize.height)];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureHideKeyboardAction)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureHideKeyboardAction)];
    [tapGesture setNumberOfTapsRequired:1];
    
    [scrollView setGestureRecognizers:@[ swipeGesture, tapGesture ]];
    
    CGFloat textViewX = 10;
    CGFloat textViewHeight = 30;
    CGFloat textViewWidth = self.view.frame.size.width - (textViewX * 2);
    
    userFirstname = [[UITextField alloc] initWithFrame:CGRectMake(textViewX, TOP_PADDING, textViewWidth, textViewHeight)];
    [userFirstname setPlaceholder:@"FIRST NAME"];
    [userFirstname setBackgroundColor:FT_GRAY];
    [userFirstname setFont:HelveticaNeue(14)];
    [userFirstname setDelegate:self];
    if ([user objectForKey:kFTUserFirstnameKey]) {
        [userFirstname setText:[user objectForKey:kFTUserFirstnameKey]];
    }
    [scrollView addSubview:userFirstname];
    
    CGFloat userLastnameY = userFirstname.frame.size.height + userFirstname.frame.origin.y + TOP_PADDING;
    userLastname = [[UITextField alloc] initWithFrame:CGRectMake(textViewX, userLastnameY, textViewWidth, textViewHeight)];
    [userLastname setPlaceholder:@"LAST NAME"];
    [userLastname setBackgroundColor:FT_GRAY];
    [userLastname setFont:HelveticaNeue(14)];
    [userLastname setDelegate:self];
    
    if ([user objectForKey:kFTUserLastnameKey]) {
        [userLastname setText:[user objectForKey:kFTUserLastnameKey]];
    }
    
    [scrollView addSubview:userLastname];
    
    CGFloat userHandleY = userLastname.frame.size.height + userLastname.frame.origin.y + TOP_PADDING;
    userHandle = [[UITextField alloc] initWithFrame:CGRectMake(textViewX, userHandleY, textViewWidth, textViewHeight)];
    [userHandle setPlaceholder:@"USER HANDLE"];
    [userHandle setBackgroundColor:FT_GRAY];
    [userHandle setFont:HelveticaNeue(14)];
    [userHandle setDelegate:self];
    
    if ([user objectForKey:kFTUserDisplayNameKey]) {
        [userHandle setText:[user objectForKey:kFTUserDisplayNameKey]];
    }
    
    [userHandle setAutocorrectionType:UITextAutocorrectionTypeNo];
    [userHandle setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [scrollView addSubview:userHandle];
    
    CGFloat userWebsiteY = userHandle.frame.size.height + userHandle.frame.origin.y + TOP_PADDING;
    userWebsite = [[UITextField alloc] initWithFrame:CGRectMake(textViewX, userWebsiteY, textViewWidth, textViewHeight)];
    [userWebsite setPlaceholder:@"WEBSITE"];
    [userWebsite setBackgroundColor:FT_GRAY];
    [userWebsite setFont:HelveticaNeue(14)];
    if ([user objectForKey:kFTUserWebsiteKey]) {
        [userWebsite setText:[user objectForKey:kFTUserWebsiteKey]];
    }
    [scrollView addSubview:userWebsite];
    
    // User bio text view
    CGFloat userBiographyY = userWebsite.frame.size.height + userWebsite.frame.origin.y + TOP_PADDING;
    userBiography = [[UITextView alloc] initWithFrame:CGRectMake(textViewX, userBiographyY, textViewWidth, 150)];
    [userBiography setBackgroundColor:FT_GRAY];
    [userBiography setTextColor:[UIColor blackColor]];
    [userBiography setFont:HelveticaNeue(14)];
    [userBiography setUserInteractionEnabled:YES];
    [userBiography setDelegate:self];
    
    if ([user objectForKey:kFTUserBioKey]) {
        [userBiography setText:[user objectForKey:kFTUserBioKey]];
    }
    
    [scrollView addSubview:userBiography];
    
    [self.view addSubview:scrollView];
}

- (void)configureShareSettings {
    //NSLog(@"%@::configureShareSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Share settings
    
    CGFloat navigationViewEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    UITableView *tableView = [[UITableView alloc] init];
    [tableView setFrame:CGRectMake(0, navigationViewEnd + TOP_PADDING, self.view.frame.size.width, 80)];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // Facebook table view cell
    
    UILabel *facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, 120, ROW_HEIGHT)];
    [facebookLabel setTextAlignment: NSTextAlignmentLeft];
    [facebookLabel setUserInteractionEnabled: YES];
    [facebookLabel setFont:MULIREGULAR(18)];
    [facebookLabel setTextColor: [UIColor blackColor]];
    [facebookLabel setText:SOCIAL_FACEBOOK];
    [facebookLabel setTag:0];
    // Twitter table view cell
    
    UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, 120, ROW_HEIGHT)];
    [twitterLabel setTextAlignment: NSTextAlignmentLeft];
    [twitterLabel setUserInteractionEnabled: YES];
    [twitterLabel setFont:MULIREGULAR(18)];
    [twitterLabel setTextColor: [UIColor blackColor]];
    [twitterLabel setText:SOCIAL_TWITTER];
    [twitterLabel setTag:1];
    // UITableView setup
    
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setScrollEnabled:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setRowHeight:ROW_HEIGHT];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    self.objects = [[NSArray alloc] initWithObjects:facebookLabel, twitterLabel, nil];
    [tableView reloadData];
    [self.view addSubview:tableView];
}

- (void)configureNotificationsSettings {
    //NSLog(@"%@::configureNotificationsSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    CGFloat navigationViewEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    NSArray *notifications = [[NSArray alloc] initWithObjects:  @[ NOTIFICATION_TEXT_COMMENT, @2 ],
                                                                @[ NOTIFICATION_TEXT_LIKED, @3 ],
                                                                @[ NOTIFICATION_TEXT_FOLLOW, @4 ],
                                                                @[ NOTIFICATION_TEXT_MENTION, @5 ], nil];
    
    NSMutableArray *notificationLabels = [[NSMutableArray alloc] init];
    
    UITableView *tableView = [[UITableView alloc] init];
    [tableView setFrame:CGRectMake(0, navigationViewEnd + TOP_PADDING, self.view.frame.size.width, ROW_HEIGHT * notifications.count)];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

    int i = 0;
    for (NSArray *notification in notifications) {
        UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, 240, ROW_HEIGHT)];
        [notificationLabel setTextAlignment: NSTextAlignmentLeft];
        [notificationLabel setUserInteractionEnabled: YES];
        [notificationLabel setFont:MULIREGULAR(18)];
        [notificationLabel setTextColor: [UIColor blackColor]];
        [notificationLabel setText:[notification objectAtIndex:0]];
        [notificationLabel setTag:[[notification objectAtIndex:1] integerValue]];        
        [notificationLabels addObject:notificationLabel];
        i++;
    }
    
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setScrollEnabled:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setRowHeight:ROW_HEIGHT];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    self.objects = [[NSArray alloc] initWithArray:notificationLabels];
    [tableView reloadData];
    [self.view addSubview:tableView];
}

- (void)configureRewardSettings {
    //NSLog(@"%@::configureRewardSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    PFQuery *businessUsersQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [businessUsersQuery whereKey:kFTUserTypeKey equalTo:kFTUserTypeBusiness];
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityToUserKey matchesQuery:businessUsersQuery];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    [followingActivitiesQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [followingActivitiesQuery includeKey:kFTActivityToUserKey];
    [followingActivitiesQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            NSLog(@"activities:%@",activities);
            
            CGFloat navigationViewEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
            
            NSMutableArray *businessnameLabels = [[NSMutableArray alloc] init];
            
            UITableView *tableView = [[UITableView alloc] init];
            [tableView setFrame:CGRectMake(0, navigationViewEnd + TOP_PADDING, self.view.frame.size.width, ROW_HEIGHT * (activities.count + 1))];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
            // Reward Setting
            UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, 240, ROW_HEIGHT)];
            rewardLabel.textAlignment =  NSTextAlignmentLeft;
            rewardLabel.textColor = [UIColor blackColor];
            rewardLabel.backgroundColor = [UIColor clearColor];
            rewardLabel.font = MULIREGULAR(18);
            rewardLabel.text = @"Reward Push Notifications";
            rewardLabel.tag = 6;
            [businessnameLabels addObject:rewardLabel];
            
            int i = 0;
            for (PFObject *activity in activities) {
                PFUser *business = [activity objectForKey:kFTActivityToUserKey];
                
                UILabel *businessnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, 240, ROW_HEIGHT)];
                [businessnameLabel setTextAlignment: NSTextAlignmentLeft];
                [businessnameLabel setUserInteractionEnabled: YES];
                [businessnameLabel setFont:MULIREGULAR(18)];
                [businessnameLabel setTextColor:[UIColor blackColor]];
                [businessnameLabel setText:[business objectForKey:kFTUserCompanyNameKey]];
                [businessnameLabel setTag:7];
                [businessnameLabels addObject:businessnameLabel];
                i++;
            }
            
            [tableView setBackgroundColor:[UIColor whiteColor]];
            [tableView setScrollEnabled:NO];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
            [tableView setSeparatorInset:UIEdgeInsetsZero];
            [tableView setRowHeight:ROW_HEIGHT];
            [tableView setDataSource:self];
            [tableView setDelegate:self];
            
            self.objects = [[NSArray alloc] initWithArray:businessnameLabels];
            [tableView reloadData];
            [self.view addSubview:tableView];
        }
    }];
}

- (void)configureBlog {
    
    // Navigation buttons container
    
    webViewNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    [webViewNavigationBar setBackgroundColor:[UIColor clearColor]];
    
    // Tittle View Buttons
    
    UIButton *backNavigationItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backNavigationItemButton setFrame:CGRectMake(0, 10, 11, 18)];
    [backNavigationItemButton setBackgroundImage:[UIImage imageNamed:BACK_NAVIGATION_ITEM] forState:UIControlStateNormal];
    [backNavigationItemButton setBackgroundColor:[UIColor clearColor]];
    [backNavigationItemButton setTintColor:[UIColor whiteColor]];
    [backNavigationItemButton addTarget:self action:@selector(didTapBackNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *refreshNavigationItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshNavigationItemButton setFrame:CGRectMake((webViewNavigationBar.frame.size.width - 16) / 2, 10, 16, 16)];
    [refreshNavigationItemButton setBackgroundImage:[UIImage imageNamed:REFRESH_NAVIGATION_ITEM] forState:UIControlStateNormal];
    [refreshNavigationItemButton setBackgroundColor:[UIColor clearColor]];
    [refreshNavigationItemButton setTintColor:[UIColor whiteColor]];
    [refreshNavigationItemButton addTarget:self action:@selector(didTapRefreshNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *forwardNavigationItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardNavigationItemButton setFrame:CGRectMake(webViewNavigationBar.frame.size.width - 11, 10, 11, 18)];
    [forwardNavigationItemButton setBackgroundImage:[UIImage imageNamed:FORWARD_NAVIGATION_ITEM] forState:UIControlStateNormal];
    [forwardNavigationItemButton setBackgroundColor:[UIColor clearColor]];
    [forwardNavigationItemButton setTintColor:[UIColor whiteColor]];
    [forwardNavigationItemButton addTarget:self action:@selector(didTapForwardNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [webViewNavigationBar addSubview:backNavigationItemButton];
    [webViewNavigationBar addSubview:refreshNavigationItemButton];
    [webViewNavigationBar addSubview:forwardNavigationItemButton];
    [self.navigationItem setTitleView:webViewNavigationBar];
    
    CGFloat webViewY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, webViewY, self.view.frame.size.width, self.view.frame.size.height)];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FITTAG_BLOG_URL]]];
    
    [self.view addSubview:webView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //NSLog(@"%@::textView:shouldChangeTextInRange:replacementText:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    NSInteger integer = 150 - textView.text.length;
    [self showHudMessage:[NSString stringWithFormat:@"%ld",(long)integer] WithDuration:1];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing:");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    scrollView.frame = CGRectMake(scrollView.frame.origin.x, (scrollView.frame.origin.y - 140.0), scrollView.frame.size.width, scrollView.frame.size.height);
    [UIView commitAnimations];
    
    if ([userBiography.text isEqualToString:CAPTION_ABOUT]) {
        userBiography.text = EMPTY_STRING;
        userBiography.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing:");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    scrollView.frame = CGRectMake(scrollView.frame.origin.x, (scrollView.frame.origin.y + 140.0), scrollView.frame.size.width, scrollView.frame.size.height);
    [UIView commitAnimations];
    
    if (userBiography.text.length == 0) {
        userBiography.textColor = [UIColor lightGrayColor];
        userBiography.text = CAPTION_ABOUT;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FTSwitchCell *cell = [[FTSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:REUSABLE_IDENTIFIER_SOCIAL];
    
    UILabel *label = self.objects[indexPath.row];
    [cell setDelegate:self];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setUserInteractionEnabled:YES];
    [cell.contentView addSubview:label];
    
    switch (label.tag) {
        case 0:
            cell.type = FTSwitchTypeFacebook;
            break;
        case 1:
            cell.type = FTSwitchTypeTwitter;
            break;
        case 2:
            cell.type = FTSwitchTypeComment;
            break;
        case 3:
            cell.type = FTSwitchTypeLike;
            break;
        case 4:
            cell.type = FTSwitchTypeFollow;
            break;
        case 5:
            cell.type = FTSwitchTypeMention;
            break;
        case 6:
            cell.type = FTSwitchTypeReward;
            break;
        case 7:
            cell.key = label.text;
            cell.type = FTSwitchTypeBusiness;
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

#pragma mark - FTSocialCellDelegate

- (void)switchCell:(FTSwitchCell *)switchCell didChangeFollowSwitch:(UISwitch *)lever {
    if ([lever isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeLikeSwitch:(UISwitch *)lever {
    if ([lever isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushLikesKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFTUserDefaultsSettingsViewControllerPushLikesKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeCommentSwitch:(UISwitch *)lever {
    if ([lever isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushCommentsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFTUserDefaultsSettingsViewControllerPushCommentsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeMentionSwitch:(UISwitch *)lever {
    if ([lever isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushMentionsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFTUserDefaultsSettingsViewControllerPushMentionsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeRewardSwitch:(UISwitch *)lever {
    if ([lever isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushRewardsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFTUserDefaultsSettingsViewControllerPushRewardsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeBusinessSwitch:(UISwitch *)lever key:(NSString *)key {
    
    NSLog(@"key:%@",key);
    
    // Get dictionary stored in user defaults
    NSMutableDictionary *permissions = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kFTUserDefaultsSettingsViewControllerPushBusinessesKey] mutableCopy];
    
    if (!permissions) {
        permissions = [[NSMutableDictionary alloc] init];
    }
    
    // Update the dictionary
    if ([lever isOn]) {
        [permissions setObject:@"YES" forKey:key];
    } else {
        [permissions setObject:@"NO" forKey:key];
    }
    
    // Update standard defaults permissions
    [[NSUserDefaults standardUserDefaults] setObject:permissions forKey:kFTUserDefaultsSettingsViewControllerPushBusinessesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeFacebookSwitch:(UISwitch *)lever {
    NSLog(@"didChangeFacebookSwitch:");
    if ([lever isOn]) {
        NSLog(@"[lever isOn]");
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",@"public_profile",@"user_friends",nil];
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:permissions block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Facebook linked");
                [lever setOn:YES];
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
                [lever setOn:NO];
                [[[UIAlertView alloc] initWithTitle:@"Facebook Error"
                                            message:@"Failed to link with your facebook account. Please try again, if the problem continues contact support@fittag.com. :("
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    } else {
        NSLog(@"![lever isOn]");
        [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Facebook unlinked");
                [lever setOn:NO];
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
                [lever setOn:YES];
                [[[UIAlertView alloc] initWithTitle:@"Facebook Error"
                                            message:@"Failed to unlink with your facebook account. Please try again, if the problem continues contact support. :("
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void)switchCell:(FTSwitchCell *)switchCell didChangeTwitterSwitch:(UISwitch *)lever {
    NSLog(@"socialCell:didChangeTwitterSwitch:");
    if ([lever isOn]) {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Twitter linked");
                [lever setOn:YES];
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
                [lever setOn:NO];
                [[[UIAlertView alloc] initWithTitle:@"Twitter Error"
                                            message:@"Failed to link with your twitter account. Please try again, if the problem continues contact support@fittag.com. :("
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    } else {
        [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Twitter unlinked");
                [lever setOn:NO];
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
                [lever setOn:YES];
                [[[UIAlertView alloc] initWithTitle:@"Twitter Error"
                                            message:@"Failed to unlink with your twitter account. Please try again, if the problem continues contact support@fittag.com. :("
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    }
}

#pragma mark - FTCamViewControllerDelegate

- (void)camViewController:(FTCamViewController *)camViewController coverPhoto:(UIImage *)photo {
    
    //NSLog(@"camViewController:coverPhoto:");
    
    if (missingCoverPhotoLabel) {
        [missingCoverPhotoLabel removeFromSuperview];
        missingCoverPhotoLabel = nil;
    }
    
    [coverPhotoImageView setImage:photo];
    
    UIImage *resizedImage = [photo resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                        bounds:CGSizeMake(640, 320)
                                          interpolationQuality:kCGInterpolationHigh];
    NSData *coverPhotoImageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    PFUser *user = [PFUser currentUser];
    [user setValue:[PFFile fileWithName:FILE_COVER_JPEG data:coverPhotoImageData] forKey:kFTUserCoverPhotoKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self showHudMessage:PROFILE_UPDATED WithDuration:3];
            
            // Notify if new cover photo is available
            [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeCoverPhotoNotification object:photo];
        }
        
        if (error) {
            
            [coverPhotoImageView setImage:nil];
            
            if (!missingCoverPhotoLabel) {
                missingCoverPhotoLabel = [[UILabel alloc] initWithFrame:coverPhotoImageView.frame];
                [missingCoverPhotoLabel setTextAlignment:NSTextAlignmentCenter];
                [missingCoverPhotoLabel setUserInteractionEnabled:NO];
                [missingCoverPhotoLabel setFont:SYSTEMFONTBOLD(24)];
                [missingCoverPhotoLabel setTextColor: [UIColor blackColor]];
                [missingCoverPhotoLabel setText:@"No Cover Photo Found"];
                
                [coverPhotoImageView addSubview:missingCoverPhotoLabel];
                [self.view addSubview:coverPhotoImageView];
            }
            
            [[[UIAlertView alloc] initWithTitle:@"Network Problems"
                                        message:@"Unable to save your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] show];
        }
    }];
}

- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo {
    [userProfileImageView setImage:photo];
    
    UIImage *resizedImage = [photo resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                        bounds:CGSizeMake(640, 640)
                                          interpolationQuality:kCGInterpolationHigh];
    NSData *profileImageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    PFUser *user = [PFUser currentUser];
    [user setValue:[PFFile fileWithName:FILE_MEDIUM_JPEG data:profileImageData] forKey:kFTUserProfilePicMediumKey];
    [user setValue:[PFFile fileWithName:FILE_SMALL_JPEG data:profileImageData] forKey:kFTUserProfilePicSmallKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self showHudMessage:PROFILE_UPDATED WithDuration:3];
            
            // Notify if new profile photo is available
            [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeProfilePhotoNotification object:photo];
        }
        
        if (error) {
            // clear image
            [userProfileImageView setImage:nil];
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Unable to save your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - FTCropImageViewControllerDelegate

- (void)cropImageViewController:(FTCropImageViewController *)cropImageViewController didCropPhotoAction:(UIImage *)photo {
    
    if (missingCoverPhotoLabel) {
        [missingCoverPhotoLabel removeFromSuperview];
        missingCoverPhotoLabel = nil;
    }
    
    [coverPhotoImageView setImage:photo];
    
    NSData *coverPhotoImageData = UIImageJPEGRepresentation(photo, 0.8f);
    
    PFUser *user = [PFUser currentUser];
    [user setValue:[PFFile fileWithName:FILE_COVER_JPEG data:coverPhotoImageData] forKey:kFTUserCoverPhotoKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self showHudMessage:PROFILE_UPDATED WithDuration:3];
        }
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Unable to save your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - ()

- (void)clearProfileImageButtons {
    [facebookImageButton setBackgroundColor:[UIColor whiteColor]];
    [twitterImageButton setBackgroundColor:[UIColor whiteColor]];
    [takePhotoButton setBackgroundColor:[UIColor whiteColor]];
    [selectPhotoButton setBackgroundColor:[UIColor whiteColor]];
    [cropPhotoButton setBackgroundColor:[UIColor whiteColor]];
    [clearPhotoButton setBackgroundColor:[UIColor whiteColor]];
    
    [facebookImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [twitterImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cropPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)didHighlightButtonAction:(UIButton *)button {
    [self clearProfileImageButtons];
    
    UIColor *titleColor = FT_RED;
    UIColor *backgroundColor = FT_GRAY;
    [button setBackgroundColor:backgroundColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateSelected];
    [button setTitleColor:titleColor forState:UIControlStateHighlighted];
}

- (void)didTapFacebookImageButtonAction:(id)sender {
    //NSLog(@"didTapFacebookImageButtonAction");
    [self clearProfileImageButtons];
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(USER_DID_LOGIN_FACEBOOK);
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
            if (!error) {
                NSData* profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:FACEBOOK_GRAPH_PICTURES_URL,[FBuser objectForKey:FBUserIDKey]]]];
                
                PFUser *user = [PFUser currentUser];
                [user setValue:[PFFile fileWithName:FILE_MEDIUM_JPEG data:profileImageData] forKey:kFTUserProfilePicMediumKey];
                [user setValue:[PFFile fileWithName:FILE_SMALL_JPEG data:profileImageData] forKey:kFTUserProfilePicSmallKey];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        // Update profile image
                        PFFile *file = [PFFile fileWithName:FILE_MEDIUM_JPEG data:profileImageData];
                        
                        if (file && ![file isEqual:[NSNull null]]) {
                            
                            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                    
                                    UIImage *profileImage = [UIImage imageWithData:data];
                                    
                                    [userProfileImageView setImage:profileImage];
                                    
                                    [self showHudMessage:PROFILE_UPDATED WithDuration:3];
                                    
                                    // Notify if new profile photo is available
                                    [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeProfilePhotoNotification object:profileImage];
                                }
                            }];
                        }
                    }
                    
                    if (error) {
                        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                        [[[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to update your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil] show];
                    }
                }];
                
            } else {
                NSLog(@"Facebook%@%@",ERROR_MESSAGE,error);
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Unable to update your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not pull facebook profile picture. Make sure that your account is linked to facebook."
                                   delegate:self
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)didTapTwitterImageButtonAction:(id)sender {
    //NSLog(@"didTapTwitterImageButtonAction");
    [self clearProfileImageButtons];
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(USER_DID_LOGIN_TWITTER);
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        NSString *requestString = [NSString stringWithFormat:TWITTER_API_USERS,[PFTwitterUtils twitter].screenName];
        NSURL *verify = [NSURL URLWithString:requestString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
        
        [[PFTwitterUtils twitter] signRequest:request];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error == nil) {
            NSDictionary* TWuser = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSString *profile_image_normal = [TWuser objectForKey:TWITTER_PROFILE_HTTPS];
            NSString *profile_image = [profile_image_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            NSData *profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_image]];
            
            PFUser *user = [PFUser currentUser];
            [user setValue:[PFFile fileWithName:FILE_MEDIUM_JPEG data:profileImageData] forKey:kFTUserProfilePicMediumKey];
            [user setValue:[PFFile fileWithName:FILE_SMALL_JPEG data:profileImageData] forKey:kFTUserProfilePicSmallKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@%@",ERROR_MESSAGE,error);
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:@"Unable to update your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                               delegate:self
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil] show];
                } else {
                    // Update profile image
                    PFFile *file = [PFFile fileWithName:FILE_MEDIUM_JPEG data:profileImageData];
                    
                    if (file && ![file isEqual:[NSNull null]]) {
                        
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                
                                UIImage *profileImage = [UIImage imageWithData:data];
                                [userProfileImageView setImage:profileImage];
                                
                                [self showHudMessage:PROFILE_UPDATED WithDuration:3];
                                
                                // Notify if new profile photo is available
                                [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeProfilePhotoNotification object:profileImage];
                            }
                        }];
                    }
                }
            }];
        } else {
            NSLog(@"Twitter%@%@",ERROR_MESSAGE,error);
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Unable to update your profile picture. Please try again later, if the problem continues contact support@fittag.com."
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] show];
        }
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not pull facebook profile picture. Make sure that your account is linked to facebook."
                                   delegate:self
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)didTapTakeCoverPhotoButtonAction:(UIButton *)sender {
    //NSLog(@"didTapTakeCoverPhotoButtonAction");
    [self clearProfileImageButtons];
    
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isCoverPhoto = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ camViewController ] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didTapCropCoverPhotoButtonAction:(UIButton *)sender {
    [self clearProfileImageButtons];
    
    if (cropImageViewController) {
        cropImageViewController = nil;
    }
    
    cropImageViewController = [[FTCropImageViewController alloc] initWithPhoto:coverPhotoImageView.image];
    cropImageViewController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ cropImageViewController ] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didTapClearCoverPhotoButtonAction:(UIButton *)button {
    
    [self clearProfileImageButtons];
    
    coverPhotoImageView.image = nil;
    
    if (!missingCoverPhotoLabel) {
        missingCoverPhotoLabel = [[UILabel alloc] initWithFrame:coverPhotoImageView.frame];
        [missingCoverPhotoLabel setTextAlignment:NSTextAlignmentCenter];
        [missingCoverPhotoLabel setUserInteractionEnabled:NO];
        [missingCoverPhotoLabel setFont:SYSTEMFONTBOLD(24)];
        [missingCoverPhotoLabel setTextColor: [UIColor blackColor]];
        [missingCoverPhotoLabel setText:@"No Cover Photo Found"];
        
        [coverPhotoImageView addSubview:missingCoverPhotoLabel];
        [self.view addSubview:coverPhotoImageView];
    }
    
    PFUser *user = [PFUser currentUser];
    [user setObject:[NSNull null] forKey:kFTUserCoverPhotoKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [FTUtility showHudMessage:@"cover cleared.." WithDuration:2];
            
            // Notify if new cover photo is available
            [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeCoverPhotoNotification object:nil];
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
    
}

- (void)didTapTakePhotoButtonAction:(id)sender {
    //NSLog(@"didTapTakePhotoButtonAction");
    [self clearProfileImageButtons];
    
    if (missingCoverPhotoLabel) {
        [missingCoverPhotoLabel removeFromSuperview];
        missingCoverPhotoLabel = nil;
    }
    
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isProfilePciture = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ camViewController ] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

/*
- (void)didTapSelectPhotoButtonAction:(id)sender {
    NSLog(@"didTapSelectPhotoButtonAction");
    [self clearProfileImageButtons];
}
*/

- (void)showHudMessage:(NSString *)message WithDuration:(NSTimeInterval)duration {
    //NSLog(@"%@::showHudMessage:WithDuration:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    self.hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.margin = 10;
    self.hud.yOffset = 0;
    self.hud.removeFromSuperViewOnHide = YES;
    self.hud.userInteractionEnabled = NO;
    self.hud.labelText = message;
    [self.hud hide:YES afterDelay:duration];
}

- (void)didTapBackNavigationButtonAction:(UIButton *)button {
    if ([webView canGoBack])
        [webView goBack];
}

- (void)didTapRefreshNavigationButtonAction:(UIButton *)button {
    if (webView)
        [webView reload];
}

- (void)didTapForwardNavigationButtonAction:(UIButton *)button {
    if ([webView canGoForward])
        [webView goForward];
}

- (void)didTapRewardsSwitchAction:(UISwitch *)rewardSwitch {
    //NSLog(@"%@::didTapRewardsSwitchAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    if ([rewardSwitch isOn]) {
        NSLog(SWITCH_REWARD_ON);
        [self showHudMessage:SWITCH_REWARD_ON WithDuration:3];
    } else {
        NSLog(SWITCH_REWARD_OFF);
        [self showHudMessage:SWITCH_REWARD_OFF WithDuration:3];
    }
}

- (void)didTapNotificationSwitchAction:(UISwitch *)notificationSwitch {
    //NSLog(@"%@::didTapNotificationSwitchAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    if ([notificationSwitch isOn]) {
        NSLog(SWITCH_NOTIFICATIONS_ON);
        [self showHudMessage:SWITCH_NOTIFICATIONS_ON WithDuration:3];
    } else {
        NSLog(SWITCH_NOTIFICATIONS_OFF);
        [self showHudMessage:SWITCH_NOTIFICATIONS_OFF WithDuration:3];
    }
}

- (void)didTapFacebookSwitchAction:(UISwitch *)facebookSwitch {
    //NSLog(@"%@::didTapFacebookSwitchAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    if ([facebookSwitch isOn]) {
        NSLog(SWITCH_FACEBOOK_ON);
        [self showHudMessage:SWITCH_FACEBOOK_ON WithDuration:3];
    } else {
        NSLog(SWITCH_FACEBOOK_OFF);
        [self showHudMessage:SWITCH_FACEBOOK_OFF WithDuration:3];
    }
}

- (void)didTapTwitterSwitchAction:(UISwitch *)twitterSwitch {
    //NSLog(@"%@::didTapTwitterSwitchAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    if ([twitterSwitch isOn]) {
        NSLog(SWITCH_TWITTER_ON);
        [self showHudMessage:SWITCH_TWITTER_ON WithDuration:3];
    } else {
        NSLog(SWITCH_TWITTER_OFF);
        [self showHudMessage:SWITCH_TWITTER_OFF WithDuration:3];
    }
}

- (void)didTapFacebookLabelAction:(id)sender {
    NSLog(@"%@::didTapFacebookLabelAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
}

- (void)didTapTwitterLabelAction:(id)sender {
    NSLog(@"%@::didTapTwitterLabelAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapDoneButtonAction:(id)sender {
    //NSLog(@"%@::didTapSaveButtonAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    BOOL doneEditing = YES;
    
    if ([self.detailItem isEqualToString:EDIT_BIO]) {
        [self updateUserInformation];
        return;
    }
    
    if (doneEditing) {
        [self.navigationController popViewControllerAnimated:YES];
    }    
}

- (void)updateUserInformation {
    //NSLog(@"%@::updateUserInformation:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    [self didGestureHideKeyboardAction];
    
    PFUser *user = [PFUser currentUser];
    
    if (userFirstname.text.length > 0) {
        if (userFirstname.text.length < 20) {
            [user setObject:userFirstname.text forKey:kFTUserFirstnameKey];
        } else {
            [self showHudMessage:HUD_MESSAGE_CHARACTER_LIMIT WithDuration:2];
            return;
        }
    }
    
    if (userLastname.text.length > 0) {
        if (userLastname.text.length < 20) {
            [user setObject:userLastname.text forKey:kFTUserLastnameKey];
        } else {
            [self showHudMessage:HUD_MESSAGE_CHARACTER_LIMIT WithDuration:2];
            return;
        }
    }
    
    [user setObject:userWebsite.text forKey:kFTUserWebsiteKey];
    
    if (userHandle.text.length > 0) {
        
        if (userHandle.text.length < 15) {
            
            NSCharacterSet *alphaNumericUnderscoreSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
            alphaNumericUnderscoreSet = [alphaNumericUnderscoreSet invertedSet];
            userHandle.text = [userHandle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSRange range = [userHandle.text rangeOfCharacterFromSet:alphaNumericUnderscoreSet];
            
            if (range.location != NSNotFound) {
                [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_INVALID WithDuration:2];
                return;
            }
            
            [user setObject:[userHandle.text lowercaseString] forKey:kFTUserDisplayNameKey];
            
        } else {
            [self showHudMessage:HUD_MESSAGE_CHARACTER_LIMIT WithDuration:2];
            return;
        }
    } else {
        [self showHudMessage:HUD_MESSAGE_HANDLE_EMPTY WithDuration:2];
        return;
    }
    
    if (userBiography.text.length > 150) {
        [self showHudMessage:HUD_MESSAGE_BIOGRAPHY_LIMIT WithDuration:2];
        return;
    }
    
    if (userBiography.text.length <= 150 && userBiography.text.length > 0) {
        [user setObject:userBiography.text forKey:kFTUserBioKey];
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(HUD_MESSAGE_UPDATED);
            [self showHudMessage:HUD_MESSAGE_UPDATED WithDuration:3];
            [self.navigationController popViewControllerAnimated:NO];
            
            // Notify if new biography text is available
            [[NSNotificationCenter defaultCenter] postNotificationName:FTProfileDidChangeBioNotification object:userBiography.text];            
        }
        
        if (error) {
            NSLog(@"%@",error);
            
            switch (error.code) {
                case 142:
                    [self showHudMessage:HUD_MESSAGE_HANDLE_TAKEN WithDuration:2];
                    break;
                    
                default:
                    break;
            }
            
        }
    }];
}

@end
