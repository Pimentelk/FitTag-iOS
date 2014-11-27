//
//  FTInviteFriendsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTInviteFriendsViewController.h"
#import "FTCollectionHeaderView.h"
#import "FTFlowLayout.h"
#import "FTExternalFriendsView.h"
#import "FTUserProfileViewController.h"

#define REUSABLE_IDENTIFIER_HEADER @"HeaderView"
#define REUSABLE_IDENTIFIER_MEMBER @"MemberCell"
#define REUSABLE_IDENTIFIER_FOOTER @"FooterView"
#define REUSABLE_IDENTIFIER_FOLLOW @"SocialCell"
#define REUSABLE_IDENTIFIER_EXTERN @"ExternCell"

@interface FTInviteFriendsViewController()
@property (nonatomic, strong) UILabel *continueMessage;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) FTExternalFriendsView *externalFriendsView;
@property (nonatomic, strong) FTSocialMediaFriendsView *socialMediaFriendsView;
@property (nonatomic) MBProgressHUD *hud;
@end

@implementation FTInviteFriendsViewController
@synthesize continueButton;
@synthesize continueMessage;
@synthesize externalFriendsView;
@synthesize socialMediaFriendsView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PFUser currentUser]) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
        return;
    }
    
    // View layout
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUND_FIND_FRIENDS]]];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    // Back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Friends already on fittag
    
    CGFloat toolBarHeight = self.navigationController.toolbar.frame.size.height;
    CGFloat followFriendsX = 0;
    CGFloat followFriendsY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    CGFloat followFriendsWidth = self.view.frame.size.width;
    CGFloat followFriendsHeight = ((self.view.frame.size.height - followFriendsY - toolBarHeight) / 2) ;
    
    NSLog(@"followFriendsHeight:%f",followFriendsHeight);
    NSLog(@"self.view.frame.size.height:%f",self.view.frame.size.height);
    NSLog(@"followFriendsY:%f",followFriendsY);
    
    // Social media friends already on the app component
    socialMediaFriendsView = [[FTSocialMediaFriendsView alloc] initWithFrame:CGRectMake(followFriendsX, followFriendsY, followFriendsWidth, followFriendsHeight)
                                                                                 reuseIdentifier:REUSABLE_IDENTIFIER_FOLLOW];
    [socialMediaFriendsView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [socialMediaFriendsView setDelegate:self];
    [self.view addSubview:socialMediaFriendsView];
    
    // Invite external friends
    externalFriendsView = [[FTExternalFriendsView alloc] initWithFrame:CGRectMake(followFriendsX, followFriendsY+followFriendsHeight,
                                                                                               followFriendsWidth, followFriendsHeight)
                                                                           reuseIdentifier:REUSABLE_IDENTIFIER_EXTERN];
    [externalFriendsView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [self.view addSubview:externalFriendsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Label
    continueMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 280, 30)];
    continueMessage.numberOfLines = 0;
    continueMessage.text = @"YOUR JOURNEY STARTS HERE";
    continueMessage.font = BENDERSOLID(22);
    continueMessage.backgroundColor = [UIColor clearColor];
    
    // Toolbar
    continueButton = [[UIButton alloc] initWithFrame:CGRectMake((self.navigationController.toolbar.frame.size.width - 38.0f), 4, 34, 37)];
    [continueButton setBackgroundImage:[UIImage imageNamed:IMAGE_SIGNUP_BUTTON] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(didTapContinueButtonAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.toolbar addSubview:continueMessage];
    [self.navigationController.toolbar addSubview:continueButton];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_INVITE];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [continueMessage removeFromSuperview];
    [continueButton removeFromSuperview];
    
    continueButton = nil;
    continueMessage = nil;
    
    if ([[PFUser currentUser] objectForKey:kFTUserLastLoginKey]) {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

#pragma mark

- (void)didTapBackButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapContinueButtonAction:(UIButton *)button {
    
    if (externalFriendsView.selectedContacts.count > 0) {
        //NSLog(@"selectedContacts.count:%ld",externalViewController.selectedContacts.count);
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        for (NSString *contact in externalFriendsView.selectedContacts) {
            [recipients addObject:[externalFriendsView.contacts objectAtIndex:[contact integerValue]]];
        }
        
        NSLog(@"recipients: %@",recipients);
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]) {
            controller.body = @"SMS message here";
            controller.recipients = recipients;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Can not send text."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            if (self.isSettingsChild == YES) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    
    } else {
        /*
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Can not send text."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        */
        
        if (self.isSettingsChild == YES) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    NSLog(@"messageComposeViewController");
    
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
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isSettingsChild == YES) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - FTSocialMediaFriendsViewControllerDelegate

- (void)socialMediaFriendsView:(FTSocialMediaFriendsView *)socialMediaFriendsView
            didTapProfileImage:(UIButton *)button
                          user:(PFUser *)aUser {
    
    NSLog(@"%@::followCell:didTapProfileImage:user",VIEWCONTROLLER_INVITE);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
    
    FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setUser:aUser];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
