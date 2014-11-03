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


@interface FTConfigViewController () {
    FTLoginViewController *loginViewController;
    FTSignupViewController *signUpViewController;
}
@end

@implementation FTConfigViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"%@::viewWillAppear:",VIEWCONTROLLER_CONFIG);
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    
    // Present FitTag UI
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"%@::viewDidAppear:",VIEWCONTROLLER_CONFIG);
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_CONFIG];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (![PFUser currentUser]) {
        // Customize the Log In View Controller
        loginViewController = [[FTLoginViewController alloc] init];
        loginViewController.delegate = self;
        loginViewController.facebookPermissions = @[@"email",@"public_profile",@"user_friends"];
        loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton;
        
        // Customize the Sign Up View Controller
        signUpViewController = [[FTSignupViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault;
        loginViewController.signUpController = signUpViewController;        
        
        [self presentViewController:loginViewController animated:NO completion:NULL];
    }
}

#pragma mark - ()

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
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

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    //NSLog(@"%@::logInViewController:didLogInUser:",VIEWCONTROLLER_CONFIG);
    [self presentTabBarController:user];
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password {
    
    //NSLog(@"logInViewController shouldBeginLogInWithUsername");
    if (username && password && username.length && password.length) {
        return YES;
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
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Credentials", nil)
                                message:NSLocalizedString(@"The operation couldn't be completed. Invalid username or password, please try again.", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"%@::logInViewControllerDidCancelLogIn:",VIEWCONTROLLER_CONFIG);
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSLog(@"%@::signUpViewController:shouldBeginSignUp:",VIEWCONTROLLER_CONFIG);
    
    NSString *firstname = signUpViewController.firstname;
    NSString *lastname = signUpViewController.lastname;
    BOOL isPasswordConfirmed = signUpViewController.isPasswordConfirmed;
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete || !isPasswordConfirmed || [lastname isEqualToString:EMPTY_STRING] || [firstname isEqualToString:EMPTY_STRING]) {
        NSLog(@"Missing Information");
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil)
                                        message:NSLocalizedString(STRING_MISSING_INFORMATION, nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
        return NO;
    }
    
    return YES;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //NSLog(@"%@::signUpViewController:didSignUpUser:",VIEWCONTROLLER_CONFIG);
    if (user){
        NSLog(USER_DID_LOGIN);
        [user setValue:signUpViewController.firstname forKey:kFTUserFirstnameKey];
        [user setValue:signUpViewController.lastname forKey:kFTUserLastnameKey];
        [user setValue:[NSString stringWithFormat:@"@%@%@",signUpViewController.firstname,signUpViewController.lastname] forKey:kFTUserDisplayNameKey];
        
        if (![signUpViewController.about isEqualToString:EMPTY_STRING]){
            [user setValue:signUpViewController.about forKey:kFTUserBioKey];
        } else {
            [user setValue:DEFAULT_BIO_TEXT_A forKey:kFTUserBioKey];
        }
        
        if (signUpViewController.profilePhoto) {
            UIImage *resizedImage = [signUpViewController.profilePhoto resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                                            bounds:CGSizeMake(560.0f, 560.0f)
                                                                              interpolationQuality:kCGInterpolationHigh];
            
            UIImage *thumbImage = [signUpViewController.profilePhoto thumbnailImage:86.0f
                                                                  transparentBorder:0.0f
                                                                       cornerRadius:10.0f
                                                               interpolationQuality:kCGInterpolationDefault];
            
            NSData *imageData           = UIImageJPEGRepresentation(resizedImage, 0.8f);
            NSData *thumbnailImageData  = UIImagePNGRepresentation(thumbImage);
            
            if (imageData && thumbnailImageData) {
                [user setValue:[PFFile fileWithName:FILE_MEDIUM_JPEG data:imageData] forKey:kFTUserProfilePicMediumKey];
                [user setValue:[PFFile fileWithName:FILE_SMALL_JPEG data:imageData] forKey:kFTUserProfilePicSmallKey];
            }
        }
        
        [user setValue:kFTUserTypeUser forKey:kFTUserTypeKey];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [user saveEventually];
                NSLog(@"%@%@",ERROR_MESSAGE,error);
            }
        }];
        
        if (signUpViewController) {
            [signUpViewController dismissViewControllerAnimated:YES completion:nil];
            [self presentTabBarController:user];
        }
    } else {
        NSLog(USER_NOT_LOGGEDIN);
    }
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"%@::signUpViewController:didFailToSignUpWithError:",VIEWCONTROLLER_CONFIG);
    NSLog(@"%@%@",ERROR_MESSAGE,error);
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"%@::signUpViewControllerDidCancelSignUp:",VIEWCONTROLLER_CONFIG);
}

@end
