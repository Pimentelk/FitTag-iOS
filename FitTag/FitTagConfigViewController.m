//
//  FitTagLoginViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FitTagConfigViewController.h"
#import "FitTagLoginViewController.h"
#import "FitTagSignupViewController.h"
#import "InterestsViewController.h"
#import "InterestCollectionViewFlowLayout.h"
#import "FeedCollectionViewFlowLayout.h"
#import "FeedViewController.h"
#import "FitTagToolBar.h"
#import "FitTagNavigationBar.h"

@interface FitTagConfigViewController ()
{
    FitTagLoginViewController *logInViewController;
    FitTagSignupViewController *signUpViewController;
}
@end

@implementation FitTagConfigViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSLog(@"FitTagConfigViewController::viewWillAppear");
    if ([PFUser currentUser]) {
        //self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[PFUser currentUser] username]];
    } else {
        //self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"FitTagConfigViewController::viewDidAppear");
    //[PFUser logOut]; // For testing log out user.
    // Check if user is logged in
    if (![PFUser currentUser]) {
        
        // Customize the Log In View Controller
        logInViewController = [[FitTagLoginViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"friends_about_me"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten;

        // Customize the Sign Up View Controller
        signUpViewController = [[FitTagSignupViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault;
        logInViewController.signUpController = signUpViewController;

        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];        
    } else {
        
        BOOL isFirstLogin = NO; // Check if user is first time logging in.
        
        if(isFirstLogin){ // Take user through the first time signin screens
            
            InterestCollectionViewFlowLayout *layoutFlow = [[InterestCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(159.5,42)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            InterestsViewController *rootViewController = [[InterestsViewController alloc] initWithCollectionViewLayout:layoutFlow];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        } else { // Take user to the main feed screen

            FeedCollectionViewFlowLayout *layoutFlow = [[FeedCollectionViewFlowLayout alloc] init];
            [layoutFlow setItemSize:CGSizeMake(320,320)];
            [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layoutFlow setMinimumInteritemSpacing:0];
            [layoutFlow setMinimumLineSpacing:0];
            [layoutFlow setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
            [layoutFlow setHeaderReferenceSize:CGSizeMake(320,80)];
            
            // Show the interests
            FeedViewController *rootViewController = [[FeedViewController alloc] initWithCollectionViewLayout:layoutFlow];
            UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[FitTagNavigationBar class]
                                                                                                  toolbarClass:[FitTagToolBar class]];
            [navController setViewControllers:@[rootViewController] animated:NO];
            
            // Present the Interests View Controller
            [self presentViewController:navController animated:YES completion:NULL];
            
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidAppear");
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    NSLog(@"logInViewController shouldBeginLogInWithUsername");
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"logInViewController didLogInUser");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"logInViewController didFailToLogInWithError");
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"logInViewControllerDidCancelLogIn logInController");
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    
    NSLog(@"signUpViewController ShouldBeginSignUp...My dictionary: %@ ", info);
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
    NSLog(@"signUpViewController didSignUpUser...user: %@ ", user);
    
    if(user){
        NSLog(@"User is logged in.");
        user[@"firstname"] = signUpViewController.firstname;
        user[@"lastname"] = signUpViewController.lastname;
        
        if(![signUpViewController.about isEqual:nil] && ![signUpViewController.about isEqual: @""]){
            user[@"bio"] = signUpViewController.about;
        } else {
            user[@"bio"] = @"Tell us about yourself(Optional)";
        }
        //userData[@"coverPhoto"] = signUpViewController.coverPhoto;
        
        NSLog(@"OBJECT: %@", user);

        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Error: saveEventually... %@", error);
                [user saveEventually];
            } else {
                NSLog(@"Saving... %@", user);
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


#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
