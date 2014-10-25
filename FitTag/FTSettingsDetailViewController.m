//
//  FTAccountHeaderView+FTSettingsDetailViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsDetailViewController.h"
#import "MBProgressHUD.h"

#define TEXTVIEW_PADDING 20

// Profile Image Options

#define FACEBOOK_PHOTO @"Facebook Profile Image"
#define TWITTER_PHOTO @"Twitter Profile Image"
#define TAKE_PHOTO @"Take Photo"
#define SELECT_PHOTO @"Select Photo"

#define TABLE_CELL_HEIGHT 45

@interface FTSettingsDetailViewController () {
    CGFloat navigationBarEnd;
}
@property (nonatomic, strong) UIImageView *userProfileImageView;
@property (nonatomic, strong) UITextView *userBiography;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *webViewNavigationBar;
@end

@implementation FTSettingsDetailViewController
@synthesize userBiography;
@synthesize webView;
@synthesize webViewNavigationBar;
@synthesize userProfileImageView;

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
        
        if(webViewNavigationBar){
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
        NSLog(@"%@ self.detailItem: %@",VIEWCONTROLLER_SETTINGS_DETAIL, self.detailItem);
        
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
    
    // Navigation bar ends
    navigationBarEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    // Set the current user
    self.user = [PFUser currentUser];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Set Background
    
    [self.view setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                                  green:FT_GRAY_COLOR_GREEN
                                                   blue:FT_GRAY_COLOR_BLUE alpha:1.0f]];
    
    // Override the back idnicator
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:FT_RED_COLOR_RED
                                                                             green:FT_RED_COLOR_GREEN
                                                                              blue:FT_RED_COLOR_BLUE alpha:1.0f]];
    
    // Back button
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Done button
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
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
    
    // Set profile image
    
    userProfileImageView = [[UIImageView alloc] init];
    [userProfileImageView setFrame:CGRectMake(0, navigationBarEnd, self.view.frame.size.width, self.view.frame.size.width)];
    
    PFUser *user = [PFUser currentUser];
    PFFile *file = [user objectForKey:kFTUserProfilePicMediumKey];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *profileImage = [UIImage imageWithData:data];
            
            [userProfileImageView setImage:profileImage];
            [self.view addSubview:userProfileImageView];
        }
    }];
    
    // Set profile image buttons
    
    CGFloat profileImageViewEnd = userProfileImageView.frame.size.height + userProfileImageView.frame.origin.y;
    CGFloat profileImageHeight = self.view.frame.size.height - userProfileImageView.frame.size.height;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, profileImageViewEnd, self.view.frame.size.width, profileImageHeight)
                                                          style:UITableViewStylePlain];
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setScrollEnabled:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // Create buttons
    
    NSArray *imageOption = @[ FACEBOOK_PHOTO, TWITTER_PHOTO, TAKE_PHOTO, SELECT_PHOTO ];
    
    for (int i = 0; i < imageOption.count; i++) {
        NSString *option = [imageOption objectAtIndex:i];
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, TABLE_CELL_HEIGHT * i, tableView.frame.size.width, TABLE_CELL_HEIGHT)];
        label.textAlignment =  NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(18.0)];
        label.text = option;
        [tableView insertSubview:label atIndex:i];
    }
    
    [self.view addSubview:tableView];
}

- (void)configureCoverPhoto {
   // NSLog(@"%@::configureCoverPhoto",VIEWCONTROLLER_SETTINGS_DETAIL);
}

- (void)configureBiography {
    //NSLog(@"%@::configureBiography",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // User bio text view
    
    userBiography = [[UITextView alloc] initWithFrame:CGRectMake(10, navigationBarEnd + TEXTVIEW_PADDING, self.view.frame.size.width - 20, 150)];
    [userBiography setBackgroundColor:[UIColor whiteColor]];
    [userBiography setTextColor:[UIColor blackColor]];
    [userBiography setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [userBiography setUserInteractionEnabled:YES];
    [userBiography setDelegate:self];
    [userBiography setText:[self.user objectForKey:kFTUserBioKey]];
    [self.view addSubview:userBiography];
}

- (void)configureShareSettings {
    //NSLog(@"%@::configureShareSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Share settings
    
    UILabel *facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 300, 32)];
    facebookLabel.textAlignment =  NSTextAlignmentLeft;
    facebookLabel.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                              green:FT_RED_COLOR_GREEN
                                               blue:FT_RED_COLOR_BLUE alpha:1.0f];
                              
    facebookLabel.backgroundColor = [UIColor clearColor];
    facebookLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    facebookLabel.text = SOCIAL_FACEBOOK;
    [self.view addSubview:facebookLabel];
    
    UISwitch *facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 100, 0, 0)];
    [facebookSwitch setOn:NO animated:YES];
    [facebookSwitch addTarget:self action:@selector(didTapFacebookSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookSwitch];
    
    UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 300, 32)];
    twitterLabel.textAlignment =  NSTextAlignmentLeft;
    twitterLabel.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                             green:FT_RED_COLOR_GREEN
                                              blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    twitterLabel.backgroundColor = [UIColor clearColor];
    twitterLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    twitterLabel.text = SOCIAL_TWITTER;
    [self.view addSubview:twitterLabel];
    
    UISwitch *twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 170, 0, 0)];
    [twitterSwitch setOn:NO animated:YES];
    [twitterSwitch addTarget:self action:@selector(didTapTwitterSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twitterSwitch];
}

