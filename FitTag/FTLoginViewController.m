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
    
    // Set background image
    //[self.logInView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_image_01"]]];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:LOGIN_IMAGE_LOGO];
    [logoImageView setFrame:CGRectMake(0, 0, 320, 79)];
    
    // Set logo image
    [self.logInView setLogo:logoImageView];
    [self.logInView.externalLogInLabel setText:EMPTY_STRING];
    
    // Set motto
    //fitTagMotto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_screen_motto"]];
    //[self.logInView addSubview: self.fitTagMotto];

    /*
    // Set buttons appearance
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateSelected];
    */
    
    // Set login button
    /*
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateNormal];
    [self.logInView.facebookButton addTarget:self action:@selector(didTapFacebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.facebookButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:EMPTY_STRING forState:UIControlStateHighlighted];
    */
    /*
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateHighlighted];
    [self.logInView.twitterButton addTarget:self action:@selector(didTapTwitterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.twitterButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.logInView.twitterButton setTitle:EMPTY_STRING forState:UIControlStateHighlighted];
    */
    /*
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton addTarget:self action:@selector(didTapSignupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.signUpButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:EMPTY_STRING forState:UIControlStateHighlighted];
    
    loginHex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_hex"]];
    [self.logInView addSubview:self.loginHex];
    [self.logInView sendSubviewToBack:self.loginHex];
    
    // Add password forgot button
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot_password"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot_password"] forState:UIControlStateHighlighted];
    [self.logInView.passwordForgottenButton addTarget:self action:@selector(didTapForgotPasswordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.passwordForgottenButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitle:EMPTY_STRING forState:UIControlStateHighlighted];
    
    // disable signup label since we are using an image for our signup message
    [self.logInView.signUpLabel setText:nil];
    
    // Add signup background
    signupBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_screen_overlay"]];
    [self.logInView addSubview:self.signupBackground];
    [self.logInView sendSubviewToBack:self.signupBackground];
    
    // Add signup message
    signupMessage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_screen_message"]];
    [self.signupBackground addSubview:self.signupMessage];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    
    // Set username placeholder text color
    if ([self.logInView.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor grayColor];
        self.logInView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    // Regular username text color: black
    //[self.logInView bringSubviewToFront:self.logInView.usernameField];
    [self.logInView.usernameField setTextAlignment:NSTextAlignmentLeft]; // align placeholder text left
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
    [self.logInView.usernameField setDelegate:self];
    
    // Set password placeholder text color
    if ([self.logInView.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor grayColor];
        self.logInView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    // Regular password text color: black
    //[self.logInView bringSubviewToFront:self.logInView.passwordField];
    [self.logInView.passwordField setTextAlignment:NSTextAlignmentLeft]; // align placeholder text left
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setDelegate:self];
    
    // Clear social external text
    [self.logInView.externalLogInLabel setText:nil];
    
    // Gesture recognizer
    */
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
    
    
    UIButton *signupButton = self.logInView.logInButton;
    
    CGRect signupButtonFrame = self.logInView.logInButton.frame;
    signupButtonFrame.origin.y = signupButtonFrame.size.height + signupButtonFrame.origin.y + 10;
    
    [signupButton setFrame:signupButtonFrame];
    
    /*
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake([self getCenterX: 165.0f],45.0f,165.0f,35.0f)];
    [self.fitTagMotto setFrame:CGRectMake([self getCenterX: CGRectGetWidth(self.fitTagMotto.bounds)],
                                          CGRectGetMaxY(self.logInView.logo.bounds) + CGRectGetHeight(self.logInView.logo.bounds) + CGRectGetHeight(self.fitTagMotto.bounds),
                                          245.0f,17.0f)];
    
    //[self.logInView.facebookButton setFrame:CGRectMake(20.0f, 327.0f, 71.0f, 80.0f)];
    //[self.logInView.twitterButton setFrame:CGRectMake(230.0f, 327.0f, 71.0f, 80.0f)];
    
    [self.signupBackground setFrame:CGRectMake(0.0f,(self.view.frame.size.height) - CGRectGetHeight(self.signupBackground.bounds) + 1.0f,320.0f,71.0f)];
    
    [self.signupMessage setFrame:CGRectMake(CGRectGetWidth(self.signupMessage.bounds) * 0.20f,
                                            (CGRectGetHeight(self.signupBackground.bounds) - CGRectGetHeight(self.signupMessage.bounds))/2.0f,
                                            184.0f,38.0f)];
    
    [self.logInView.signUpButton setFrame:CGRectMake(CGRectGetWidth(self.logInView.signUpButton.bounds),
                                                     ((self.view.frame.size.height) - CGRectGetHeight(self.logInView.signUpButton.bounds)) - 22.0f,
                                                     57.0f,65.0f)];
    
    [self.loginHex setFrame:CGRectMake([self getCenterX: 219.0f], 105.0f, 219.0f, 253.0f)];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
    [self.logInView.logInButton addTarget:self action:@selector(didTapLogInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInView.logInButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:EMPTY_STRING forState:UIControlStateHighlighted];
    
    [self.logInView.logInButton setFrame:CGRectMake([self getCenterX: 32.0f], 310.0f, 32.0f, 17.0f)];
    
    [self.logInView.passwordForgottenButton setFrame:CGRectMake([self getCenterX: 93.0f],135.0f + CGRectGetHeight(self.loginHex.bounds),93.0f,11.0f)];
    [self.logInView.usernameField setFrame:CGRectMake((self.view.frame.size.width)/4.0f - 5.0f,180.0f,190.0f,50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake((self.view.frame.size.width)/4.0f - 5.0f,240.0f,190.0f,50.0f)];
    */
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
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

#pragma mark - ()

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
