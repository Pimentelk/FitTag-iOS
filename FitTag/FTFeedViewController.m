//
//  FTFeedViewController
//  FitTag
//
//  Created by Kevin Pimentel on 8/16/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTFeedViewController.h"
#import "ImageCustomNavigationBar.h"
#import "FTHandleViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTInterestsViewController.h"
#import "FTInterestViewFlowLayout.h"
#import "AppDelegate.h"
#import "FTFlowLayout.h"
#import "FTSearchViewController.h"
//#import "FTNetworkViewController.h"
//#import "Reachability.h"

#define IMAGE_WIDTH 147
#define IMAGE_HEIGHT 203
#define IMAGE_Y 100

#define ANIMATION_DURATION 0.200f

@interface FTFeedViewController ()
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation FTFeedViewController
@synthesize firstLaunch;
@synthesize blankTimelineView;

#pragma mark - UIViewController

/*
-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error) {
        NSLog(@"error:%@",error);
        return;
    }
    
    NSLog(@"json:%@",json);
 
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray *predictions = [json objectForKey:@"predictions"];
    
    for (NSDictionary *prediction in predictions) {
        if ([prediction objectForKey:@"description"]) {
            NSLog(@"%@",[prediction objectForKey:@"description"]);
        }
    }
    
    NSArray *results = [json objectForKey:@"results"];
    for (NSDictionary *result in results) {
        if ([result objectForKey:@"name"]) {
            NSLog(@"%@",[result objectForKey:@"name"]);
        }
    }
    
    //Write out the data to the console.
    //NSLog(@"Google Data: %@", places);
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    //https://maps.googleapis.com/maps/api/place/search/json?location=40.757787,-74.035871&radius=500&types=gym&sensor=true&key=AIzaSyDLrDeCCYwFjiu_rW8ni72bWwurwChhZQU
    //https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=AddYourOwnKeyHere&input=pizza+near%20par
    NSString *googlePlacesURL = [NSString stringWithFormat:googleMapsAPIPlaceSearchURL,40.75778699404458,-74.0358710140337,@"2000",@"gym",GOOGLE_PLACES_API_KEY];
    //NSString *googlePlacesURL = [NSString stringWithFormat:googleMapsAPIPlaceQueryURL,GOOGLE_PLACES_API_KEY,@"gym+near+hoboken"];
    NSLog(@"googlePlacesURL:%@",googlePlacesURL);
    
    NSURL *googleRequestURL = [NSURL URLWithString:googlePlacesURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    */
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    */
    
    // Set Background
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - IMAGE_WIDTH)/2, IMAGE_Y, IMAGE_WIDTH, IMAGE_HEIGHT);
    [button setBackgroundImage:[UIImage imageNamed:IMAGE_TIMELINE_BLANK] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapFollowFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    
    [self shouldRunTestCode:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_MAP];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (![[PFUser currentUser] objectForKey:kFTUserDisplayNameKey]) {
        FTHandleViewController *handleViewController = [[FTHandleViewController alloc] init];
        [self.navigationController presentViewController:handleViewController animated:YES completion:nil];
        return;
    }
    
    if ([PFUser currentUser]) {
        [self isFirstTimeUser:[PFUser currentUser]];
        return;
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = YES;
    
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
        
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
        
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}

#pragma mark - ()
/*
- (void)reachabilityStatusChanged:(NSNotification *)notification {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        FTNetworkViewController *networkViewController = [[FTNetworkViewController alloc] init];
        [self.navigationController presentViewController:networkViewController animated:NO completion:nil];
    }
}
*/
- (void)shouldRunTestCode:(BOOL)run {
    if (run) {
        NSLog(@"***");
        for (NSString* family in [UIFont familyNames]) {
            NSLog(@"%@", family);            
            for (NSString* name in [UIFont fontNamesForFamilyName: family]) {
                NSLog(@"  %@", name);
            }
        }
    }
    
}

- (void)didTapFollowFriendsButtonAction:(id)sender {
    // Init search user controller
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    
    FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *followFriendsNavController = [[UINavigationController alloc] init];
    [followFriendsNavController setViewControllers:@[followFriendsViewController] animated:NO];
    [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
    [self.navigationController pushViewController:followFriendsViewController animated:YES];
}

- (BOOL)isFirstTimeUser:(PFUser *)user {
    //NSLog(@"%@::isFirstTimeUser:",VIEWCONTROLLER_FEED);
    // Check if the user has logged in before
    if (![user objectForKey:kFTUserLastLoginKey]) {
        
        //NSLog(@"user: %@",user);
    
        [self didLogInWithFacebook:user];
        [self didLogInWithTwitter:user];
        [self autoFollowFittag:user];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        // Set default settings
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushLikesKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushRewardsKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushCommentsKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFTUserDefaultsSettingsViewControllerPushMentionsKey];
        [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:kFTUserDefaultsSettingsViewControllerPushBusinessesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        FTInterestViewFlowLayout *interestLayoutFlow = [[FTInterestViewFlowLayout alloc] init];
        [interestLayoutFlow setItemSize:CGSizeMake(self.view.frame.size.width/2,42)];
        [interestLayoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
        [interestLayoutFlow setMinimumInteritemSpacing:0];
        [interestLayoutFlow setMinimumLineSpacing:0];
        [interestLayoutFlow setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [interestLayoutFlow setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width, 80)];
    
        // Show the interests
        FTInterestsViewController *interestsViewController = [[FTInterestsViewController alloc] initWithCollectionViewLayout:interestLayoutFlow];
        interestsViewController.isFirstLaunch = YES;
    
        UINavigationController *navController = [[UINavigationController alloc] init];
        [navController setViewControllers:@[interestsViewController] animated:NO];
    
        [self presentViewController:navController animated:NO completion:^(){
            [user setValue:[NSDate date] forKey:kFTUserLastLoginKey];
            if (user) {
                @try {
                    //NSLog(@"User:%@",user);
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"error:%@",error);
                            switch (error.code) {
                                case 101:
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                    [FTUtility showHudMessage:@"User not found" WithDuration:2];
                                    [[UIApplication sharedApplication].delegate performSelector:@selector(logOut)];
                                    break;
                                default:
                                    break;
                            }
                        }
                    }];
                } @catch (NSException *exception) {
                    NSLog(@"Exception:%@",exception);
                } @finally {
                    
                }
            }
            [self.tabBarController setSelectedIndex:2];
        }];
        NSLog(FIRSTTIME_USER);
        return YES;
    }
    
    //NSLog(RETURNING_USER);
    return NO;
}

