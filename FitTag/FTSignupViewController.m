//
//  FitTagSignupViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FTSignupViewController.h"
#import "FTCamViewController.h"
#import "UIView+FormScroll.h"
#import "FTCamRollViewController.h"
#import "ImageCustomNavigationBar.h"
#import "FTNavigationBar.h"

@interface FTSignupViewController ()
@property (nonatomic,strong) UIImageView *separators;
@property (nonatomic,strong) UILabel *defaultLabel;
@property (nonatomic,strong) UITextField *firstnameTextField;
@property (nonatomic,strong) UITextField *lastnameTextField;
@property (nonatomic,strong) UITextView *aboutTextView;
@property (nonatomic,strong) UIImageView *signupWithText;
@property (nonatomic,strong) UIButton *profileImageButton;
@property (nonatomic,strong) UIButton *facebookButton;
@property (nonatomic,strong) UIButton *twitterButton;
@property (nonatomic,strong) UITextField *confirmPasswordTextField;
@property (nonatomic,strong) UIImageView *termsText;
@property (nonatomic,strong) UITextField *activeField;
@property (nonatomic,strong) UILabel *aLabel;
@end

@implementation FTSignupViewController

@synthesize separators;
@synthesize defaultLabel;
@synthesize firstnameTextField;
@synthesize lastnameTextField;
@synthesize aboutTextView;
@synthesize signupWithText;
@synthesize profileImageButton;
@synthesize confirmPasswordTextField;
@synthesize termsText;
@synthesize aLabel;
@synthesize facebookButton;
@synthesize twitterButton;

