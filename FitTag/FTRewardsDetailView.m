//
//  UIViewController+FTRewardsDetailView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTRewardsDetailView.h"

@interface FTRewardsDetailView ()
@property (nonatomic, strong) FTRewardsDetailsHeaderView *headerView;
@property (nonatomic, strong) FTRewardsDetailFooterView *footerView;
@property (nonatomic, strong) UIImageView *rewardPhoto;
@property (nonatomic, strong) UIView *popUpView;
@property BOOL isPopupHidden;
@end

@implementation FTRewardsDetailView
@synthesize reward;
@synthesize rewardPhoto;

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
    
    [self.navigationItem setTitle:@"REWARDS"];
    
    // Override the back idnicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(popDetailViewController:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // remove this offer
    UIBarButtonItem *removeReward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(removeReward:)];
    [removeReward setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:removeReward];
    
    // Set table header
    self.headerView = [[FTRewardsDetailsHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 465.0f) reward:reward];
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    self.footerView = [[FTRewardsDetailFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 73.0f)];
    self.footerView.delegate = self;
    
    self.tableView.tableFooterView = self.footerView;
    
    // Popup View
    CGFloat popupViewWidth = 320.0f;
    CGFloat popupViewHeight = 366.0f;
    CGFloat paddingY = 73.0f;
    CGFloat paddingX = 0.0f;
    
    self.popUpView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, paddingY, popupViewWidth, popupViewHeight)];
    [self.popUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"popup"]]];
    [self.view addSubview:self.popUpView];
    [self.view bringSubviewToFront:self.popUpView];
    //[self.popUpView setHidden:YES];
    self.popUpView.alpha = 0;
    self.isPopupHidden = YES;
    
    UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [yesButton setBackgroundImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [yesButton addTarget:self action:@selector(yesButtonClickHandlerAction) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat yButtonWidth = 80.0f;
    CGFloat yButtonHeight = 92.0f;
    CGFloat yPaddingY = (popupViewHeight - yButtonHeight) / 2;
    CGFloat yPaddingX = popupViewWidth - 61.0f - yButtonWidth;

    [yesButton setFrame:CGRectMake(yPaddingX, yPaddingY, yButtonWidth, yButtonHeight)];
    [self.popUpView addSubview:yesButton];
    
    UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noButton setBackgroundImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [noButton addTarget:self action:@selector(noButtonClickHandlerAction) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat nButtonWidth = 80.0f;
    CGFloat nButtonHeight = 92.0f;
    CGFloat nPaddingY = (popupViewHeight - nButtonHeight) / 2;
    CGFloat nPaddingX = 61.0f;
    
    [noButton setFrame:CGRectMake(nPaddingX, nPaddingY, nButtonWidth, nButtonHeight)];
    [self.popUpView addSubview:noButton];
 
    UILabel *popupMessage = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, nPaddingY + nButtonHeight, 250.0f, 45.0f)];
    popupMessage.textAlignment =  NSTextAlignmentLeft;
    popupMessage.textColor = [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1];
    popupMessage.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(15.0)];
    popupMessage.text = @"After clicking yes, the offer will be emailed to you with instructions on how to redeem.";
    popupMessage.numberOfLines = 0;
    popupMessage.lineBreakMode = NSLineBreakByWordWrapping;
    [self.popUpView addSubview:popupMessage];

}

- (void)yesButtonClickHandlerAction {
    
    [self removePopup];
    PFUser *user = [PFUser currentUser];
    
    if ([user objectForKey:kFTUserEmailKey]) {
        
        NSLog(@"EMAIL: %@",[user objectForKey:kFTUserEmailKey]);
        
        [PFCloud callFunctionInBackground:@"sendTemplate"
                           withParameters:@{@"templateName": @"FitTag Template",@"toEmail": [user objectForKey:kFTUserEmailKey], @"toName": [user objectForKey:kFTUserDisplayNameKey]}
                                    block:^(NSNumber *ratings, NSError *error) {
                                        if (!error) {
                                            
                                            PFObject *activity = [PFObject objectWithClassName:kFTActivityClassKey];
                                            [activity setObject:kFTActivityTypeReward forKey:kFTActivityTypeKey];
                                            [activity setObject:reward forKey:kFTActivityRewardsKey];
                                            [activity setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                                            [activity setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                                            
                                            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                                            [ACL setPublicReadAccess:YES];
                                            activity.ACL = ACL;
                                            
                                            [activity saveEventually];
                                            
                                            NSLog(@"ratings %@",ratings);
                                            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                                  message:@"Email has been sent!"
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles: nil];
                                            [myAlertView show];
                                            
                                        } else {
                                            NSLog(@"Error: %@",error);
                                            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:@"Email could not be sent, make sure your email has been submitted in settings."
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles: nil];
                                            [myAlertView show];
                                        }
                                    }];
    } else {
        
        UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Submit Email"
                                                             message:@"Email not detected, please submit your email address below:"
                                                            delegate:self
                                                   cancelButtonTitle:@"cancel"
                                                   otherButtonTitles:@"OK", nil];
        
        [emailAlert setAlertViewStyle: UIAlertViewStylePlainTextInput];
        [emailAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    // Update email
    PFUser *user = [PFUser currentUser];
    user.email = [[alertView textFieldAtIndex:0] text];
    [user saveEventually:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self yesButtonClickHandlerAction];
        } else {
            user.email = nil;
            UIAlertView *invalidEmail = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                                    message:@"You did not enter a valid email, reward could not be sent."
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                
            [invalidEmail show];
        }
    }];
}

- (void)noButtonClickHandlerAction {
    [self removePopup];
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

- (void)popDetailViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeReward:(id)sender {
    // Block reward
}

#pragma mark - FTRewardsDetailFooterView

- (void)rewardsDetailFooterView:(FTRewardsDetailFooterView *)footerView didTapRedeemButton:(UIButton *)button {
    if (self.isPopupHidden) {
        [self showPopup];
    } else {
        [self removePopup];
    }
}

@end
