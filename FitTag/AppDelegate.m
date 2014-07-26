//
//  AppDelegate.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"
#import "FitTagConfigViewController.h"
#import "FTActivityFeedViewController.h"
#import "FeedViewController.h"
#import "FTAccountViewController.h"
#import "FTPhotoDetailsViewController.h"

@interface AppDelegate()
{
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) FeedViewController *homeViewController;
@property (nonatomic, strong) FitTagConfigViewController *welcomeViewController;
@property (nonatomic, strong) FTActivityFeedViewController *activityViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"9Cii0KKJr09vtACtVRSccu1BHGFJYR6c6XYkafb1"
                  clientKey:@"eJxD9HcQ5ZK8GPYxaMz4RkrOjo2mMtujGsgn1HZe"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set root view controller
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"oNqZ0kZQxrAEHeMggEvls5VdJ" consumerSecret: @"cvltCUyuouYILtFlsf05G1eA1C7J7ZCDUQkO5iawD9RRabnPte"];
    
    
    
    return YES;
}
/*
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url ];
}
*/

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //return [PFFacebookUtils handleOpenURL:url];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Handle an interruption during the authorization flow, such as the user clicking the home button.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook;
    loginViewController.facebookPermissions = @[ @"user_about_me" ];
    
    [self.welcomeViewController presentViewController:loginViewController animated:NO completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {
    self.tabBarController = [[FTTabBarController alloc] init];
    self.homeViewController = [[FeedViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[FTActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"Home") image:[[UIImage imageNamed:@"IconHome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconHomeSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", @"Activity") image:[[UIImage imageNamed:@"IconTimeline.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconTimelineSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:86.0f/255.0f green:55.0f/255.0f blue:42.0f/255.0f alpha:1.0f] } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:129.0f/255.0f green:99.0f/255.0f blue:69.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, emptyNavigationController, activityFeedNavigationController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kFTUserFacebookIDKey]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
}

- (void)logOut {
    // clear cache
    //[[FTCache sharedCache] clear];
    
    // clear NSUserDefaults
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFTUserDefaultsCacheFacebookFriendsKey];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFTUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    //[[PFInstallation currentInstallation] removeObjectForKey:kFTInstallationUserKey];
    //[[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
   
    
    //[self setupRootView];
    
    self.homeViewController = nil;
    //self.activityViewController = nil;
}

#pragma mark - ()

- (void)setupAppearance {
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FitTagConfigViewController alloc] init]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        //if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {        
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([FTUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kFTLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kFTPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:FTFeedTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            FTPhotoDetailsViewController *detailViewController = [[FTPhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[FTCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:kFTUserFacebookFriendsKey]) {
                [user removeObjectForKey:kFTUserFacebookFriendsKey];
            }
            
            if (![user objectForKey:kFTUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kFTUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using Anypic
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kFTUserFacebookIDKey containedIn:facebookIds];
                
                NSArray *anypicFriends = [facebookFriendsQuery findObjects:&error];
                
                if (!error) {
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kFTActivityClassKey];
                        [joinActivity setObject:user forKey:kFTActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kFTActivityToUserKey];
                        [joinActivity setObject:kFTActivityTypeJoined forKey:kFTActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [FTUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kFTUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kFTUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kFTUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

@end
