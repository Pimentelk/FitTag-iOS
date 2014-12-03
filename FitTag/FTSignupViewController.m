//
//  FitTagSignupViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSignupViewController.h"
#import "FTCamViewController.h"
#import "UIView+FormScroll.h"
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
#define PLACEHOLDER_USERNAME @"USERNAME"
#define PLACEHOLDER_EMAIL @"EMAIL ADDRESS"
#define PLACEHOLDER_PASSWORD @"PASSWORD"
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
    
    UIColor *attrColor = [UIColor grayColor];
    
    // Set logo
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]]];
    
    // Dismiss Button
    [self.signUpView.dismissButton setBackgroundImage:[UIImage imageNamed:@"dismiss_button"] forState:UIControlStateNormal];
    
    // Set profile photo
    profileImageButton = [[UIButton alloc] init];
    [self.profileImageButton setBackgroundImage:[UIImage imageNamed:ADD_PHOTO] forState:UIControlStateNormal];
    [self.profileImageButton setBackgroundImage:[UIImage imageNamed:ADD_PHOTO] forState:UIControlStateHighlighted];
    [self.profileImageButton addTarget:self action:@selector(didTapLoadCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.signUpView addSubview:self.profileImageButton];
    
    // Or signup with
    aLabel = [[UILabel alloc]init];
    aLabel.numberOfLines = 0;
    aLabel.font = [UIFont systemFontOfSize:7];
    aLabel.textColor = [UIColor blackColor];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.text = @"OR SIGNUP WITH:";
    
    //[self.signUpView addSubview:aLabel];
    
    // facebook button
    facebookButton = [[UIButton alloc] init];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:FACEBOOK_BUTTON] forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(didTapFacebookLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.signUpView addSubview:self.facebookButton];
    
    // twitter button
    twitterButton = [[UIButton alloc] init];
    [self.twitterButton setBackgroundImage:[UIImage imageNamed:TWITTER_BUTTON] forState:UIControlStateNormal];
    [self.twitterButton addTarget:self action:@selector(didTapTwitterLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.signUpView addSubview:self.twitterButton];
    
    // Set signup red button
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:SIGNUP_BUTTON] forState: UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    
    /*
    // Implement firstname textfield
    firstnameTextField = [[UITextField alloc] init];
    [self.firstnameTextField setPlaceholder:PLACEHOLDER_FIRSTNAME];
    [self.firstnameTextField setDelegate:self];
    [self.firstnameTextField setFont:BENDERSOLID(16)];
    [self.firstnameTextField setTextAlignment:NSTextAlignmentLeft];
    [self.firstnameTextField addTarget: self action:@selector(didChangeFirstNameTextFieldAction:) forControlEvents:UIControlEventEditingChanged];
    
    //[self.signUpView addSubview:self.firstnameTextField];
    */
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHideKeyboardAction)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    /*
    // Implement lastname textfield
    lastnameTextField = [[UITextField alloc] init];
    [self.lastnameTextField setPlaceholder:PLACEHOLDER_LASTNAME];
    [self.lastnameTextField setDelegate:self];
    [self.lastnameTextField setFont:BENDERSOLID(16)];
    [self.lastnameTextField setTextAlignment:NSTextAlignmentLeft];
    [lastnameTextField addTarget:self action:@selector(didChangeLastNameTextFieldAction:) forControlEvents:UIControlEventEditingChanged];
    
    //[self.signUpView addSubview:self.lastnameTextField];
    
    // Implement confirm password textfield
    confirmPasswordTextField = [[UITextField alloc] init];
    [self.confirmPasswordTextField setPlaceholder:PLACEHOLDER_CONFIRM];
    [self.confirmPasswordTextField setDelegate:self];
    [self.confirmPasswordTextField setFont:BENDERSOLID(16)];
    [self.confirmPasswordTextField setTextAlignment:NSTextAlignmentLeft];
    [self.confirmPasswordTextField setSecureTextEntry:YES];
    [self.confirmPasswordTextField addTarget:self action:@selector(didConfirmTextFieldFinish:) forControlEvents:UIControlEventEditingChanged];
    
    //[self.signUpView addSubview:self.confirmPasswordTextField];
    */
    
    // Set password confirm
    //[self setIsPasswordConfirmed:NO];
    
    // Implement about textview
    /*
    aboutTextView = [[UITextView alloc] init];
    [self.aboutTextView setDelegate:self];
    [self.aboutTextView setBackgroundColor:nil];
    defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    [self.defaultLabel setTextColor:attrColor];
    [self.defaultLabel setFont:BENDERSOLID(16)];
    [self.defaultLabel setText:DEFAULT_BIO_TEXT_B];
    [self.aboutTextView addSubview:self.defaultLabel];
    [self.signUpView addSubview:self.aboutTextView];
    */
    // Align username, email, password text fields left
    [self.signUpView.usernameField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.usernameField setTextColor:attrColor];
    [self.signUpView.usernameField setPlaceholder:PLACEHOLDER_USERNAME];
    //[self.signUpView.usernameField setFont:BENDERSOLID(16)];
    
    [self.signUpView.emailField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.emailField setTextColor:attrColor];
    [self.signUpView.emailField setPlaceholder:PLACEHOLDER_EMAIL];
    //[self.signUpView.emailField setFont:BENDERSOLID(16)];

    [self.signUpView.passwordField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.passwordField setTextColor:attrColor];
    [self.signUpView.passwordField setPlaceholder:PLACEHOLDER_PASSWORD];
    //[self.signUpView.passwordField setFont:BENDERSOLID(16)];
    
    // Setup terms text
    termsText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SIGNUP_SCREEN_TEXT]];
    [self.signUpView addSubview:self.termsText];
    
    // Set signup grid/separators
    separators = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SEPARATORS]];
    [self.signUpView addSubview:self.separators];
    [self.signUpView sendSubviewToBack:self.separators];
    
    // Set background image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SIGNUP_BACKGROUND_IMAGE]];
    [backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 568)];
    [self.signUpView addSubview:backgroundImageView];
    [self.signUpView sendSubviewToBack:backgroundImageView];
    
    [self.signUpView setBackgroundColor:[UIColor clearColor]];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    float logoPositionY = 30.0f;
    
    [self.separators setFrame:CGRectMake(0, 0, self.view.frame.size.width, 568)];
    [self.signUpView.logo setFrame:CGRectMake([self getCenterX:165.0f], logoPositionY, 165.0f, 35.0f)];
    [self.profileImageButton setFrame:CGRectMake(10.0f, 80.0f, 71.0f, 83.0f)];
    NSInteger centerLabelX = self.profileImageButton.frame.origin.x + self.profileImageButton.frame.size.width + 5.0f;
    NSInteger centerLabelY = (self.profileImageButton.frame.origin.y + (self.profileImageButton.frame.size.height / 2)) - 15;
    [self.aLabel setFrame: CGRectMake(centerLabelX, centerLabelY, 70, 30)];
    [self.facebookButton setFrame:CGRectMake(centerLabelX + self.aLabel.frame.size.width, 80.0f, 71.0f, 83.0f)];
    [self.twitterButton setFrame:CGRectMake(self.facebookButton.frame.origin.x + self.facebookButton.frame.size.width + 12.0f, 80.0f, 71.0f, 83.0f)];
    [self.signupWithText setFrame:CGRectMake(85.0f, 120.0f, 77.0f, 8.0f)];
    //[self.firstnameTextField setFrame:CGRectMake(10.0f, 173.0f, 140.0f, 35.0f)];
    //[self.lastnameTextField setFrame:CGRectMake(160.0f, 173.0f, 140.0f, 35.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(10.0f, 213.0f, 280.0f, 35.0f)];
    [self.signUpView.usernameField setFrame:CGRectMake(10.0f, 253.0f, 280.0f, 35.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(10.0f, 293.0f, 280.0f, 35.0f)];
    //[self.confirmPasswordTextField setFrame:CGRectMake(10.0f, 333.0f, 280.0f, 35.0f)];
    //[self.aboutTextView setFrame:CGRectMake(10.0f, 373.0f, 300.0f, 100.0f)];
    [self.termsText setFrame:CGRectMake([self getCenterX:240.0f], self.separators.frame.size.height - 90, 240.0f, 7.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake([self getCenterX:57.0f],self.separators.frame.size.height - 65 - 5, 57.0f, 65.0f)];
    
    [self.signUpView setScrollEnabled:YES];
    [self.signUpView setContentSize:CGSizeMake(self.view.frame.size.width, 568)];
    [self.signUpView setBounces:NO];
    self.signUpView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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
    [self.signUpView scrollElement:textView toPoint:160];
}

- (void)textViewDidChange:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
    //self.about = aboutTextView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.signUpView scrollElement:textField toPoint:160];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark - ()

- (void)didTapFacebookLoginButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didTapTwitterLoginButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didTapSignupButtonAction:(id)sender {
    //[self.firstnameTextField resignFirstResponder];
    //[self.lastnameTextField resignFirstResponder];
    //[self.confirmPasswordTextField resignFirstResponder];
    //[self.aboutTextView resignFirstResponder];
    [self.signUpView.passwordField resignFirstResponder];
    [self.signUpView.emailField resignFirstResponder];
    [self.signUpView.usernameField resignFirstResponder];
}

- (void)didTapLoadCameraButtonAction:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isProfilePciture = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ camViewController ] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didTapHideKeyboardAction {
    //[self.firstnameTextField resignFirstResponder];
    //[self.lastnameTextField resignFirstResponder];
    //[self.confirmPasswordTextField resignFirstResponder];
    //[self.aboutTextView resignFirstResponder];
    [self.signUpView.passwordField resignFirstResponder];
    [self.signUpView.emailField resignFirstResponder];
    [self.signUpView.usernameField resignFirstResponder];
    [self.signUpView scrollToY:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (float)getCenterX:(float)elementWith{
    return (self.view.frame.size.width)/2.0f - elementWith/2.0f;
}

- (void)didChangeFirstNameTextFieldAction:(id)sender {
    //self.firstname = firstnameTextField.text;
}

- (void)didChangeLastNameTextFieldAction:(id)sender {
    //self.lastname = lastnameTextField.text;
}

/*
- (void)didConfirmTextFieldFinish:(id)sender {
    if([self.signUpView.passwordField.text isEqual:self.confirmPasswordTextField.text]){
        //[self setIsPasswordConfirmed:YES];
    } else {
        //[self setIsPasswordConfirmed:NO];
    }
}
*/

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

@end
