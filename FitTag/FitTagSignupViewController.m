//
//  FitTagSignupViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "FitTagSignupViewController.h"
#import "UIView+FormScroll.h"
#import "ImageCollectionViewController.h"
#import "ImageCustomNavigationBar.h"

@interface FitTagSignupViewController ()
@property (nonatomic,strong) UIImageView *separators;
@property (nonatomic,strong) UILabel *defaultLabel;
@property (nonatomic,strong) UITextField *firstnameTextField;
@property (nonatomic,strong) UITextField *lastnameTextField;
@property (nonatomic,strong) UITextView *aboutTextView;
@property (nonatomic,strong) UIImageView *signupWithText;
@property (nonatomic,strong) UIButton *profileImageButton;
@property (nonatomic,strong) UITextField *confirmPasswordTextField;
@property (nonatomic,strong) UIImageView *termsText;
@property (nonatomic,strong) UITextField *activeField;
@end

@implementation FitTagSignupViewController

@synthesize separators, defaultLabel, firstnameTextField, lastnameTextField, aboutTextView, signupWithText, profileImageButton, confirmPasswordTextField, termsText;

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background image
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"signup_screen_background_image"]]];
    
    
    // Set form background
    separators = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separators"]];
    [self.signUpView addSubview:self.separators];
    [self.signUpView sendSubviewToBack:self.separators];
    
    // Set logo
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fittag_logo"]]];
    
    // Set profile photo
    profileImageButton = [[UIButton alloc] init];
    [self.profileImageButton setBackgroundImage:[UIImage imageNamed:@"add_photo"] forState:UIControlStateNormal];
    [self.profileImageButton setBackgroundImage:[UIImage imageNamed:@"add_photo"] forState:UIControlStateHighlighted];
    [self.signUpView addSubview:self.profileImageButton];
    [self.profileImageButton addTarget:self
                                action:@selector(loadCameraRoll)
                      forControlEvents:UIControlEventTouchUpInside];
    
    // Or signup with
    signupWithText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_screen_or_signup_with"]];
    [self.signUpView addSubview:self.signupWithText];
    
    // Set signup red button
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState: UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState: UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];

    // Implement firstname textfield
    firstnameTextField = [[UITextField alloc] init];
    [self.firstnameTextField setPlaceholder:@"FIRST NAME"];
    [self.firstnameTextField setDelegate:self];
    [self.signUpView addSubview:self.firstnameTextField];
    [self.firstnameTextField setTextAlignment:NSTextAlignmentLeft];
    [self.firstnameTextField addTarget: self
                           action:@selector(firstnameTextFieldDidChange)
                 forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.signUpView addGestureRecognizer:gestureRecognizer];
    
    // Implement lastname textfield
    lastnameTextField = [[UITextField alloc] init];
    [self.lastnameTextField setPlaceholder:@"LAST NAME"];
    [self.lastnameTextField setDelegate:self];
    [self.signUpView addSubview:self.lastnameTextField];
    [self.lastnameTextField setTextAlignment:NSTextAlignmentLeft];
    [lastnameTextField addTarget:self
                          action:@selector(lastnameTextFieldDidChange)
                forControlEvents:UIControlEventEditingChanged];
    
    // Implement confirm password textfield
    confirmPasswordTextField = [[UITextField alloc] init];
    [self.confirmPasswordTextField setPlaceholder:@"CONFIRM PASSWORD"];
    [self.confirmPasswordTextField setDelegate:self];
    [self.signUpView addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordTextField setTextAlignment:NSTextAlignmentLeft];
    [self.confirmPasswordTextField setSecureTextEntry:YES];
    [self.confirmPasswordTextField addTarget:self
                        action:@selector(confirmTextFieldDidFinish)
              forControlEvents:UIControlEventEditingDidEnd];
    
    // Set password confirm
    [self setIsPasswordConfirmed:NO];
    
    // Implement about textview
    aboutTextView = [[UITextView alloc] init];
    [self.aboutTextView setDelegate:self];
    [self.aboutTextView setBackgroundColor:nil];
    defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    [self.defaultLabel setTextColor:[UIColor grayColor]];
    [self.defaultLabel setText: @"WHAT MAKES YOU, YOU? (OPTIONAL)"];
    [self.aboutTextView addSubview:self.defaultLabel];
    [self.signUpView addSubview:self.aboutTextView];
    
    // Align username, email, password text fields left
    [self.signUpView.usernameField setTextAlignment:NSTextAlignmentLeft];
    // Set username placeholder text color
    if ([self.signUpView.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor grayColor];
        self.signUpView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"USERNAME" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    [self.signUpView.emailField setTextAlignment:NSTextAlignmentLeft];
    // Set username placeholder text color
    if ([self.signUpView.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor grayColor];
        self.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"EMAIL ADDRESS" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    [self.signUpView.passwordField setTextAlignment:NSTextAlignmentLeft];
    // Set username placeholder text color
    if ([self.signUpView.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor grayColor];
        self.signUpView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    // Setup terms text
    termsText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_screen_terms_text"]];
    [self.signUpView addSubview:self.termsText];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    float logoPositionY = 30.0f;
    
    [self.separators setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f)];
    [self.signUpView.logo setFrame:CGRectMake([self getCenterX:165.0f], logoPositionY, 165.0f, 35.0f)];
    [self.profileImageButton setFrame:CGRectMake(10.0f, 80.0f, 71.0f, 83.0f)];
    [self.signupWithText setFrame:CGRectMake(85.0f, 120.0f, 77.0f, 8.0f)];
    [self.firstnameTextField setFrame:CGRectMake(10.0f, 173.0f, 140.0f, 35.0f)];
    [self.lastnameTextField setFrame:CGRectMake(160.0f, 173.0f, 140.0f, 35.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(10.0f, 213.0f, 140.0f, 35.0f)];
    [self.signUpView.usernameField setFrame:CGRectMake(10.0f, 253.0f, 140.0f, 35.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(10.0f, 293.0f, 140.0f, 35.0f)];
    [self.confirmPasswordTextField setFrame:CGRectMake(10.0f, 333.0f, 240.0f, 35.0f)];
    [self.aboutTextView setFrame:CGRectMake(10.0f, 373.0f, 300.0f, 100.0f)];
    [self.termsText setFrame:CGRectMake([self getCenterX:240.0f], (self.view.frame.size.height - (87.0f)), 240.0f, 7.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake([self getCenterX:57.0f], (self.view.frame.size.height - (65.0f + 5.0f)), 57.0f, 65.0f)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
    self.defaultLabel.hidden = YES;
    [self.signUpView scrollToView:textView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.defaultLabel.hidden = ([textView.text length] > 0);
    self.about = aboutTextView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.defaultLabel.hidden = ([textView.text length] > 0);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.signUpView scrollToView:textField];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    
}

#pragma mark - ()

- (void)loadCameraRoll
{
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(104,104)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    ImageCollectionViewController *rootViewController = [[ImageCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[ImageCustomNavigationBar class]
                                                                                          toolbarClass:nil];
    [navController setViewControllers:@[rootViewController] animated:NO];
    
    [self presentViewController:navController animated:YES completion:NULL];
    
    rootViewController.onCompletion = ^(id result){
        [navController dismissViewControllerAnimated:YES completion:NULL];
        NSLog(@"Image selected result: %@ ", result);
    };
}

- (void)hideKeyboard
{
    [self.firstnameTextField resignFirstResponder];
    [self.lastnameTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.aboutTextView resignFirstResponder];
    [self.signUpView.passwordField resignFirstResponder];
    [self.signUpView.emailField resignFirstResponder];
    [self.signUpView.usernameField resignFirstResponder];
    [self.signUpView scrollToY:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (float)getCenterX:(float)elementWith
{
    return (self.view.frame.size.width)/2.0f - elementWith/2.0f;
}

- (void)firstnameTextFieldDidChange
{
    self.firstname = firstnameTextField.text;
}

- (void)lastnameTextFieldDidChange
{
    self.lastname = lastnameTextField.text;
}

- (void)confirmTextFieldDidFinish
{
    if([self.signUpView.passwordField.text isEqual:self.confirmPasswordTextField.text]){
        [self setIsPasswordConfirmed:YES];
    } else {
        [self setIsPasswordConfirmed:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
