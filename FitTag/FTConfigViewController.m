//
//  FitTagLoginViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTConfigViewController.h"
#import "FTLoginViewController.h"
#import "FTSignupViewController.h"
#import "FTInterestsViewController.h"
#import "FTInterestViewFlowLayout.h"
#import "FTToolBar.h"
#import "FTFeedViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "FTMapViewController.h"
#import "AppDelegate.h"
#import "FTLoginViewController.h"
#import "FTSignupViewController.h"

#define OVERLAY_HEGIHT 212
#define OVERLAY_WIDTH 320

#define LOGO_WIDTH 320
#define LOGO_HEIGHT 102

#define FACEBOOK_WIDTH 295
#define FACEBOOK_HEIGHT 57

#define OVERLAY_PADDING 10

#define SIGNUP_WIDTH 142
#define SIGNUP_HEIGHT 57

#define LOGIN_WIDTH 142
#define LOGIN_HEIGHT 57

#define LOGIN_SIGNUP_PADDING 11

@interface FTConfigViewController () {
    FTLoginViewController *loginViewController;
    FTSignupViewController *signUpViewController;
}
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UIButton *signupButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *logoView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation FTConfigViewController
@synthesize facebookButton;
@synthesize twitterButton;
@synthesize signupButton;
@synthesize loginButton;
@synthesize overlayView;
@synthesize logoView;
@synthesize tapGesture;

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"%@::viewWillAppear:",VIEWCONTROLLER_CONFIG);
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        //[(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    
    // Present FitTag UI
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:FT_RED];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLogoAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    
    CGSize viewSize = self.view.frame.size;
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:LOGIN_IMAGE_LOGO];
    [logoImageView setFrame:CGRectMake(0, 0, 320, 79)];
    
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 320, 79)];
    [logoView setBackgroundColor:[UIColor clearColor]];
    [logoView setUserInteractionEnabled:YES];
    [logoView addGestureRecognizer:tapGesture];
    [logoView addSubview:logoImageView];
    [self.view addSubview:logoView];
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, viewSize.height - OVERLAY_HEGIHT, viewSize.width, OVERLAY_HEGIHT)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [overlayView setUserInteractionEnabled:YES];
    [overlayView addGestureRecognizer:tapGesture];
    [overlayView setBackgroundColor:[UIColor colorWithPatternImage:LOGIN_IMAGE_OVERLAY]];
    [self.view addSubview:overlayView];
    
    // Customize the Log In View Controller
    loginViewController = [[FTLoginViewController alloc] init];
    loginViewController.delegate = self;
    loginViewController.facebookPermissions = @[@"email",@"public_profile",@"user_friends"];
    loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton;
    
    // Customize the Sign Up View Controller
    signUpViewController = [[FTSignupViewController alloc] init];
    signUpViewController.delegate = self;
    signUpViewController.fields = PFSignUpFieldsDefault;
    loginViewController.signUpController = signUpViewController;
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@::viewDidAppear:",VIEWCONTROLLER_CONFIG);
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_CONFIG];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    CGSize viewSize = self.view.frame.size;
    
    CGRect facebookRect = CGRectMake((viewSize.width - FACEBOOK_WIDTH)/2, OVERLAY_PADDING, FACEBOOK_WIDTH, FACEBOOK_HEIGHT);
    
    facebookButton = loginViewController.logInView.facebookButton;
    [facebookButton addTarget:self action:@selector(didTapFacebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [facebookButton setFrame:facebookRect];
    [facebookButton setImage:nil forState:UIControlStateNormal];
    [facebookButton setImage:nil forState:UIControlStateHighlighted];
    [facebookButton setBackgroundImage:LOGIN_IMAGE_FACEBOOK forState:UIControlStateNormal];
    [facebookButton setBackgroundImage:LOGIN_IMAGE_FACEBOOK forState:UIControlStateSelected];
    [facebookButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [facebookButton setTitle:EMPTY_STRING forState:UIControlStateSelected];
    [facebookButton addTarget:self action:@selector(didTapFacebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:facebookButton];
    
    CGRect twitterRect = facebookRect;
    twitterRect.origin.y += OVERLAY_PADDING + facebookRect.size.height;
    
    twitterButton = loginViewController.logInView.twitterButton;
    [twitterButton addTarget:self action:@selector(didTapTwitterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [twitterButton setFrame:twitterRect];
    [twitterButton setImage:nil forState:UIControlStateNormal];
    [twitterButton setImage:nil forState:UIControlStateHighlighted];
    [twitterButton setBackgroundImage:LOGIN_IMAGE_TWITTER forState:UIControlStateNormal];
    [twitterButton setBackgroundImage:LOGIN_IMAGE_TWITTER forState:UIControlStateSelected];
    [twitterButton setTitle:EMPTY_STRING forState:UIControlStateNormal];
    [twitterButton setTitle:EMPTY_STRING forState:UIControlStateSelected];
    
    [twitterButton setBackgroundImage:LOGIN_IMAGE_TWITTER forState:UIControlStateNormal];
    [twitterButton addTarget:self action:@selector(didTapTwitterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:twitterButton];
    
    CGRect signupRect = CGRectMake(twitterRect.origin.x, twitterRect.origin.y, SIGNUP_WIDTH, SIGNUP_HEIGHT);
    signupRect.origin.y += OVERLAY_PADDING + twitterRect.size.height;
    
    signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupButton setFrame:signupRect];
    [signupButton setImage:LOGIN_IMAGE_SIGNUP forState:UIControlStateNormal];
    [signupButton addTarget:self action:@selector(didTapSignupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:signupButton];
    
    CGRect loginRect = signupRect;
    loginRect.origin.x += loginRect.size.width + LOGIN_SIGNUP_PADDING;
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:loginRect];
    [loginButton setImage:LOGIN_IMAGE_LOGIN forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(didTapLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:loginButton];
}

#pragma mark - ()

- (void)didTapFacebookButtonAction:(UIButton *)button {
    [self presentViewController:loginViewController animated:YES completion:NULL];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeFacebook
                                                           value:nil] build]];
}

- (void)didTapTwitterButtonAction:(UIButton *)button {
    [self presentViewController:loginViewController animated:YES completion:NULL];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeTwitter
                                                           value:nil] build]];
}

