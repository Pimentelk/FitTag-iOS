//
//  UIViewController+FTLinkSocialViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLinkSocialViewController.h"

#define PLACEHOLDER_USERNAME @"Username"
#define PLACEHOLDER_PASSWORD @"Password"

#define TWITTER_LINKED @"Twitter is linked"

#define TOP_PADDING 20
#define TEXTFIELD_PADDING 1

@interface FTLinkSocialViewController() {
    UITextField *username;
    UITextField *password;
    UITableView *tableView;
}
@end

@implementation FTLinkSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Done button
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButtonAction:)];
    [doneButtonItem setStyle:UIBarButtonItemStylePlain];
    [doneButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    // Background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Remove subviews
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Configure the view controller layout
    NSLog(@"self.type = %u",self.type);
    
    [self configLinkAccount];
    
    if (self.type & FTSocialMediaTypeFacebook) {
        NSLog(@"FTSocialMediaTypeFacebook");
        [self.navigationItem setTitle:SOCIAL_FACEBOOK];
        
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            NSLog(@"facebookConfig");
            [self facebookConfig];
        }
        
    } else if (self.type & FTSocialMediaTypeTwitter) {
        NSLog(@"FTSocialMediaTypeTwitter");
        [self.navigationItem setTitle:SOCIAL_TWITTER];
        
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self twitterConfig];
            NSLog(@"twitterConfig");
        }
    } else {
        [self configLinkAccount];
    }
}

#pragma mark - config

- (void)facebookConfig {
    
}

- (void)twitterConfig {
    [username setUserInteractionEnabled:YES];
    [password setUserInteractionEnabled:NO];
    [password setHidden:YES];
    
    NSString *requestString = [NSString stringWithFormat:TWITTER_API_USERS,[PFTwitterUtils twitter].screenName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    [[PFTwitterUtils twitter] signRequest:request];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error){
        NSDictionary* TWuser = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSString *name = [NSString stringWithFormat:@"Connected as %@",[TWuser objectForKey:@"name"]];
        [username setText:name];
        
        UIColor *customColor = [UIColor colorWithRed:FT_GRAY_COLOR_RED green:FT_GRAY_COLOR_GREEN blue:FT_GRAY_COLOR_BLUE alpha:1.0f];
        CGFloat twitterPermissionsY = username.frame.origin.y + username.frame.size.height + 30;
        
        UIView *twitterPermissionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, twitterPermissionsY, self.view.frame.size.width, 40)];
        [twitterPermissionContainer setBackgroundColor:customColor];
        [twitterPermissionContainer setUserInteractionEnabled:YES];
        
        UILabel *twitterPermissionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 280, 40)];
        [twitterPermissionLabel setTextAlignment: NSTextAlignmentLeft];
        [twitterPermissionLabel setFont:[UIFont fontWithName:FITTAG_FONT size:(18.0)]];
        [twitterPermissionLabel setTextColor:[UIColor blackColor]];
        [twitterPermissionLabel setText:TWITTER_LINKED];
        [twitterPermissionContainer addSubview:twitterPermissionLabel];
        
        UISwitch *twitterPermissionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 5, 0, 0)];
        [twitterPermissionSwitch setOn:YES animated:YES];
        [twitterPermissionSwitch addTarget:self action:@selector(didTapTwitterPermissionSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [twitterPermissionContainer addSubview:twitterPermissionSwitch];
        
        [self.view addSubview:twitterPermissionContainer];
    }
}

- (void)configLinkAccount {
    
    // UITextFields
    UIColor *textFieldBackgroundColor = [UIColor colorWithRed:FT_GRAY_COLOR_RED green:FT_GRAY_COLOR_GREEN blue:FT_GRAY_COLOR_BLUE alpha:1.0f];
    UIView *usernameSpacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    UIView *passwordSpacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    CGFloat navigationBarEnd = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    username = [[UITextField alloc] initWithFrame:CGRectMake(0, TOP_PADDING + navigationBarEnd, self.view.frame.size.width, 40)];
    [username setPlaceholder:PLACEHOLDER_USERNAME];
    [username setBackgroundColor:textFieldBackgroundColor];
    [username setTextColor:[UIColor blackColor]];
    [username setLeftViewMode:UITextFieldViewModeAlways];
    [username setLeftView:usernameSpacerView];
    [username setDelegate:self];
    [username setTag:0];
    
    [self.view addSubview:username];
    
    CGFloat usernameEnd = username.frame.size.height + username.frame.origin.y;
    password = [[UITextField alloc] initWithFrame:CGRectMake(0, TEXTFIELD_PADDING + usernameEnd, self.view.frame.size.width, 40)];
    [password setPlaceholder:PLACEHOLDER_PASSWORD];
    [password setBackgroundColor:textFieldBackgroundColor];
    [password setSecureTextEntry:YES];
    [password setTextColor:[UIColor blackColor]];
    [password setLeftViewMode:UITextFieldViewModeAlways];
    [password setLeftView:passwordSpacerView];
    [username setDelegate:self];
    [password setTag:1];
    
    [self.view addSubview:password];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {    // Try to find next responder
        [nextResponder becomeFirstResponder]; // Found next responder, so set it.
    } else {
        [textField resignFirstResponder]; // Not found, so remove keyboard.
    }
    return NO;
}

#pragma mark - ()

- (void)didTapFacebookPermissionSwitchAction:(UISwitch *)permission {
    if ([permission isOn]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",@"public_profile",@"user_friends",nil];
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:permissions block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Facebook enalbed");
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
            }
        }];
    } else {
        [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Facebook disabled");
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
            }
        }];
    }
}

- (void)didTapTwitterPermissionSwitchAction:(UISwitch *)permission {
    if ([permission isOn]) {
        [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Twitter enabled");
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
            }
        }];
    } else {
        [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Twitter disabled");
            }
            
            if (error) {
                NSLog(@"%@ %@",ERROR_MESSAGE,error);
            }
        }];
    }
}

- (void)didTapDoneButtonAction:(UIButton *)button {
    
}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