- (BOOL)didLogInWithTwitter:(PFObject *)user {
    //NSLog(@"%@::didLogInWithTwitter:",VIEWCONTROLLER_FEED);
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(USER_DID_LOGIN_TWITTER);
        NSString *requestString = [NSString stringWithFormat:TWITTER_API_USERS,[PFTwitterUtils twitter].screenName];
        NSURL *verify = [NSURL URLWithString:requestString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
        
        [[PFTwitterUtils twitter] signRequest:request];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error == nil){
            NSDictionary *TWuser = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSString *profile_image_normal = [TWuser objectForKey:TWITTER_PROFILE_HTTPS];
            NSString *profile_image = [profile_image_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            NSData *profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profile_image]];
            
            NSString *names = [TWuser objectForKey:@"name"];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
            
            if (array.count > 1){
                [user setObject:[array lastObject] forKey:kFTUserLastnameKey];
                [array removeLastObject];
                [user setObject:[array componentsJoinedByString:@" "] forKey:kFTUserFirstnameKey];
            }
            
            /*
            if ([TWuser objectForKey:@"name"]) {
                [user setValue:[TWuser objectForKey:@"name"]
                        forKey:kFTUserDisplayNameKey];
            }
            */
            
            if ([TWuser objectForKey:@"id"]) {
                [user setValue:[NSString stringWithFormat:@"%@",[TWuser objectForKey:@"id"]]
                        forKey:kFTUserTwitterIdKey];
            }
            
            //[user setValue:DEFAULT_BIO_TEXT_B forKey:kFTUserBioKey];
            
            if (profileImageData) {
                PFFile *mediumPicFile = [PFFile fileWithData:profileImageData];
                [user setObject:mediumPicFile forKey:kFTUserProfilePicMediumKey];
                PFFile *smallPicFile = [PFFile fileWithData:profileImageData];
                [user setObject:smallPicFile forKey:kFTUserProfilePicSmallKey];
            }
            
            [user setValue:kFTUserTypeUser forKey:kFTUserTypeKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"error.code: %ld",(long)error.code);
                    switch (error.code) {
                        case 203:
                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Duplicate Email Error", nil)
                                                        message:NSLocalizedString(@"It looks like the email for this account has already been associated with another account", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil] show];
                            [self dismissViewControllerAnimated:NO completion:nil];
                            //[[PFUser currentUser] deleteInBackground];
                            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
                            break;
                            
                        default:
                            break;
                    }
                }
                
                if (!error) {
                    NSLog(@"twitter updated successful");
                }
            }];
        }
        return YES;
    }
    NSLog(USER_NOT_LOGIN_TWITTER);
    return NO;
}

