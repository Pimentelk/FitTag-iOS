//
//  FTAccountHeaderView+FTSettingsDetailViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/19/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsDetailViewController.h"
#import "MBProgressHUD.h"

@interface FTSettingsDetailViewController ()
@property (nonatomic, strong) UITextView *userBiography;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation FTSettingsDetailViewController
@synthesize userBiography;

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
        [self.navigationItem setTitle:self.detailItem];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
        
        // Remove all subviews
        [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
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
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    // Save button
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didTapSaveButtonAction:)];
    [saveButtonItem setStyle:UIBarButtonItemStylePlain];
    [saveButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:saveButtonItem];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

#pragma mark - Item Configuration

- (void)configureProfilePicture {
    NSLog(@"%@::configureProfilePicture",VIEWCONTROLLER_SETTINGS_DETAIL);
}

- (void)configureCoverPhoto {
    NSLog(@"%@::configureCoverPhoto",VIEWCONTROLLER_SETTINGS_DETAIL);
}

- (void)configureBiography {
    NSLog(@"%@::configureBiography",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // User bio text view    
    CGFloat userBiographyY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y + 20;
    userBiography = [[UITextView alloc] initWithFrame:CGRectMake(10, userBiographyY, self.view.frame.size.width - 20, 150)];
    [userBiography setBackgroundColor:[UIColor whiteColor]];
    [userBiography setTextColor:[UIColor blackColor]];
    [userBiography setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [userBiography setUserInteractionEnabled:YES];
    [userBiography setDelegate:self];
    [userBiography setText:[self.user objectForKey:kFTUserBioKey]];
    [self.view addSubview:userBiography];
}

- (void)configureShareSettings {
    NSLog(@"%@::configureShareSettings",VIEWCONTROLLER_SETTINGS_DETAIL);
    
    // Share settings
    
    UILabel *facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 300, 32)];
    facebookLabel.textAlignment =  NSTextAlignmentLeft;
    facebookLabel.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                            green:FT_RED_COLOR_GREEN
                                             blue:FT_RED_COLOR_BLUE alpha:1.0f];
                              
    facebookLabel.backgroundColor = [UIColor clearColor];
    facebookLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    facebookLabel.text = @"Facebook";
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
    twitterLabel.text = @"Twitter";
    [self.view addSubview:twitterLabel];
    
    UISwitch *twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 170, 0, 0)];
    [twitterSwitch setOn:NO animated:YES];
    [twitterSwitch addTarget:self action:@selector(didTapTwitterSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twitterSwitch];
}

- (void)configureNotificationsSettings {
    
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

#pragma mark - ()

- (void)showHudMessage:(NSString *)message WithDuration:(NSTimeInterval)duration {
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.margin = 10.f;
    self.hud.yOffset = 150.f;
    self.hud.removeFromSuperViewOnHide = YES;
    self.hud.userInteractionEnabled = NO;
    self.hud.labelText = message;
    [self.hud hide:YES afterDelay:duration];
}



- (void)didTapRewardsSwitchAction:(UISwitch *)rewardSwitch {
    if ([rewardSwitch isOn]) {
        NSLog(SWITCH_REWARD_ON);
        [self showHudMessage:SWITCH_REWARD_ON WithDuration:3];
    } else {
        NSLog(SWITCH_REWARD_OFF);
        [self showHudMessage:SWITCH_REWARD_OFF WithDuration:3];
    }
}

- (void)didTapNotificationSwitchAction:(UISwitch *)notificationSwitch {
    if ([notificationSwitch isOn]) {
        NSLog(SWITCH_NOTIFICATIONS_ON);
        [self showHudMessage:SWITCH_NOTIFICATIONS_ON WithDuration:3];
    } else {
        NSLog(SWITCH_NOTIFICATIONS_OFF);
        [self showHudMessage:SWITCH_NOTIFICATIONS_OFF WithDuration:3];
    }
}

- (void)didTapFacebookSwitchAction:(UISwitch *)facebookSwitch {
    if ([facebookSwitch isOn]) {
        NSLog(SWITCH_FACEBOOK_ON);
        [self showHudMessage:SWITCH_FACEBOOK_ON WithDuration:3];
    } else {
        NSLog(SWITCH_FACEBOOK_OFF);
        [self showHudMessage:SWITCH_FACEBOOK_OFF WithDuration:3];
    }
}

- (void)didTapTwitterSwitchAction:(UISwitch *)twitterSwitch {
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

- (void)didTapSaveButtonAction:(id)sender {
    
    [userBiography resignFirstResponder];
    
    if (userBiography.text.length <= 150) {
        [self showHudMessage:HUD_MESSAGE_BIOGRAPHY_UPDATED WithDuration:3];
        [self.user setObject:userBiography.text forKey:kFTUserBioKey];
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(HUD_MESSAGE_BIOGRAPHY_UPDATED);
            }
        }];
        
        [self.navigationController popViewControllerAnimated:NO];
        
    } else if (userBiography.text.length > 150 ) {
        [self showHudMessage:HUD_MESSAGE_BIOGRAPHY_LIMIT WithDuration:3];
    }
}

#pragma mark - ()

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSInteger integer = 150 - textView.text.length;
    [self showHudMessage:[NSString stringWithFormat:@"%ld",(long)integer] WithDuration:1];
    return YES;
}

@end
