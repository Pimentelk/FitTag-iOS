//
//  FitTagSignupViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSignupViewController.h"
#import "FTCamViewController.h"
//#import "UIView+FormScroll.h"
#import "ImageCustomNavigationBar.h"

#define ADD_PHOTO @"add_photo"
#define FITTAG_LOGO @"fittag_logo"
#define SEPARATORS @"separators"
#define SIGNUP_BACKGROUND_IMAGE @"signup_screen_background_image"
#define FACEBOOK_BUTTON @"facebook_button"
#define TWITTER_BUTTON @"twitter_button"
#define SIGNUP_BUTTON @"signup_button"
#define PLACEHOLDER_FIRSTNAME @"FIRST NAME"
#define PLACEHOLDER_LASTNAME @"LAST NAME"
#define PLACEHOLDER_CONFIRM @"CONFIRM PASSWORD"
#define PLACEHOLDER_USERNAME @"Username"
#define PLACEHOLDER_EMAIL @"Email address"
#define PLACEHOLDER_PASSWORD @"Password"
#define SIGNUP_SCREEN_TEXT @"signup_screen_terms_text"

@interface FTSignupViewController ()
@property (nonatomic,strong) UIImageView *separators;
@property (nonatomic,strong) UILabel *defaultLabel;
//@property (nonatomic,strong) UITextField *firstnameTextField;
//@property (nonatomic,strong) UITextField *lastnameTextField;
//@property (nonatomic,strong) UITextView *aboutTextView;
@property (nonatomic,strong) UIImageView *signupWithText;
@property (nonatomic,strong) UIButton *profileImageButton;
@property (nonatomic,strong) UIButton *facebookButton;
@property (nonatomic,strong) UIButton *twitterButton;
//@property (nonatomic,strong) UITextField *confirmPasswordTextField;
@property (nonatomic,strong) UIImageView *termsText;
@property (nonatomic,strong) UITextField *activeField;
@property (nonatomic,strong) UILabel *aLabel;
@end

@implementation FTSignupViewController
@synthesize separators;
@synthesize defaultLabel;
//@synthesize firstnameTextField;
//@synthesize lastnameTextField;
//@synthesize aboutTextView;
@synthesize signupWithText;
@synthesize profileImageButton;
//@synthesize confirmPasswordTextField;
@synthesize termsText;
@synthesize aLabel;
@synthesize facebookButton;
@synthesize twitterButton;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // dismissbutton
    [self.signUpView.dismissButton setHidden:YES];
    
    // background
    [self.signUpView setBackgroundColor:FT_RED];
    
    // Set logo
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(didTapHideKeyboardAction)];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(didTapHideKeyboardAction)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view setGestureRecognizers:@[ swipeGestureRecognizer, tapGestureRecognizer ]];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect usernameFieldRect = self.signUpView.usernameField.frame;
    usernameFieldRect.origin.y = (self.signUpView.frame.size.height - (usernameFieldRect.size.height * 3) - 20) / 2;
    
    [self.signUpView.usernameField setFrame:usernameFieldRect];
    [self.signUpView.usernameField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.usernameField setTextColor:[UIColor blackColor]];
    [self.signUpView.usernameField setPlaceholder:PLACEHOLDER_USERNAME];
    [self.signUpView.usernameField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    
    CGRect passwordFieldRect = self.signUpView.passwordField.frame;
    passwordFieldRect.origin.y = usernameFieldRect.size.height + usernameFieldRect.origin.y + 10;
    
    [self.signUpView.passwordField setFrame:passwordFieldRect];
    [self.signUpView.passwordField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.passwordField setTextColor:[UIColor blackColor]];
    [self.signUpView.passwordField setPlaceholder:PLACEHOLDER_PASSWORD];
    [self.signUpView.passwordField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    
    CGRect emailFieldRect = self.signUpView.emailField.frame;
    emailFieldRect.origin.y = passwordFieldRect.size.height + passwordFieldRect.origin.y + 10;
    
    [self.signUpView.emailField setFrame:emailFieldRect];
    [self.signUpView.emailField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.emailField setTextColor:[UIColor blackColor]];
    [self.signUpView.emailField setPlaceholder:PLACEHOLDER_EMAIL];
    [self.signUpView.emailField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    
    CGRect signupButtonFrame = self.signUpView.signUpButton.frame;
    signupButtonFrame.origin.y = emailFieldRect.size.height + emailFieldRect.origin.y + 10;
    
    [self.signUpView.signUpButton setFrame:signupButtonFrame];
    
    CGRect cancelButtonFrame = self.signUpView.signUpButton.frame;
    cancelButtonFrame.origin.y = signupButtonFrame.origin.y + signupButtonFrame.size.height + 10;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    [cancelButton addTarget:self action:@selector(didTapCancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.signUpView addSubview:cancelButton];
    
    [self.signUpView setScrollEnabled:YES];
    [self.signUpView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    [self.signUpView setBounces:YES];
    [self.signUpView setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_SIGNUP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.defaultLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
}

#pragma mark - ()

- (void)didTapCancelButtonAction:(UIButton *)button {
    [self.signUpView.dismissButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)didTapSignupButtonAction:(id)sender {
    [self.signUpView.passwordField resignFirstResponder];
    [self.signUpView.emailField resignFirstResponder];
    [self.signUpView.usernameField resignFirstResponder];
}

- (void)didTapHideKeyboardAction {
    [self.signUpView.passwordField resignFirstResponder];
    [self.signUpView.emailField resignFirstResponder];
    [self.signUpView.usernameField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (float)getCenterX:(float)elementWith{
    return (self.view.frame.size.width)/2.0f - elementWith/2.0f;
}

/*
 - (void)didTapLoadCameraButtonAction:(id)sender {
 FTCamViewController *camViewController = [[FTCamViewController alloc] init];
 camViewController.delegate = self;
 camViewController.isProfilePciture = YES;
 
 UINavigationController *navController = [[UINavigationController alloc] init];
 [navController setViewControllers:@[ camViewController ] animated:NO];
 [self presentViewController:navController animated:YES completion:nil];
 }
 */

/*
#pragma mark - FTEditPhotoViewController

- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo {
    //NSLog(@"%@::camViewController:photo:",VIEWCONTROLLER_SIGNUP);
    self.profilePhoto = photo;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:photo];
    [imageView setFrame:CGRectMake(10, 80, 80, 80)];
    [imageView setUserInteractionEnabled:YES];
    [imageView setClipsToBounds:YES];
    [imageView.layer setCornerRadius:CORNERRADIUS(80)];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLoadCameraButtonAction:)];
    [singleTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:singleTap];
    
    
    [self.profileImageButton removeFromSuperview];
    [self.signUpView addSubview:imageView];
}
*/

@end