- (BOOL)didLogInWithFacebook:(PFObject *)user {
    //NSLog(@"%@::didLogInWithFacebook:",VIEWCONTROLLER_FEED);
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(USER_DID_LOGIN_FACEBOOK);
        
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
            if (!error) {
                NSData *profileImageData = [NSData dataWithContentsOfURL:
                                            [NSURL URLWithString:
                                             [NSString stringWithFormat:FACEBOOK_GRAPH_PICTURES_URL,
                                              [FBuser objectForKey:FBUserIDKey]]]];
                
                if (profileImageData) {
                    PFFile *mediumPicFile = [PFFile fileWithData:profileImageData];
                    [user setObject:mediumPicFile forKey:kFTUserProfilePicMediumKey];
                    PFFile *smallPicFile = [PFFile fileWithData:profileImageData];
                    [user setObject:smallPicFile forKey:kFTUserProfilePicSmallKey];
                }
                
                // Get the data from facebook and put it into the user object
                [user setValue:[FBuser objectForKey:FBUserFirstNameKey] forKey:kFTUserFirstnameKey];
                [user setValue:[FBuser objectForKey:FBUserLastNameKey] forKey:kFTUserLastnameKey];
                //[user setValue:[FBuser objectForKey:FBUserNameKey] forKey:kFTUserDisplayNameKey];
                [user setValue:[FBuser objectForKey:FBUserEmailKey] forKey:kFTUserEmailKey];
                [user setValue:[FBuser objectForKey:FBUserIDKey] forKey:kFTUserFacebookIDKey];
                //[user setValue:DEFAULT_BIO_TEXT_B forKey:kFTUserBioKey];
                [user setValue:kFTUserTypeUser forKey:kFTUserTypeKey];
                [user setValue:[NSDate date] forKey:kFTUserLastLoginKey];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"error.code: %ld",(long)error.code);
                        switch (error.code) {
                            case 203:
                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Duplicate Email Error", nil)
                                                            message:NSLocalizedString(@"It looks like the email for this account has already been associated with another account", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil] show];
                                [self dismissViewControllerAnimated:NO completion:nil];
                                //[[PFUser currentUser] deleteInBackground];
                                [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    if (!error) {
                        NSLog(@"facebook updated successful");
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

- (void)autoFollowFittag:(PFUser *)user {
    
    PFQuery *fittagQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [fittagQuery whereKey:kFTUserDisplayNameKey equalTo:@"fittag"];
    [fittagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                
                PFUser *fittagUser = [objects objectAtIndex:0];
                if (fittagUser) {
                    
                    [FTUtility followUserInBackground:fittagUser block:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"Error following fittag: %@",error);
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:FTUtilityUserFollowingChangedNotification object:nil];
                        }
                    }];
                    
                } else {
                    NSLog(@"No fittag user...");
                }
                
            } else {
                NSLog(@"There should only be one user... BUT THERE ISN'T!!!");
            }
        }
    }];
    
}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

