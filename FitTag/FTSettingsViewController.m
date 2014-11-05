//
//  FTSettingsActionSheetDelegate.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsCell.h"
#import "FTSettingsViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

#define REUSEABLE_IDENTIFIER_DATA @"DataCell"

#define SETTINGS_BUTTON @"settings_button"
#define SETTINGS_BUTTON_X 0
#define SETTINGS_BUTTON_Y 4
#define SETTINGS_BUTTON_HEIGHT 32

@interface FTSettingsViewController ()

@property NSDictionary *settingsDictionary;
@property NSArray *settingsSectionTitles;
@property (nonatomic, strong) MFMailComposeViewController *mailer;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation FTSettingsViewController
@synthesize settingsDictionary;
@synthesize settingsSectionTitles;
@synthesize mailer;
@synthesize hud;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:NAVIGATION_TITLE_SETTINGS];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                                       green:FT_GRAY_COLOR_GREEN
                                                        blue:FT_GRAY_COLOR_BLUE alpha:1.0f]];
    
    // Override the back idnicator
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
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
    
    [self.tableView registerClass:[FTSettingsCell class] forCellReuseIdentifier:REUSEABLE_IDENTIFIER_DATA];
    
    // Sections setup
    settingsDictionary = @{ SECTION_EDIT_PROFILE : @[ PROFILE_PICTURE, COVER_PHOTO, EDIT_BIO ],
                            SECTION_ADDITIONAL_INFO : @[ ADD_INTERESTS, INVITE_FRIENDS ],
                            SECTION_SETTINGS : @[ SHARE_SETTINGS, NOTIFICATION_SETTINGS, REWARD_SETTIGNS ],
                            SECTION_APP_SETTINGS : @[ REVIEW_US, GIVE_FEEDBACK, FITTAG_BLOG ] };
    settingsSectionTitles = [settingsDictionary allKeys];
    
    // Interests flow layout
    
    FTInterestViewFlowLayout *interestFlowLayout = [[FTInterestViewFlowLayout alloc] init];
    [interestFlowLayout setItemSize:CGSizeMake(159.5,42)];
    [interestFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [interestFlowLayout setMinimumInteritemSpacing:0];
    [interestFlowLayout setMinimumLineSpacing:0];
    [interestFlowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [interestFlowLayout setHeaderReferenceSize:CGSizeMake(320,80)];
    
    // View controllers
    
    self.interestsViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:interestFlowLayout];
    self.findFriendsViewController = [[FTFindFriendsViewController alloc] init];
    self.settingsDetailViewController = [[FTSettingsDetailViewController alloc] init];
    
    // Table view footer
    
    UIButton *signout = [UIButton buttonWithType:UIButtonTypeCustom];
    [signout setFrame:CGRectMake( SETTINGS_BUTTON_X, SETTINGS_BUTTON_Y, self.tableView.frame.size.width, SETTINGS_BUTTON_HEIGHT )];
    [signout setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:SETTINGS_BUTTON]]];
    [signout addTarget:self action:@selector(didTapSignoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,40)];
    [footer setBackgroundColor:[UIColor colorWithRed:FT_GRAY_COLOR_RED
                                               green:FT_GRAY_COLOR_GREEN
                                                blue:FT_GRAY_COLOR_BLUE alpha:1.0f]];
    [footer addSubview:signout];
    self.tableView.tableFooterView = footer;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_SETTINGS];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [settingsSectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [settingsSectionTitles objectAtIndex:section];
    NSArray *sectionSettings = [settingsDictionary objectForKey:sectionTitle];
    return sectionSettings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *sectionName = [[UILabel alloc] initWithFrame:CGRectMake(5, -5, 300, 32)];
    sectionName.textAlignment =  NSTextAlignmentLeft;
    sectionName.textColor = [UIColor colorWithRed:FT_RED_COLOR_RED
                                           green:FT_RED_COLOR_GREEN
                                            blue:FT_RED_COLOR_BLUE alpha:1.0f];
    
    sectionName.backgroundColor = [UIColor clearColor];
    sectionName.font = BENDERSOLID(22);
    NSString *sectionNameText = [settingsSectionTitles objectAtIndex:section];
    sectionName.text = NSLocalizedString(sectionNameText,sectionNameText);
    [headerView addSubview:sectionName];
    return headerView;
}

