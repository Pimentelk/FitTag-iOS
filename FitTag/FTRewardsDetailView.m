//
//  UIViewController+FTRewardsDetailView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailView.h"
#import "FTBusinessProfileViewController.h"

#define CLOUD_SUCESS_MESSAGE @"Email has been sent!"
#define CLOUD_ERROR_MESSAGE @"Email could not be sent, make sure your email has been submitted in settings."
#define EMAIL_ERROR_MESSAGE @"Email not detected, please submit your email address below:"
#define VALID_EMAIL_ERROR_MESSAGE @"You did not enter a valid email, reward could not be sent."
#define POPUP_MESSAGE @"After clicking yes, the offer will be emailed to you with instructions on how to redeem."

#define POPUP_WIDTH 320.0f
#define POPUP_HEIGHT 366.0f
#define POPUP_PADDING 73.0f

#define IMAGE_REWARDS_POPUP @"popup"

#define NO_BUTTON @"no_button"
#define YES_BUTTON @"yes_button"

#define REWARD_HEADER_HEIGHT 465.0f
#define REWARD_FOOTER_HEIGHT 73.0f

@interface FTRewardsDetailView ()
@property (nonatomic, strong) FTRewardsDetailHeaderView *headerView;
@property (nonatomic, strong) FTRewardsDetailFooterView *footerView;
@property (nonatomic, strong) UIImageView *rewardPhoto;
@property (nonatomic, strong) UIView *popUpView;
@property (nonatomic, strong) UIButton *popupNoButton;
@property BOOL isPopupHidden;
@end

@implementation FTRewardsDetailView
@synthesize reward;
@synthesize rewardPhoto;
@synthesize popupNoButton;

- (id)initWithReward:(PFObject *)aReward {
    self = [super initWithStyle:UITableViewStylePlain];    
    if (self) {
        // The className to query on
        self.parseClassName = @"Dummy";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.reward = aReward;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Title
    [self.navigationItem setTitle:NAVIGATION_TITLE_REWARDS];
    
    // back button
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // remove this offer button
    UIBarButtonItem *removeReward = [[UIBarButtonItem alloc] init];
    [removeReward setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_TRASH]];
    [removeReward setStyle:UIBarButtonItemStylePlain];
    [removeReward setTarget:self];
    [removeReward setAction:@selector(didTapRemoveRewardButtonAction:)];
    [removeReward setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setRightBarButtonItem:removeReward];
    
    // Set table header
    
    self.headerView = [[FTRewardsDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, REWARD_HEADER_HEIGHT) reward:reward];
    self.headerView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCouponImageAction:)];
    [tapGesture setNumberOfTapsRequired:2];
    
    // Set table footer
    
    self.footerView = [[FTRewardsDetailFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, REWARD_FOOTER_HEIGHT)];
    self.footerView.delegate = self;
    self.tableView.tableFooterView = self.footerView;
    
    if (self.footerView.canRedeem) {
        [self.headerView addGestureRecognizer:tapGesture];        
    }
    
    // Popup View
    
    self.popUpView = [[UIView alloc] initWithFrame:CGRectMake(( self.view.frame.size.width - POPUP_WIDTH ) / 2, POPUP_PADDING, POPUP_WIDTH, POPUP_HEIGHT)];
    [self.popUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:IMAGE_REWARDS_POPUP]]];
    [self.view addSubview:self.popUpView];
    [self.view bringSubviewToFront:self.popUpView];
    self.popUpView.alpha = 0;
    self.isPopupHidden = YES;
    
    // Popup yes Button
    
    UIButton *popupYesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [popupYesButton setBackgroundImage:[UIImage imageNamed:YES_BUTTON] forState:UIControlStateNormal];
    [popupYesButton addTarget:self
                       action:@selector(didTapYesButtonAction)
             forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat yButtonWidth = 80.0f;
    CGFloat yButtonHeight = 92.0f;
    CGFloat yPaddingY = (POPUP_HEIGHT - yButtonHeight) / 2;
    CGFloat yPaddingX = POPUP_WIDTH - 61.0f - yButtonWidth;

    [popupYesButton setFrame:CGRectMake(yPaddingX, yPaddingY, yButtonWidth, yButtonHeight)];
    [self.popUpView addSubview:popupYesButton];
    
    // Popup no Button
    
    popupNoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [popupNoButton setBackgroundImage:[UIImage imageNamed:NO_BUTTON] forState:UIControlStateNormal];
    [popupNoButton addTarget:self
                      action:@selector(didTapNoButtonAction)
            forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat nButtonWidth = 80.0f;
    CGFloat nButtonHeight = 92.0f;
    CGFloat nPaddingY = (POPUP_HEIGHT - nButtonHeight) / 2;
    CGFloat nPaddingX = 61.0f;
    
    [popupNoButton setFrame:CGRectMake(nPaddingX, nPaddingY, nButtonWidth, nButtonHeight)];
    [self.popUpView addSubview:popupNoButton];
    
    // Popup message
    
    UILabel *popupMessage = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, nPaddingY + nButtonHeight, 250.0f, 45.0f)];
    popupMessage.textAlignment =  NSTextAlignmentLeft;
    popupMessage.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
    popupMessage.font = BENDERSOLID(15);
    popupMessage.text = POPUP_MESSAGE;
    popupMessage.numberOfLines = 0;
    popupMessage.lineBreakMode = NSLineBreakByWordWrapping;
    [self.popUpView addSubview:popupMessage];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_REWARDS_DETAIL];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didTapNoButtonAction {
    [self removePopup];
}

