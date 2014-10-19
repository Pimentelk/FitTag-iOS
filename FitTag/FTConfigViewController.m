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
    CLLocationManager *locationManager;
}
@end

@implementation FTConfigViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSLog(@"%@::viewWillAppear:",VIEWCONTROLLER_CONFIG);
    
    // If not logged in, present login view controller
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
    
    if (![PFUser currentUser]) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    // Present FitTag UI
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentTabBarController];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@::viewDidAppear:",VIEWCONTROLLER_CONFIG);
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

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    
}

#pragma mark - DidLoginWithSocialMedia

- (BOOL)isLoggedInWithTwitter {
    NSLog(@"%@::isLoggedInWithTwitter:",VIEWCONTROLLER_CONFIG);
    return [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
}

- (BOOL)isLoggedInWithFacebook {
    NSLog(@"%@::isLoggedInWithFacebook:",VIEWCONTROLLER_CONFIG);
    return [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
}

- (BOOL)didLogInWithTwitter:(PFObject *)user {
    NSLog(@"%@::didLogInWithTwitter:",VIEWCONTROLLER_CONFIG);
    
    if ([self isLoggedInWithTwitter]) {
        
        NSLog(USER_DID_LOGIN_TWITTER);
        
        NSString * requestString = [NSString stringWithFormat:TWITTER_API_USERS,[PFTwitterUtils twitter].screenName];
        NSURL *verify = [NSURL URLWithString:requestString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
        [[PFTwitterUtils twitter] signRequest:request];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error == nil){
            NSDictionary* TWuser = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSString *profile_image_normal = [TWuser objectForKey:TWITTER_PROFILE_HTTPS];
            NSString *profile_image = [profile_image_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            NSData *profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_image]];
            
            NSString *names = [TWuser objectForKey:@"name"];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
            
            if ( array.count > 1){
                [user setObject:[array lastObject] forKey:kFTUserLastnameKey];
                [array removeLastObject];
                [user setObject:[array componentsJoinedByString:@" "] forKey:kFTUserFirstnameKey];
            }
            
            [user setValue:[TWuser objectForKey:@"name"]
                    forKey:kFTUserDisplayNameKey];
            
            [user setValue:[NSString stringWithFormat:@"%@",[TWuser objectForKey:@"id"]]
                    forKey:kFTUserTwitterIDKey];
            
            [user setValue:DEFAULT_BIO_TEXT_B
                    forKey:kFTUserBioKey];
            
            [user setValue:[PFFile fileWithName:MEDIUM_JPEG data:profileImageData]
                    forKey:kFTUserProfilePicMediumKey];
            
            [user setValue:[PFFile fileWithName:SMALL_JPEG data:profileImageData]
                    forKey:kFTUserProfilePicSmallKey];
            
            
            //user[@"displayName"]            = TWuser[@"name"];
            //user[@"twitterId"]              = [NSString stringWithFormat:@"%@",TWuser[@"id"]];
            //user[@"bio"]                    = @"WHAT MAKES YOU, YOU? (OPTIONAL)";
            //user[@"profilePictureMedium"]   = [PFFile fileWithName:@"medium.jpeg" data:profileImageData];
            //user[@"profilePictureSmall"]    = [PFFile fileWithName:@"small.png" data:profileImageData];
            //user[@"lastLogin"]              = [NSDate date];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@%@",ERROR_MESSAGE,error);
                    [user saveEventually];
                }
            }];
        }
        return YES;
    }

    NSLog(USER_NOT_LOGIN_TWITTER);
    return NO;
}

