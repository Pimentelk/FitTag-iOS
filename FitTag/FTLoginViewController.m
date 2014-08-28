//
//  FitTagLoginViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTLoginViewController.h"
#import <QuickLook/QuickLook.h>
#import "UIView+FormScroll.h"

@interface FTLoginViewController ()
@property (nonatomic, strong) UIImageView *loginHex;
@property (nonatomic, strong) UIImageView *signupBackground;
@property (nonatomic, strong) UIImageView *fitTagMotto;
@property (nonatomic, strong) UIImageView *signupMessage;
@property (nonatomic, strong) UIImageView *redSignupButton;
@end

@implementation FTLoginViewController

- (float)getCenterX:(float)elementWith
{
    return (self.view.frame.size.width)/2.0f - elementWith/2.0f;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@synthesize loginHex, signupBackground, fitTagMotto, signupMessage, redSignupButton;

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background image
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background_image_01"]]];
    
    // Set logo image
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fittag_logo"]]];

    // Set motto
    fitTagMotto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_screen_motto"]];
    [self.logInView addSubview: self.fitTagMotto];

    // Set buttons appearance
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    
    // Set login button
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    loginHex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_hex"]];
    [self.logInView addSubview:self.loginHex];
    [self.logInView sendSubviewToBack:self.loginHex];
    
    // Add password forgot button
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot_password"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot_password"] forState:UIControlStateHighlighted];
    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateHighlighted];
    
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
    
    
    // Clear social external text
    [self.logInView.externalLogInLabel setText:nil];
    
    // Gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.logInView addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake([self getCenterX: 165.0f],45.0f,165.0f,35.0f)];
    [self.fitTagMotto setFrame:CGRectMake([self getCenterX: CGRectGetWidth(self.fitTagMotto.bounds)],
                                          CGRectGetMaxY(self.logInView.logo.bounds) + CGRectGetHeight(self.logInView.logo.bounds) + CGRectGetHeight(self.fitTagMotto.bounds),
                                          245.0f,17.0f)];
    
    [self.logInView.facebookButton setFrame:CGRectMake(20.0f, 327.0f, 71.0f, 80.0f)];
    [self.logInView.twitterButton setFrame:CGRectMake(230.0f, 327.0f, 71.0f, 80.0f)];
    
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
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.logInButton setFrame:CGRectMake([self getCenterX: 32.0f], 310.0f, 32.0f, 17.0f)];
    
    [self.logInView.passwordForgottenButton setFrame:CGRectMake([self getCenterX: 93.0f],135.0f + CGRectGetHeight(self.loginHex.bounds),93.0f,11.0f)];
    [self.logInView.usernameField setFrame:CGRectMake((self.view.frame.size.width)/4.0f - 5.0f,180.0f,190.0f,50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake((self.view.frame.size.width)/4.0f - 5.0f,240.0f,190.0f,50.0f)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard
{
    [self.logInView.usernameField resignFirstResponder];
    [self.logInView.passwordField resignFirstResponder];
    [self.logInView scrollToY:0];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.logInView scrollToView:textField];
}

@end