- (void)configureNotificationsSettings {
    //NSLog(@"%@::configureNotificationsSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Notification Settings
    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 300, 32)];
    notificationLabel.textAlignment =  NSTextAlignmentLeft;
    notificationLabel.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                              green:FT_RED_COLOR_GREEN
                                               blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    notificationLabel.backgroundColor = [UIColor clearColor];
    notificationLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    notificationLabel.text = @"Notifications";
    [self.view addSubview:notificationLabel];
    
    UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 100, 0, 0)];
    [notificationSwitch setOn:NO animated:YES];
    [notificationSwitch addTarget:self action:@selector(didTapNotificationSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:notificationSwitch];
}

- (void)configureRewardSettings {
    //NSLog(@"%@::configureRewardSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Reward Settings
    UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 300, 32)];
    rewardLabel.textAlignment =  NSTextAlignmentLeft;
    rewardLabel.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                            green:FT_RED_COLOR_GREEN
                                             blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    rewardLabel.backgroundColor = [UIColor clearColor];
    rewardLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    rewardLabel.text = @"Rewards";
    [self.view addSubview:rewardLabel];
    
    UISwitch *rewardSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 100, 0, 0)];
    [rewardSwitch setOn:NO animated:YES];
    [rewardSwitch addTarget:self action:@selector(didTapRewardsSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rewardSwitch];
}

- (void)configureBlog {
    
    // Navigation buttons container
    
    webViewNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,32)];
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

#pragma mark - ()

- (void)showHudMessage:(NSString *)message WithDuration:(NSTimeInterval)duration {
    //NSLog(@"%@::showHudMessage:WithDuration:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.margin = 10.f;
    self.hud.yOffset = 150.f;
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

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapDoneButtonAction:(id)sender {
    //NSLog(@"%@::didTapSaveButtonAction:",VIEWCONTROLLER_SETTINGS_DETAIL);
    if ([self.detailItem isEqualToString:PROFILE_PICTURE]) {

    } else if ([self.detailItem isEqualToString:COVER_PHOTO]) {

    } else if ([self.detailItem isEqualToString:EDIT_BIO]) {
        [self saveBiography];
    } else if ([self.detailItem isEqualToString:SHARE_SETTINGS]) {

    } else if ([self.detailItem isEqualToString:NOTIFICATION_SETTINGS]) {

    } else if ([self.detailItem isEqualToString:REWARD_SETTIGNS]) {

    } else if ([self.detailItem isEqualToString:FITTAG_BLOG]) {

    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)saveBiography {
    //NSLog(@"%@::saveBiography:",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    if (!userBiography) {
        NSLog(@"%@::biography not saved, biography is nil..",VIEWCONTROLLER_SETTINGS_DETAIL);
        return;
    }
    
    [userBiography resignFirstResponder];
    
    if (userBiography.text.length <= 150) {
        [self showHudMessage:HUD_MESSAGE_BIOGRAPHY_UPDATED WithDuration:3];
        [self.user setObject:userBiography.text forKey:kFTUserBioKey];
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(HUD_MESSAGE_BIOGRAPHY_UPDATED);
            }
        }];
    } else if (userBiography.text.length > 150 ) {
        [self showHudMessage:HUD_MESSAGE_BIOGRAPHY_LIMIT WithDuration:3];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //NSLog(@"%@::textView:shouldChangeTextInRange:replacementText:",VIEWCONTROLLER_SETTINGS_DETAIL);
    NSInteger integer = 150 - textView.text.length;
    [self showHudMessage:[NSString stringWithFormat:@"%ld",(long)integer] WithDuration:1];
    return YES;
}

@end
