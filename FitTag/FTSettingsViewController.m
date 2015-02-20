//
//  FTSettingsActionSheetDelegate.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsCell.h"
#import "FTSettingsViewController.h"
#import "FTInviteFriendsViewController.h"
#import "AppDelegate.h"

#define REUSEABLE_IDENTIFIER_DATA @"DataCell"

#define SIGNOUT_BUTTON @"signout_button"
#define SIGNOUT_BUTTON_X 0
#define SIGNOUT_BUTTON_Y 4
#define SIGNOUT_BUTTON_HEIGHT 32

@interface FTSettingsViewController () <MFMailComposeViewControllerDelegate>

@property NSDictionary *settingsDictionary;
@property NSArray *settingsSectionTitles;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FTSettingsViewController
@synthesize settingsDictionary;
@synthesize settingsSectionTitles;
@synthesize hud;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // Toolbar & Navigationbar Setup
    [self.navigationItem setTitle:NAVIGATION_TITLE_SETTINGS];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set Background
    [self.tableView setBackgroundColor:FT_GRAY];
    
    // Override the back idnicator
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:FT_RED];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.tableView registerClass:[FTSettingsCell class] forCellReuseIdentifier:REUSEABLE_IDENTIFIER_DATA];
    
    // Sections setup
    settingsDictionary = @{ SECTION_EDIT_PROFILE : @[ PROFILE_PICTURE, COVER_PHOTO, EDIT_BIO ],
                            SECTION_ADDITIONAL_INFO : @[ ADD_INTERESTS, INVITE_FRIENDS ],
                            SECTION_SETTINGS : @[ SHARE_SETTINGS, NOTIFICATION_SETTINGS, REWARD_SETTIGNS ],
                            SECTION_APP_SETTINGS : @[ REVIEW_US, GIVE_FEEDBACK, FITTAG_BLOG ] };
    settingsSectionTitles = [settingsDictionary allKeys];
    
    // Table view footer
    
    UIButton *signout = [UIButton buttonWithType:UIButtonTypeCustom];
    [signout setFrame:CGRectMake(SIGNOUT_BUTTON_X, SIGNOUT_BUTTON_Y, self.tableView.frame.size.width, SIGNOUT_BUTTON_HEIGHT)];
    [signout setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:SIGNOUT_BUTTON]]];
    [signout addTarget:self action:@selector(didTapSignoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    [footer setBackgroundColor:FT_GRAY];
    [footer addSubview:signout];
    
    self.tableView.tableFooterView = footer;
    
    // Navigation back button
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc] init];
    [backbutton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backbutton setStyle:UIBarButtonItemStylePlain];
    [backbutton setTarget:self];
    [backbutton setAction:@selector(didTapPopButtonAction:)];
    [backbutton setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backbutton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (delegate && [delegate respondsToSelector:@selector(settingsViewController:viewWillAppear:)]) {
        [delegate settingsViewController:self viewWillAppear:YES];
    }
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
    sectionName.textColor = FT_RED;
    
    sectionName.backgroundColor = [UIColor clearColor];
    sectionName.font = MULIREGULAR(22);
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
    cell.textLabel.font = MULIREGULAR(18);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *sectionTitle = [settingsSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSettings = [settingsDictionary objectForKey:sectionTitle];
    NSString *setting = [sectionSettings objectAtIndex:indexPath.row];
    
    if (delegate && [delegate respondsToSelector:@selector(settingsViewController:didTapSetting:)]) {
        [delegate settingsViewController:self didTapSetting:setting];
    }
    
    if ([setting isEqualToString:ADD_INTERESTS]) {
        
        // Interests flow layout
        FTInterestViewFlowLayout *interestFlowLayout = [[FTInterestViewFlowLayout alloc] init];
        [interestFlowLayout setItemSize:CGSizeMake(self.view.frame.size.width/2,42)];
        [interestFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [interestFlowLayout setMinimumInteritemSpacing:0];
        [interestFlowLayout setMinimumLineSpacing:0];
        [interestFlowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [interestFlowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,80)];
        
        FTInterestsViewController *interestsViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:interestFlowLayout];
        //[interestsViewController setDelegate:self];
        
        [self.navigationController pushViewController:interestsViewController animated:YES];
        
        //FTSettingsDetailViewController *settingsDetailViewController = [[FTSettingsDetailViewController alloc] init];
        //[settingsDetailViewController setDetailItem:setting];
        
    } else if([setting isEqualToString:INVITE_FRIENDS]) {
        
        FTInviteFriendsViewController *inviteFriendsViewController = [[FTInviteFriendsViewController alloc] init];
        inviteFriendsViewController.isSettingsChild = YES;
        
        [self.navigationController pushViewController:inviteFriendsViewController animated:YES];
        
        FTSettingsDetailViewController *settingsDetailViewController = [[FTSettingsDetailViewController alloc] init];
        [settingsDetailViewController setDetailItem:setting];
        
    } else if([setting isEqualToString:GIVE_FEEDBACK]) {
        
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:MAIL_FEEDBACK_SUBJECT];
            //[mailer setToRecipients:[NSArray arrayWithObjects:MAIL_FEEDBACK_EMAIL, nil]];
            [mailer setToRecipients:[NSArray arrayWithObjects:MAIL_TECH_EMAIL, nil]];
            [mailer setMessageBody:EMPTY_STRING isHTML:NO];
            
            [self presentViewController:mailer animated:YES completion:nil];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:MAIL_FAIL
                                        message:MAIL_NOT_SUPPORTED
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
        }
        
    } else if([setting isEqualToString:REVIEW_US]) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:iOS7AppStoreURLFormat,APP_STORE_ID]];
        [[UIApplication sharedApplication] openURL:url];
        
    } else if([setting isEqualToString:REWARD_SETTIGNS]) {
        
        FTSettingsDetailViewController *settingsDetailViewController = [[FTSettingsDetailViewController alloc] init];
        [settingsDetailViewController setDetailItem:setting];
        
        [self.navigationController pushViewController:settingsDetailViewController animated:YES];
        
    } else {
        
        FTSettingsDetailViewController *settingsDetailViewController = [[FTSettingsDetailViewController alloc] init];
        [settingsDetailViewController setDetailItem:setting];
        
        [self.navigationController pushViewController:settingsDetailViewController animated:YES];
    }
}

#pragma mark - FTInterestsViewControllerDelegate

- (void)interestsViewController:(FTInterestsViewController *)interestsViewController
         didUpdateUserInterests:(NSArray *)interests {
    [self.navigationController popViewControllerAnimated:YES];
    [FTUtility showHudMessage:HUD_MESSAGE_INTERESTS_UPDATED WithDuration:3];
}

#pragma mark - ()

- (void)didTapPopButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapSignoutButtonAction:(UIButton *)button {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didTapBackButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
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