- (BOOL)didLogInWithFacebook:(PFObject *)user {
    NSLog(@"%@::didLogInWithFacebook:",VIEWCONTROLLER_CONFIG);

    if ([self isLoggedInWithFacebook]) {
        NSLog(USER_DID_LOGIN_FACEBOOK);
        
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
            if (!error) {
                NSData* profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:FACEBOOK_GRAPH_PICTURES_URL,[FBuser objectForKey:FBUserIDKey]]]];
                
                // Get the data from facebook and put it into the user object
                [user setValue:[FBuser objectForKey:FBUserFirstNameKey] forKey:kFTUserFirstnameKey];
                [user setValue:[FBuser objectForKey:FBUserLastNameKey] forKey:kFTUserLastnameKey];
                [user setValue:[FBuser objectForKey:FBUserNameKey] forKey:kFTUserDisplayNameKey];
                [user setValue:[FBuser objectForKey:FBUserEmailKey] forKey:kFTUserEmailKey];
                [user setValue:[FBuser objectForKey:FBUserIDKey] forKey:kFTUserFacebookIDKey];
                [user setValue:DEFAULT_BIO_TEXT_B forKey:kFTUserBioKey];
                [user setValue:[PFFile fileWithName:MEDIUM_JPEG data:profileImageData] forKey:kFTUserProfilePicMediumKey];
                [user setValue:[PFFile fileWithName:SMALL_JPEG data:profileImageData] forKey:kFTUserProfilePicSmallKey];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [user saveEventually];
                        NSLog(@"%@ %@", ERROR_MESSAGE, error);
                    }
                }];
                
            } else {
                NSLog(@"Facebook%@%@",ERROR_MESSAGE,error);
            }
        }];
        return YES;
    }
    
    NSLog(@"%@ %@",ERROR_MESSAGE,USER_NOT_LOGIN_FACEBOOK);
    return NO;
}

- (void)presentTabBarController:(PFUser *)user {
    
    if (!user) {
        [NSException raise:NSInvalidArgumentException format:IF_USER_NOT_SET_MESSAGE];
        return;
    }
    
    // save the total number of rewards the user has earned
    PFQuery *queryPosts = [PFQuery queryWithClassName:kFTPostClassKey];
    [queryPosts whereKey:kFTPostUserKey equalTo:user];
    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSNumber *count = [NSNumber numberWithUnsignedInteger:objects.count];
            NSNumber *rewardCount = [NSNumber numberWithUnsignedInteger:(objects.count / 10)];
            [user setObject:count forKey:kFTUserPostCountKey];
            [user setObject:rewardCount forKey:kFTUserRewardsEarnedKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@ %@",ERROR_MESSAGE,error);
                    [user saveEventually];
                }
            }];
        }
    }];
    
    [[UIApplication sharedApplication].delegate performSelector:@selector(presentTabBarController)];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"%@::logInViewController:didLogInUser:",VIEWCONTROLLER_CONFIG);
    [self didLogInWithFacebook:user];
    [self didLogInWithTwitter:user];
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
    
    if (!informationComplete || !isPasswordConfirmed || [lastname isEqualToString:@""] || [firstname isEqualToString:@""]) {
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
    NSLog(@"%@::signUpViewController:didSignUpUser:",VIEWCONTROLLER_CONFIG);
    
    if (user){
        NSLog(USER_DID_LOGIN);
        [user setValue:signUpViewController.firstname forKey:kFTUserFirstnameKey];
        [user setValue:signUpViewController.lastname forKey:kFTUserLastnameKey];
        [user setValue:[NSString stringWithFormat:@"@%@%@",signUpViewController.firstname,signUpViewController.lastname] forKey:kFTUserDisplayNameKey];
        
        if (![signUpViewController.about isEqualToString:@""]){
            [user setValue:signUpViewController.about forKey:kFTUserBioKey];
        } else {
            [user setValue:DEFAULT_BIO_TEXT_A forKey:kFTUserBioKey];
        }
        
        UIImage *resizedImage = [signUpViewController.coverPhoto resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                                      bounds:CGSizeMake(560.0f, 560.0f)
                                                                        interpolationQuality:kCGInterpolationHigh];
        
        UIImage *thumbImage = [signUpViewController.coverPhoto thumbnailImage:86.0f
                                                            transparentBorder:0.0f
                                                                 cornerRadius:10.0f
                                                         interpolationQuality:kCGInterpolationDefault];
        
        NSData *imageData           = UIImageJPEGRepresentation(resizedImage, 0.8f);
        NSData *thumbnailImageData  = UIImagePNGRepresentation(thumbImage);
        
        if (imageData && thumbnailImageData) {
            [user setValue:[PFFile fileWithName:MEDIUM_JPEG data:imageData] forKey:kFTUserProfilePicMediumKey];
            [user setValue:[PFFile fileWithName:SMALL_JPEG data:imageData] forKey:kFTUserProfilePicSmallKey];
        }
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [user saveEventually];
                NSLog(@"%@%@",ERROR_MESSAGE,error);
            }
        }];
        
        if (signUpViewController) {
            [signUpViewController dismissViewControllerAnimated:signUpViewController completion:nil];
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
