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
    NSLog(@"%@::viewDidAppear:",VIEWCONTROLLER_CONFIG);
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
    NSLog(@"%@::logInViewController:didLogInUser:",VIEWCONTROLLER_CONFIG);
    if ([PFUser currentUser] && user) {
        [self presentTabBarController:user];
    }
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password {
    
    NSLog(@"logInViewController shouldBeginLogInWithUsername");
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
    
    if (signUpViewController) {
        
        BOOL informationComplete = YES;
        
        /*
        NSString *firstname = EMPTY_STRING;
        NSString *lastname = EMPTY_STRING;
        BOOL isPasswordConfirmed = NO;
        
        if (signUpViewController.firstname) {
            NSLog(@"firstname is valid signUpViewController.firstname");
            firstname = signUpViewController.firstname;
        }
        
        if (signUpViewController.lastname) {
            NSLog(@"lastname is valid signUpViewController.lastname");
            lastname = signUpViewController.lastname;
        }
        
        if (signUpViewController.isPasswordConfirmed) {
            NSLog(@"isPasswordConfirmed is valid signUpViewController.isPasswordConfirmed");
            isPasswordConfirmed = signUpViewController.isPasswordConfirmed;
        }
        */
        
        for (id key in info) {
            NSString *field = [info objectForKey:key];
            if (!field || field.length == 0) {
                informationComplete = NO;
                break;
            }
        }
        
        // If user information is not complete email | username | password are missing
        if (!informationComplete) {
            NSLog(@"user information is not complete");
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(MESSAGE_TITTLE_MISSING_INFO, nil)
                                        message:NSLocalizedString(MESSAGE_MISSING_INFORMATION, nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            
            return NO;
        }
        
        /*
        // If password confirm does not match
        if (!isPasswordConfirmed) {
            NSLog(@"If password confirm does not match");
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(MESSAGE_TITTLE_MISSING_INFO, nil)
                                        message:NSLocalizedString(MESSAGE_CONFIRMED_MATCH, nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            
            return NO;
        }
        
        // If firstname or lastname are empty
        if (lastname.length <= 0 && firstname.length <= 0) {
            NSLog(@"If firstname or lastname are empty");
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(MESSAGE_TITTLE_MISSING_INFO, nil)
                                        message:NSLocalizedString(MESSAGE_NAME_EMPTY, nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            return NO;
        }
        */
        
        return YES;
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
                                                                                 bounds:CGSizeMake(560.0f, 560.0f)
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
            
            NSLog(@"user:%@",user);
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
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"%@::signUpViewController:didFailToSignUpWithError:",VIEWCONTROLLER_CONFIG);
    NSLog(@"%@%@",ERROR_MESSAGE,error);
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"%@::signUpViewControllerDidCancelSignUp:",VIEWCONTROLLER_CONFIG);
}

@end