- (void)didTapYesButtonAction {
    
    [self removePopup];
    PFUser *user = [PFUser currentUser];
    
    if ([user objectForKey:kFTUserEmailKey]) {
        //NSLog(@"EMAIL: %@",[user objectForKey:kFTUserEmailKey]);
        
        [PFCloud callFunctionInBackground:@"sendTemplate"
                           withParameters:@{@"templateName": @"FitTag Template",
                                            @"toEmail": [user objectForKey:kFTUserEmailKey],
                                            @"toName": [user objectForKey:kFTUserDisplayNameKey]}
         
                                    block:^(NSNumber *ratings, NSError *error) {
                                        if (!error) {
                                            
                                            PFObject *activity = [PFObject objectWithClassName:kFTActivityClassKey];
                                            [activity setObject:kFTActivityTypeRedeem forKey:kFTActivityTypeKey];
                                            [activity setObject:reward forKey:kFTActivityRewardKey];
                                            [activity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                                            [activity setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                                            
                                            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                                            [ACL setPublicReadAccess:YES];
                                            activity.ACL = ACL;
                                            
                                            [activity saveEventually];
                                            
                                            //NSLog(@"ratings %@",ratings);
                                            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                                  message:CLOUD_SUCESS_MESSAGE
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles: nil];
                                            [myAlertView show];
                                            
                                        } else {
                                            NSLog(@"Error: %@",error);
                                            [[[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                        message:CLOUD_ERROR_MESSAGE
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles: nil] show];
                                            
                                        }
                                    }];
    } else {
        UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Submit Email"
                                                             message:EMAIL_ERROR_MESSAGE
                                                            delegate:self
                                                   cancelButtonTitle:@"cancel"
                                                   otherButtonTitles:@"OK", nil];
        [emailAlert setAlertViewStyle: UIAlertViewStylePlainTextInput];
        [emailAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    // Update email
    PFUser *user = [PFUser currentUser];
    user.email = [[alertView textFieldAtIndex:0] text];
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self didTapYesButtonAction];
        } else {
            user.email = nil;
            
            [[[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                        message:VALID_EMAIL_ERROR_MESSAGE
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}



- (void)showPopup {
    self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.popUpView.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.alpha = 1;
        self.popUpView.transform = CGAffineTransformMakeScale(1, 1);
        self.isPopupHidden = NO;
    }];
}

- (void)removePopup {
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.isPopupHidden = YES;
        }
    }];
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didTapRemoveRewardButtonAction:(id)sender {
    
    if (!self.reward) {
        [[[UIAlertView alloc] initWithTitle:@"Delete Error"
                                   message:@"Could not delete this reward."
                                  delegate:self
                         cancelButtonTitle:@"OK" 
                         otherButtonTitles:nil] show];
        return;
    }
    
    // create and save photo caption
    PFObject *delete = [PFObject objectWithClassName:kFTActivityClassKey];
    [delete setObject:kFTActivityTypeDelete forKey:kFTActivityTypeKey];
    [delete setObject:reward forKey:kFTActivityRewardKey];
    [delete setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
    [delete setObject:[reward objectForKey:kFTRewardUserKey] forKey:kFTActivityToUserKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    delete.ACL = ACL;
    
    [delete saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [FTUtility showHudMessage:@"Successfully Deleted" WithDuration:3];
            [self didTapBackButtonAction:nil];
        }
    }];
}

#pragma mark - FTRewardsDetailFooterViewDelegate

- (void)rewardsDetailFooterView:(FTRewardsDetailFooterView *)footerView didTapRedeemButton:(UIButton *)button {
    if (self.isPopupHidden) {
        [self showPopup];
    } else {
        [self removePopup];
    }
}

#pragma mark - FTRewardsDetailHeaderViewDelegate

- (void)rewardsDetailHeaderView:(FTRewardsDetailHeaderView *)rewardsDetailHeaderView didTapBusinessButton:(UIButton *)button business:(PFUser *)business {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
    
    FTBusinessProfileViewController *businessProfileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [businessProfileViewController setBusiness:business];
    [self.navigationController pushViewController:businessProfileViewController animated:YES];
}

#pragma mark - ()

- (void)didTapCouponImageAction:(id)sender {
    if (self.isPopupHidden) {
        [self showPopup];
    } else {
        [self removePopup];
    }
}

@end