- (void)didTapSignupButtonAction:(UIButton *)button {
    [self presentViewController:signUpViewController animated:YES completion:NULL];
}

- (void)didTapLoginButtonAction:(UIButton *)button {
    [self presentViewController:loginViewController animated:YES completion:NULL];
}

- (void)didTapLogoAction:(id)sender {
    [FTUtility showHudMessage:@"boop" WithDuration:1];
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject
                                       error:(NSError *)error {
    if (!error) {
        //NSLog(@"refreshObject: %@",refreshedObject);
    }
}

- (void)presentTabBarController:(PFUser *)user {
    if (!user) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
        return;
    }    
    [[UIApplication sharedApplication].delegate performSelector:@selector(presentTabBarController)];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - PFLogInViewControllerDelegate

- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user {
    //NSLog(@"%@::logInViewController:didLogInUser:",VIEWCONTROLLER_CONFIG);
    if ([PFUser currentUser] && user) {
        [self presentTabBarController:user];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                              action:kFTTrackEventActionTypeUserLogIn
                                                               label:kFTTrackEventLabelTypeSuccess
                                                               value:nil] build]];
    }
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)    logInViewController:(PFLogInViewController *)logInController
   shouldBeginLogInWithUsername:(NSString *)username
                       password:(NSString *)password {
    
    username = [username lowercaseString];
        
    //NSLog(@"logInViewController shouldBeginLogInWithUsername");
    if (username && password && username.length && password.length) {
                
        // Return yes if no uppercase letters are found, no otherwise
        if ([username rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound)
        {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                                  action:kFTTrackEventActionTypeUserLogIn
                                                                   label:kFTTrackEventLabelTypeShould
                                                                   value:nil] build]];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil)
                                message:NSLocalizedString(@"Make sure you fill out all of the information!", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
    
    return NO;
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(NSError *)error {
    NSLog(@"%@::logInViewController:loInController:didFailToLogInWithError:",VIEWCONTROLLER_CONFIG);
    NSLog(@"Failed to log in%@%@",ERROR_MESSAGE,error);
        
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LogIn Error", nil)
                                message:NSLocalizedString(@"The operation couldn't be completed. Invalid username or password, please try again. If the problem continues contact support@fittag.com.", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeError
                                                          action:kFTTrackEventActionTypeUserLogIn
                                                           label:[NSString stringWithFormat:@"Error.code:%ld",(long)error.code]
                                                           value:nil] build]];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"%@::logInViewControllerDidCancelLogIn:",VIEWCONTROLLER_CONFIG);
    NSLog(@"User dismissed the logInViewController");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeUserLogIn
                                                           label:kFTTrackEventLabelTypeCancel
                                                           value:nil] build]];
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    //NSLog(@"%@::signUpViewController:shouldBeginSignUp:",VIEWCONTROLLER_CONFIG);
    
    if (signUpViewController) {
        
        BOOL informationComplete = YES;
        
        for (id key in info) {
            NSString *field = [info objectForKey:key];
            if (!field || field.length == 0) {
                informationComplete = NO;
                break;
            }
        }
        
        // Set the username to lowercase
        NSString *username = [info objectForKey:@"username"];
        [info setValue:[username lowercaseString] forKey:@"username"];
        
        // If user information is not complete email | username | password are missing
        if (!informationComplete) {
            [FTUtility showHudMessage:MESSAGE_TITTLE_MISSING_INFO WithDuration:3];
            return NO;
        }
        
        if ([[info objectForKey:@"username"] rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound)
        {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                                  action:kFTTrackEventActionTypeUserSignUp
                                                                   label:kFTTrackEventLabelTypeBegin
                                                                   value:nil] build]];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController
               didSignUpUser:(PFUser *)user {
    NSLog(@"%@::signUpViewController:didSignUpUser:",VIEWCONTROLLER_CONFIG);
    if (user){
        NSLog(USER_DID_LOGIN);
        
        if (signUpViewController) {
            
            // User signedup event
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                                  action:kFTTrackEventActionTypeUserSignUp
                                                                   label:kFTTrackEventLabelTypeSuccess
                                                                   value:nil] build]];
            
            /*
            if (signUpViewController.firstname) {
                NSLog(@"signUpViewController.firstname");
                [user setValue:signUpViewController.firstname forKey:kFTUserFirstnameKey];
            }
            
            if (signUpViewController.lastname) {
                NSLog(@"signUpViewController.lastname");
                [user setValue:signUpViewController.lastname forKey:kFTUserLastnameKey];
            }
            
            if (signUpViewController.firstname && signUpViewController.lastname) {
                NSLog(@"signUpViewController.firstname && signUpViewController.lastname");
                [user setValue:[NSString stringWithFormat:@"@%@%@",signUpViewController.firstname,signUpViewController.lastname]
                        forKey:kFTUserDisplayNameKey];
            }
            */
            
            [user setValue:DEFAULT_BIO_TEXT_A forKey:kFTUserBioKey];
            
            /*
            if (signUpViewController.about.length > 0){
                NSLog(@"signUpViewController.about.length");
                [user setValue:signUpViewController.about forKey:kFTUserBioKey];
            }
            */
            
            if (signUpViewController.profilePhoto) {
                NSLog(@"signUpViewController.profilePhoto");
                
                UIImage *signupProfilePhoto = signUpViewController.profilePhoto;
                UIImage *resizedImage = [signupProfilePhoto resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                                 bounds:CGSizeMake(640,640)
                                                                   interpolationQuality:kCGInterpolationHigh];
                
                UIImage *thumbImage = [signupProfilePhoto thumbnailImage:86.0f
                                                       transparentBorder:0.0f
                                                            cornerRadius:10.0f
                                                    interpolationQuality:kCGInterpolationDefault];
                
                NSData *imageData           = UIImageJPEGRepresentation(resizedImage, 0.8f);
                NSData *thumbnailImageData  = UIImagePNGRepresentation(thumbImage);
                
                if (imageData && thumbnailImageData) {
                    PFFile *mediumPicFile = [PFFile fileWithData:imageData];
                    [user setObject:mediumPicFile forKey:kFTUserProfilePicMediumKey];
                    
                    PFFile *smallPicFile = [PFFile fileWithData:thumbnailImageData];
                    [user setObject:smallPicFile forKey:kFTUserProfilePicSmallKey];
                }
            }
            
            [user setValue:kFTUserTypeUser forKey:kFTUserTypeKey];
            [user setValue:[user username] forKey:kFTUserDisplayNameKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    //[user saveEventually];
                    NSLog(@"%@%@",ERROR_MESSAGE,error);
                }
            }];
            
            if (signUpViewController) {
                [signUpViewController dismissViewControllerAnimated:YES completion:nil];
                [self presentTabBarController:user];
            }
        }
        
    } else {
        NSLog(USER_NOT_LOGGEDIN);
    }
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController
    didFailToSignUpWithError:(NSError *)error {
    
    NSLog(@"%@::signUpViewController:didFailToSignUpWithError:",VIEWCONTROLLER_CONFIG);
    NSLog(@"%@%@",ERROR_MESSAGE,error);
    
    NSNumber *value = [[NSNumber alloc] initWithInteger:error.code];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeError
                                                          action:kFTTrackEventActionTypeUserSignUp
                                                           label:@"signUpViewController:didFailToSignUpWithError:"
                                                           value:value] build]];
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"%@::signUpViewControllerDidCancelSignUp:",VIEWCONTROLLER_CONFIG);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kFTTrackEventCatagoryTypeInterface
                                                          action:kFTTrackEventActionTypeButtonPress
                                                           label:kFTTrackEventLabelTypeCancel
                                                           value:nil] build]];
}

@end
