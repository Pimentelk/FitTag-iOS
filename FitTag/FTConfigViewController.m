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
#import "InterestCollectionViewFlowLayout.h"
#import "FeedCollectionViewFlowLayout.h"
#import "FTFeedViewController.h"
#import "FTToolBar.h"
#import "FTNavigationBar.h"
#import "FTHomeViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTConfigViewController ()
{
    FTLoginViewController *logInViewController;
    FTSignupViewController *signUpViewController;
}
@end

@implementation FTConfigViewController
@synthesize firstLaunch;

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[PFUser logOut]; // For testing log out user.
    PFUser *user = [PFUser currentUser];
    BOOL isLinkedToTwitter = [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
    BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
    BOOL isFirstUserLogin = YES;
    
    if ([user objectForKey:@"lastLogin"]) {
        isFirstUserLogin = NO;
    }
    
    if(user){ // Is the user logged in
        
        if(isFirstUserLogin){ // Is this his first launch
            
            if(isLinkedToFacebook){ // Is the user logged in via facebook
                
                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
                    
                    if (!error) {
                        
                        NSData* profileImageData = [NSData dataWithContentsOfURL:
                                                    [NSURL URLWithString:
                                                     [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&width=600&height=600",FBuser[@"id"]]]];
                        
                        // Get the data from facebook and put it into the user object
                        user[@"firstname"]              = FBuser[@"first_name"];
                        user[@"lastname"]               = FBuser[@"last_name"];
                        user[@"displayName"]            = FBuser[@"name"];
                        user[@"email"]                  = FBuser[@"email"];
                        user[@"facebookId"]             = FBuser[@"id"];
                        user[@"bio"]                    = @"WHAT MAKES YOU, YOU? (OPTIONAL)";
                        user[@"profilePictureMedium"]   = [PFFile fileWithName:@"medium.jpeg" data:profileImageData];
                        user[@"profilePictureSmall"]    = [PFFile fileWithName:@"small.png" data:profileImageData];
                        user[@"lastLogin"]              = [NSDate date];
                        
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (error) {
                                [user saveEventually];
                                NSLog(@"error... %@", error);
                            }
                        }];
                        
                    } else {
                        
                        NSLog(@"Facebook Error: %@",error);
                    }
                }];
                
            }
            
            if(isLinkedToTwitter){ // Is the user logged via twitter
                NSLog(@"isLinkedToTwitter");
                
                NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", [PFTwitterUtils twitter].screenName];
                NSURL *verify = [NSURL URLWithString:requestString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
                [[PFTwitterUtils twitter] signRequest:request];
                NSURLResponse *response = nil;
                NSError *error = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                if (error == nil){
                    NSDictionary* TWuser = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    NSString *profile_image_normal = TWuser[@"profile_image_url_https"];
                    NSString *profile_image = [profile_image_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                    NSData *profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_image]];
                    
                    NSString *names = [TWuser objectForKey:@"name"];
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
                    
                    if ( array.count > 1){
                        [user setObject:[array lastObject] forKey:@"lastname"];
                        [array removeLastObject];
                        [user setObject:[array componentsJoinedByString:@" "] forKey:@"firstname"];
                    }
                    
                    user[@"displayName"]            = TWuser[@"name"];
                    user[@"twitterId"]              = [NSString stringWithFormat:@"%@",TWuser[@"id"]];
                    user[@"bio"]                    = @"WHAT MAKES YOU, YOU? (OPTIONAL)";
                    user[@"profilePictureMedium"]   = [PFFile fileWithName:@"medium.jpeg" data:profileImageData];
                    user[@"profilePictureSmall"]    = [PFFile fileWithName:@"small.png" data:profileImageData];
                    user[@"lastLogin"]              = [NSDate date];

                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            [user saveEventually];
                            NSLog(@"error... %@", error);
                        }
                    }];
                }
            }
            
            InterestCollectionViewFlowLayout *layoutFlow = [[InterestCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(159.5,42)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            FTInterestsViewController *rootViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:layoutFlow];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        } else { // This is not the users first login
            
            FeedCollectionViewFlowLayout *layoutFlow = [[FeedCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(320,320)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            FTHomeViewController *rootViewController = [[FTHomeViewController alloc] initWithClassName:kFTPhotoClassKey];
            UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[FTNavigationBar class] toolbarClass:[FTToolBar class]];
            [navController setViewControllers:@[rootViewController] animated:NO];
            
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        }
        
    } else {
        
        // Customize the Log In View Controller
        logInViewController = [[FTLoginViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"email",@"public_profile",@"user_friends"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton;
        
        // Customize the Sign Up View Controller
        signUpViewController = [[FTSignupViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault;
        logInViewController.signUpController = signUpViewController;
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //NSLog(@"viewDidAppear");
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
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

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    //NSLog(@"logInViewController didLogInUser");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    //NSLog(@"FTConfigViewController::logInViewController error: %@",error);
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    //NSLog(@"logInViewControllerDidCancelLogIn logInController");
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    //NSLog(@"signUpViewController ShouldBeginSignUp...My dictionary: %@ ", info);
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
    
    // Make sure first and last name have been defined
    if([firstname isEqual:nil] || [(NSNull *)firstname isEqual: [NSNull null]] || [lastname isEqual: nil] || [(NSNull *)lastname isEqual: [NSNull null]] || !isPasswordConfirmed){
        informationComplete = NO;
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all required information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //NSLog(@"signUpViewController didSignUpUser...user: %@ ", user);
    
    if(user && [PFUser currentUser]){
        
        user[@"firstname"]      = signUpViewController.firstname;
        user[@"lastname"]       = signUpViewController.lastname;
        user[@"lastLogin"]      = [NSDate date];
        user[@"displayName"]    = [NSString stringWithFormat:@"%@ %@",signUpViewController.firstname,signUpViewController.lastname];
        
        if(![signUpViewController.about isEqual:nil] && ![signUpViewController.about isEqual: @""]){
            user[@"bio"] = signUpViewController.about;
        } else {
            user[@"bio"] = @"Tell us about yourself(Optional)";
        }
        
        UIImage *resizedImage = [signUpViewController.coverPhoto resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                                      bounds:CGSizeMake(560.0f, 560.0f)
                                                                        interpolationQuality:kCGInterpolationHigh];
        
        UIImage *thumbImage = [signUpViewController.coverPhoto thumbnailImage:86.0f
                                                            transparentBorder:0.0f
                                                                 cornerRadius:10.0f
                                                         interpolationQuality:kCGInterpolationDefault];
        
        // JPEG to decrease file size and enable faster uploads & downloads
        NSData *imageData           = UIImageJPEGRepresentation(resizedImage, 0.8f);
        NSData *thumbnailImageData  = UIImagePNGRepresentation(thumbImage);
        
        if (imageData || thumbnailImageData) {
            user[@"profilePictureMedium"]   = [PFFile fileWithName:@"medium.jpeg" data:imageData];
            user[@"profilePictureSmall"]    = [PFFile fileWithName:@"small.png" data:imageData];
        }
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [user saveEventually];
                NSLog(@"error... %@", error);
            }
        }];

    } else {
        NSLog(@"User is NOT logged in.");
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end
