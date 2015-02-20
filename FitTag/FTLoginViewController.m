//
//  FitTagLoginViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLoginViewController.h"
#import "UIView+FormScroll.h"

#define PLACEHOLDER_USERNAME @"Username"
#define PLACEHOLDER_PASSWORD @"Password"

@interface FTLoginViewController ()
@property (nonatomic, strong) UIImageView *loginHex;
@property (nonatomic, strong) UIImageView *signupBackground;
@property (nonatomic, strong) UIImageView *fitTagMotto;
@property (nonatomic, strong) UIImageView *signupMessage;
@property (nonatomic, strong) UIImageView *redSignupButton;
@end

@implementation FTLoginViewController
@synthesize loginHex;
@synthesize signupBackground;
@synthesize fitTagMotto;
@synthesize signupMessage;
@synthesize redSignupButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:FT_RED];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(didTapCancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [cancelButton setFrame:CGRectMake((self.logInView.frame.size.width-60)/2, self.logInView.frame.size.height-10, 60, 20)];
    [self.logInView addSubview:cancelButton];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:LOGIN_IMAGE_LOGO];
    [logoImageView setFrame:CGRectMake(0, 0, 320, 79)];
    
    // Set logo image
    [self.logInView setLogo:logoImageView];
    [self.logInView.externalLogInLabel setText:EMPTY_STRING];
    
    // Gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideKeyboardAction:)];
    [self.view setGestureRecognizers:@[ tapGestureRecognizer ]];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.logInView.logo setCenter:CGPointMake(160, 80)];
    
    UITextField *usernameView = self.logInView.usernameField;
    
    CGRect usernameFieldRect = self.logInView.usernameField.frame;
    usernameFieldRect.origin.y = (self.logInView.frame.size.height - (usernameFieldRect.size.height * 2) - 20) / 2;
    
    [usernameView setFrame:usernameFieldRect];
    [usernameView setTextAlignment:NSTextAlignmentLeft];
    [usernameView setTextColor:[UIColor blackColor]];
    [usernameView setPlaceholder:PLACEHOLDER_USERNAME];
    [usernameView setBorderStyle:UITextBorderStyleRoundedRect];
    [usernameView setBackgroundColor:[UIColor whiteColor]];
    [usernameView setDelegate:self];
    
    UITextField *passwordView = self.logInView.passwordField;
    
    CGRect passwordFieldRect = self.logInView.passwordField.frame;
    passwordFieldRect.origin.y = usernameFieldRect.size.height + usernameFieldRect.origin.y + 10;
    
    [passwordView setFrame:passwordFieldRect];
    [passwordView setTextAlignment:NSTextAlignmentLeft];
    [passwordView setTextColor:[UIColor blackColor]];
    [passwordView setPlaceholder:PLACEHOLDER_PASSWORD];
    [passwordView setBorderStyle:UITextBorderStyleRoundedRect];
    [passwordView setBackgroundColor:[UIColor whiteColor]];
    [passwordView setDelegate:self];
    
    [self.logInView.logInButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"Login" forState:UIControlStateSelected];
    [self.logInView.logInButton setTitle:@"Login" forState:UIControlStateHighlighted];
    
    // Signup button
    UIButton *signupButton = self.logInView.logInButton;
    
    CGRect signupButtonFrame = self.logInView.logInButton.frame;
    signupButtonFrame.origin.y = signupButtonFrame.size.height + signupButtonFrame.origin.y + 10;
    
    [signupButton setFrame:signupButtonFrame];
    
    // App version
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    UILabel *appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-130, 15, 120, 20)];
    [appVersionLabel setTextAlignment:NSTextAlignmentRight];
    [appVersionLabel setText:[NSString stringWithFormat:@"v2.0.0 b%@",appVersion]];
    [appVersionLabel setFont:[UIFont fontWithName:@"Gill Sans" size:11]];
    [appVersionLabel setTextColor:[UIColor whiteColor]];
    
    [self.logInView addSubview:appVersionLabel];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_LOGIN];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (float)getCenterX:(float)elementWith {
    return (self.view.frame.size.width)/2.0f - elementWith/2.0f;
}

- (void)didTapHideKeyboardAction:(id)sender {
    [self.logInView.usernameField resignFirstResponder];
    [self.logInView.passwordField resignFirstResponder];
    [self.logInView scrollToY:0];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.logInView scrollToView:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.logInView.usernameField) {
        textField.text = [textField.text lowercaseString];
        return YES;
    }
    return YES;
}

#pragma mark

- (void)didTapCancelButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GAI Event Tracking

- (void)didTapLogInButtonAction:(UIButton *)button {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeLogIn
                                                           value:nil] build]];
}

- (void)didTapForgotPasswordButtonAction:(UIButton *)button {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeForgotPassword
                                                           value:nil] build]];
}

- (void)didTapSignupButtonAction:(UIButton *)button {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeSignUp
                                                           value:nil] build]];
}

- (void)didTapFacebookButtonAction:(UIButton *)button {
    NSLog(@"didTapFacebookButtonAction:");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeFacebook
                                                           value:nil] build]];
}

- (void)didTapTwitterButtonAction:(UIButton *)button {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeTwitter
                                                           value:nil] build]];
}

@end