#pragma mark - UIViewController

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
    
    UIColor *attrColor = [UIColor grayColor];
    
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
    [self.profileImageButton addTarget:self action:@selector(loadCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    
    // Or signup with
    aLabel = [[UILabel alloc]init];
    aLabel.numberOfLines = 0;
    aLabel.font = [UIFont systemFontOfSize:7];
    aLabel.textColor = [UIColor blackColor];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.text = @"OR SIGNUP WITH:";
    [self.signUpView addSubview:aLabel];
    
    // Set profile photo
    facebookButton = [[UIButton alloc] init];
    [self.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_button"] forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(facebookLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpView addSubview:self.facebookButton];
    
    // Set profile photo
    twitterButton = [[UIButton alloc] init];
    [self.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_button"] forState:UIControlStateNormal];
    [self.twitterButton addTarget:self action:@selector(twitterLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpView addSubview:self.twitterButton];
    
    // Set signup red button
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_button"] forState: UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];

    // Implement firstname textfield
    firstnameTextField = [[UITextField alloc] init];
    [self.firstnameTextField setPlaceholder:@"FIRST NAME"];
    [self.firstnameTextField setDelegate:self];
    [self.signUpView addSubview:self.firstnameTextField];
    [self.firstnameTextField setTextAlignment:NSTextAlignmentLeft];
    [self.firstnameTextField addTarget: self action:@selector(firstnameTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.signUpView addGestureRecognizer:gestureRecognizer];
    
    // Implement lastname textfield
    lastnameTextField = [[UITextField alloc] init];
    [self.lastnameTextField setPlaceholder:@"LAST NAME"];
    [self.lastnameTextField setDelegate:self];
    [self.signUpView addSubview:self.lastnameTextField];
    [self.lastnameTextField setTextAlignment:NSTextAlignmentLeft];
    [lastnameTextField addTarget:self action:@selector(lastnameTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    // Implement confirm password textfield
    confirmPasswordTextField = [[UITextField alloc] init];
    [self.confirmPasswordTextField setPlaceholder:@"CONFIRM PASSWORD"];
    [self.confirmPasswordTextField setDelegate:self];
    [self.signUpView addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordTextField setTextAlignment:NSTextAlignmentLeft];
    [self.confirmPasswordTextField setSecureTextEntry:YES];
    [self.confirmPasswordTextField addTarget:self action:@selector(confirmTextFieldDidFinish) forControlEvents:UIControlEventEditingDidEnd];
    
    // Set password confirm
    [self setIsPasswordConfirmed:NO];
    
    // Implement about textview
    aboutTextView = [[UITextView alloc] init];
    [self.aboutTextView setDelegate:self];
    [self.aboutTextView setBackgroundColor:nil];
    defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    [self.defaultLabel setTextColor:attrColor];
    [self.defaultLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [self.defaultLabel setText: @"WHAT MAKES YOU, YOU? (OPTIONAL)"];
    [self.aboutTextView addSubview:self.defaultLabel];
    [self.signUpView addSubview:self.aboutTextView];
    
    // Align username, email, password text fields left
    [self.signUpView.usernameField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.usernameField setTextColor:attrColor];
    [self.signUpView.usernameField setPlaceholder:@"USERNAME"];
    [self.signUpView.usernameField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    
    [self.signUpView.emailField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.emailField setTextColor:attrColor];
    [self.signUpView.emailField setPlaceholder:@"EMAIL ADDRESS"];
    [self.signUpView.emailField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];

    [self.signUpView.passwordField setTextAlignment:NSTextAlignmentLeft];
    [self.signUpView.passwordField setTextColor:attrColor];
    [self.signUpView.passwordField setPlaceholder:@"PASSWORD"];
    [self.signUpView.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    
    // Setup terms text
    termsText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_screen_terms_text"]];
    [self.signUpView addSubview:self.termsText];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    float logoPositionY = 30.0f;
    
    [self.separators setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f)];
    [self.signUpView.logo setFrame:CGRectMake([self getCenterX:165.0f], logoPositionY, 165.0f, 35.0f)];
    [self.profileImageButton setFrame:CGRectMake(10.0f, 80.0f, 71.0f, 83.0f)];
    NSInteger centerLabelX = self.profileImageButton.frame.origin.x + self.profileImageButton.frame.size.width + 5.0f;
    NSInteger centerLabelY = (self.profileImageButton.frame.origin.y + (self.profileImageButton.frame.size.height / 2)) - 15;
    [self.aLabel setFrame: CGRectMake(centerLabelX, centerLabelY, 70, 30)];
    [self.facebookButton setFrame:CGRectMake(centerLabelX + self.aLabel.frame.size.width, 80.0f, 71.0f, 83.0f)];
    [self.twitterButton setFrame:CGRectMake(self.facebookButton.frame.origin.x + self.facebookButton.frame.size.width + 12.0f, 80.0f, 71.0f, 83.0f)];
    [self.signupWithText setFrame:CGRectMake(85.0f, 120.0f, 77.0f, 8.0f)];
    [self.firstnameTextField setFrame:CGRectMake(10.0f, 173.0f, 140.0f, 35.0f)];
    [self.lastnameTextField setFrame:CGRectMake(160.0f, 173.0f, 140.0f, 35.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(10.0f, 213.0f, 280.0f, 35.0f)];
    [self.signUpView.usernameField setFrame:CGRectMake(10.0f, 253.0f, 280.0f, 35.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(10.0f, 293.0f, 280.0f, 35.0f)];
    [self.confirmPasswordTextField setFrame:CGRectMake(10.0f, 333.0f, 280.0f, 35.0f)];
    [self.aboutTextView setFrame:CGRectMake(10.0f, 373.0f, 300.0f, 100.0f)];
    [self.termsText setFrame:CGRectMake([self getCenterX:240.0f], (self.view.frame.size.height - (87.0f)), 240.0f, 7.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake([self getCenterX:57.0f], (self.termsText.frame.size.height + self.termsText.frame.origin.y)+10, 57.0f, 65.0f)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.defaultLabel.hidden = YES;
    //[self.signUpView scrollToView:textView];
    [self.signUpView scrollElement:textView toPoint:160];
}

- (void)textViewDidChange:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
    self.about = aboutTextView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.defaultLabel.hidden = ([textView.text length] > 0);
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //[self.signUpView scrollToView:textField];
    [self.signUpView scrollElement:textField toPoint:160];
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    
}

#pragma mark - ()

- (void)facebookLogin:(id)sender{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //[[UIApplication sharedApplication].delegate performSelector:@selector(facebook)];
        if (!error) {
            //[self facebookRequestDidLoad:result];
            //[[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:)];
        } else {
            //[self facebookRequestDidFailWithError:error];
            //[[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:)];
        }
    }];
}

- (void)twitterLogin:(id)sender{
    
}

- (UIImageView *)setImage:(UIImage *)image{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(10.0f, 80.0f, 71.0f, 83.0f);
    imageView.backgroundColor = [UIColor clearColor];
    
    CGRect rect = imageView.frame;
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = imageView.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
    CGFloat lcolumn = rect.size.width - sideWidth;
    CGFloat height = rect.size.height;
    CGFloat ty = (rect.size.height - height) / 2;
    CGFloat tmy = rect.size.height / 4;
    CGFloat bmy = rect.size.height - tmy;
    CGFloat by = rect.size.height;
    CGFloat rightmost = rect.size.width;
    
    [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
    
    [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
    
    hexagonMask.path = hexagonPath.CGPath;
    
    imageView.layer.mask = hexagonMask;
    [imageView.layer addSublayer:hexagonBorder];
    [imageView setImage:image];
    
    return imageView;
}

- (void)loadCameraRoll:(id)sender{
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = (id)self;
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class] toolbarClass:NULL];
    [navController setViewControllers:@[camViewController] animated:NO];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)hideKeyboard:(id)sender{
    [self.firstnameTextField resignFirstResponder];
    [self.lastnameTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.aboutTextView resignFirstResponder];
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

- (void)firstnameTextFieldDidChange{
    self.firstname = firstnameTextField.text;
}

- (void)lastnameTextFieldDidChange{
    self.lastname = lastnameTextField.text;
}

- (void)confirmTextFieldDidFinish{
    if([self.signUpView.passwordField.text isEqual:self.confirmPasswordTextField.text]){
        [self setIsPasswordConfirmed:YES];
    } else {
        [self setIsPasswordConfirmed:NO];
    }
}

#pragma mark - FTEditPhotoViewController

- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption{
    self.coverPhoto = image;
    UIImageView *imageView = [self setImage:image];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadCameraRoll:)];
    [singleTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:singleTap];
    [imageView setFrame:CGRectMake(10.0f, 80.0f, 71.0f, 83.0f)];
    [self.profileImageButton removeFromSuperview];
    [self.signUpView addSubview:imageView];
}

@end