- (FTSettingsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = REUSEABLE_IDENTIFIER_DATA;
    FTSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    NSString *sectionTitle = [settingsSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSettings = [settingsDictionary objectForKey:sectionTitle];
    NSString *setting = [sectionSettings objectAtIndex:indexPath.row];
    cell.textLabel.text = setting;
    cell.textLabel.font = BENDERSOLID(18);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *sectionTitle = [settingsSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSettings = [settingsDictionary objectForKey:sectionTitle];
    NSString *setting = [sectionSettings objectAtIndex:indexPath.row];

    if ([setting isEqualToString:ADD_INTERESTS]) {
        [self.interestsViewController setDelegate:self];
        [self.navigationController pushViewController:self.interestsViewController animated:YES];
        [self.settingsDetailViewController setDetailItem:setting];
    } else if([setting isEqualToString:INVITE_FRIENDS]) {
        //[self.navigationController pushViewController:self.findFriendsViewController animated:YES];
        //[self.settingsDetailViewController setDetailItem:setting];
        
        [[[UIAlertView alloc] initWithTitle:@"Screen Not Finished"
                                    message:@"This find friends screen is not enabled."
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
        
    } else if([setting isEqualToString:GIVE_FEEDBACK]) {
        [self presentFeedbackMessage];
    } else if([setting isEqualToString:REVIEW_US]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:iOS7AppStoreURLFormat,APP_STORE_ID]];
        [[UIApplication sharedApplication] openURL:url];
    } else if([setting isEqualToString:REWARD_SETTIGNS]) {
        
        [[[UIAlertView alloc] initWithTitle:@"Screen Not Finished"
                                    message:@"This rewards settings screen is not enabled."
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
        
    } else {
        [self.navigationController pushViewController:self.settingsDetailViewController animated:YES];
        [self.settingsDetailViewController setDetailItem:setting];
    }
}

#pragma mark - FTInterestsViewControllerDelegate

- (void)interestsViewController:(FTInterestsViewController *)interestsViewController didUpdateUserInterests:(NSArray *)interests {
    [self.navigationController popViewControllerAnimated:YES];
    [self showHudMessage:HUD_MESSAGE_INTERESTS_UPDATED WithDuration:3];
}

#pragma mark - ()

- (void)presentFeedbackMessage {
    if ([MFMailComposeViewController canSendMail]) {
        
        mailer = [[MFMailComposeViewController alloc] init];
        self.mailer.mailComposeDelegate = self;
        [mailer setSubject:MAIL_FEEDBACK_SUBJECT];
        //[mailer setToRecipients:[NSArray arrayWithObjects:MAIL_FEEDBACK_EMAIL, nil]];
        [mailer setToRecipients:[NSArray arrayWithObjects:MAIL_TECH_EMAIL, nil]];
        [mailer setMessageBody:EMPTY_STRING isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:^(){
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:MAIL_FAIL
                                    message:MAIL_NOT_SUPPORTED
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
    }
}

- (void)didTapSignoutButtonAction:(UIButton *)button {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapBackButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(MAIL_CANCELLED);
            break;
        case MFMailComposeResultSaved:
            NSLog(MAIL_SAVED);
            break;
        case MFMailComposeResultSent:
            NSLog(MAIL_SENT);
            
            self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            self.hud.mode = MBProgressHUDModeText;
            self.hud.margin = 10.f;
            self.hud.yOffset = 150.f;
            self.hud.removeFromSuperViewOnHide = YES;
            self.hud.userInteractionEnabled = NO;
            self.hud.labelText = MAIL_SENT;
            [self.hud hide:YES afterDelay:3];
            
            break;
        default:
            NSLog(MAIL_FAIL);
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

