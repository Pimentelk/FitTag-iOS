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
@property (nonatomic, strong) TTTAttributedLabel *termsLabel;
//@property (nonatomic,strong) UITextField *firstnameTextField;
//@property (nonatomic,strong) UITextField *lastnameTextField;
//@property (nonatomic,strong) UITextView *aboutTextView;
@property (nonatomic,strong) UIImageView *signupWithText;
@property (nonatomic,strong) UIButton *profileImageButton;
@property (nonatomic,strong) UIButton *facebookButton;
@property (nonatomic,strong) UIButton *twitterButton;
//@property (nonatomic,strong) UITextField *confirmPasswordTextField;
//@property (nonatomic,strong) UIImageView *termsText;
@property (nonatomic,strong) UITextField *activeField;
@property (nonatomic,strong) UILabel *aLabel;
@end

@implementation FTSignupViewController
@synthesize separators;
@synthesize termsLabel;
@synthesize defaultLabel;
//@synthesize firstnameTextField;
//@synthesize lastnameTextField;
//@synthesize aboutTextView;
@synthesize signupWithText;
@synthesize profileImageButton;
//@synthesize confirmPasswordTextField;
//@synthesize termsText;
@synthesize aLabel;
@synthesize facebookButton;
@synthesize twitterButton;
@synthesize profilePhoto;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // dismissbutton
    [self.signUpView.dismissButton setHidden:YES];
    
    // background
    [self.signUpView setBackgroundColor:FT_RED];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:LOGIN_IMAGE_LOGO];
    [logoImageView setFrame:CGRectMake(0, 0, 320, 79)];
    
    // Set logo image
    [self.signUpView setLogo:logoImageView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideKeyboardAction)];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideKeyboardAction)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view setGestureRecognizers:@[swipeGesture, tapGesture]];
    
    /*
    if (profileImageButton) {
        [profileImageButton removeFromSuperview];
        profileImageButton = nil;
    }
    */
    
    CGFloat padding = (self.signUpView.logo.frame.size.height + 10);
    NSLog(@"logoTop:%f",padding);
    
    /*
    profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[profileImageButton setFrame:CGRectMake((frameSize.width - TAKE_PHOTO_BUTTON) / 2, (((origin - TAKE_PHOTO_BUTTON) / 2) - padding), TAKE_PHOTO_BUTTON, TAKE_PHOTO_BUTTON)];
    [profileImageButton setBackgroundColor:FT_GRAY];
    [profileImageButton addTarget:self action:@selector(didTapLoadCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [profileImageButton setClipsToBounds:YES];
    [profileImageButton.layer setCornerRadius:CORNERRADIUS(TAKE_PHOTO_BUTTON)];
    [profileImageButton setImage:[UIImage imageNamed:IMAGE_PROFILE_EMPTY] forState:UIControlStateNormal];
    [self.signUpView addSubview:profileImageButton];
    */
    
    // Terms
    
    termsLabel = [[TTTAttributedLabel alloc] init];
    [termsLabel setDelegate:self];
    [termsLabel setUserInteractionEnabled:YES];
    [termsLabel setBackgroundColor:[UIColor clearColor]];
    [termsLabel setTextAlignment:NSTextAlignmentCenter];
    [termsLabel setNumberOfLines:0];
    [termsLabel setFont:MULIREGULAR(12)];
    [termsLabel setTextColor:[UIColor whiteColor]];
    [self.signUpView addSubview:termsLabel];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    //CGRect profileImageButtonRect = CGRectMake(0, 0, TAKE_PHOTO_BUTTON, TAKE_PHOTO_BUTTON);
    //[profileImageButton setFrame:profileImageButtonRect];
    
    [self.signUpView.logo setCenter:CGPointMake(160, 80)];
    
    CGRect usernameFieldRect = self.signUpView.usernameField.frame;
    usernameFieldRect.origin.y = (self.signUpView.frame.size.height - (usernameFieldRect.size.height) - 20) / 2;
    
    [self.signUpView.usernameField setFrame:usernameFieldRect];
    [self.signUpView.usernameField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.usernameField setTextColor:[UIColor blackColor]];
    [self.signUpView.usernameField setPlaceholder:PLACEHOLDER_USERNAME];
    [self.signUpView.usernameField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.usernameField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.usernameField setDelegate:self];
    
    CGRect passwordFieldRect = self.signUpView.passwordField.frame;
    passwordFieldRect.origin.y = usernameFieldRect.size.height + usernameFieldRect.origin.y + 10;
    
    [self.signUpView.passwordField setFrame:passwordFieldRect];
    [self.signUpView.passwordField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.passwordField setTextColor:[UIColor blackColor]];
    [self.signUpView.passwordField setPlaceholder:PLACEHOLDER_PASSWORD];
    [self.signUpView.passwordField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setDelegate:self];
    
    CGRect emailFieldRect = self.signUpView.emailField.frame;
    emailFieldRect.origin.y = passwordFieldRect.size.height + passwordFieldRect.origin.y + 10;
    
    [self.signUpView.emailField setFrame:emailFieldRect];
    [self.signUpView.emailField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.emailField setTextColor:[UIColor blackColor]];
    [self.signUpView.emailField setPlaceholder:PLACEHOLDER_EMAIL];
    [self.signUpView.emailField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setDelegate:self];
    
    CGRect signupButtonFrame = self.signUpView.signUpButton.frame;
    signupButtonFrame.origin.y = emailFieldRect.size.height + emailFieldRect.origin.y + 10;
    
    [self.signUpView.signUpButton setFrame:signupButtonFrame];
    
    CGRect cancelButtonFrame = self.signUpView.signUpButton.frame;
    cancelButtonFrame.origin.y = self.signUpView.frame.size.height - cancelButtonFrame.size.height;
    
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
    
    // Profile button position
    
    //CGFloat logoEnds = self.signUpView.logo.frame.size.height + self.signUpView.logo.center.y;
    //CGFloat profileImageButtonY = (((usernameFieldRect.origin.y - logoEnds) - TAKE_PHOTO_BUTTON) / 2) + logoEnds + self.signUpView.logo.frame.size.height;
    
    //CGFloat imageButtonX = self.signUpView.logo.center.x;
    
    //[self.profileImageButton setCenter:CGPointMake(imageButtonX, profileImageButtonY)];
    
    // Terms and condition
    
    CGRect termsFrame = self.signUpView.signUpButton.frame;
    termsFrame.origin.y += termsFrame.size.height + 5;
    [termsLabel setFrame:termsFrame];
    
    NSString *termsText = @"By clicking next you agree to the terms and conditions";
    [termsLabel setText:termsText];
    
    NSRange highlight = [termsText rangeOfString:@"terms and conditions"];
    [termsLabel addLinkToURL:[NSURL URLWithString:@"http://fittag.com/terms.php"] withRange:highlight];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapURLAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [termsLabel addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_SIGNUP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"attributedLabel");
    
    [[UIApplication sharedApplication] openURL:url];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

#pragma mark - ()

- (void)didTapURLAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://fittag.com/terms.php"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didTapCancelButtonAction:(UIButton *)button {    
    [self.signUpView.dismissButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)didTapSignupButtonAction:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeSubmit
                                                           value:nil] build]];
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

- (void)didTapLoadCameraButtonAction:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isProfilePciture = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[camViewController] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - FTEditPhotoViewController

/*
- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo {
    //NSLog(@"%@::camViewController:photo:",VIEWCONTROLLER_SIGNUP);
    self.profilePhoto = photo;
    [self.profileImageButton setImage:photo forState:UIControlStateNormal];
}
*/

@end
