//
//  AppDelegate.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"
#import "UIImage+ResizeAdditions.h"
#import "FTConfigViewController.h"
#import "FTActivityFeedViewController.h"
#import "FTFeedViewController.h"
#import "FTUserProfileViewController.h"
#import "FTMapViewController.h"
#import "FTRewardsCollectionViewController.h"
#import "FTNavigationController.h"
#import "FTPostDetailsViewController.h"

@interface AppDelegate() {
    NSMutableData *_data;
    BOOL firstLaunch;
}

// Welcome View Controller
@property (nonatomic, strong) FTConfigViewController *welcomeViewController;

// TabBar ViewControllers
@property (nonatomic, strong) FTActivityFeedViewController *activityViewController;
@property (nonatomic, strong) FTMapViewController *mapViewController;
@property (nonatomic, strong) FTFeedViewController *feedViewController;
@property (nonatomic, strong) FTRewardsCollectionViewController *rewardsViewController;
@property (nonatomic, strong) FTUserProfileViewController *userProfileViewController;

// Progress HUD (Notification/Loader)
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //NSLog(@"%@::application:didFinishLaunchingWithOptions:",APPDELEGATE_RESPONDER);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_TRACKING_ID];
    
    // Parse initialization
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for remote notifications
    [self registerForRemoteNotification];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    self.welcomeViewController = [[FTConfigViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    [self.navController setNavigationBarHidden: NO];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:TWITTER_CONSUMER_KEY
                               consumerSecret:TWITTER_CONSUMER_SECRET];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@::application:didRegisterForRemoteNotificationsWithDeviceToken:",APPDELEGATE_RESPONDER);
    //[self registerForRemoteNotification];
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@::application:didFailToRegisterForRemoteNotificationsWithError:",APPDELEGATE_RESPONDER);
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSLog(@"%@::application:didReceiveRemoteNotification:",APPDELEGATE_RESPONDER);
    //NSLog(@"userInfo:%@",userInfo);
    
    if ([userInfo objectForKey:kFTPushPayloadActivityLikeKey] && [[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushLikesKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    }
    
    if ([userInfo objectForKey:kFTPushPayloadActivityCommentKey] && [[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    }
    
    if ([userInfo objectForKey:kFTPushPayloadActivityFollowKey] && [[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushFollowsKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    }
    
    if ([userInfo objectForKey:kFTPushPayloadActivityMentionKey] && [[NSUserDefaults standardUserDefaults] boolForKey:kFTUserDefaultsSettingsViewControllerPushMentionsKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > FTActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:FTActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        
                        NSLog(@"Unhandled deep link: %@", url);
                        
                        [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
                    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%@::applicationDidBecomeActive:",APPDELEGATE_RESPONDER);
    // Handle an interruption during the authorization flow, such as the user clicking the home button.
    //[FBSession.activeSession handleDidBecomeActive];
    
    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    //[FBSession.activeSession handleDidBecomeActive];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    //NSLog(@"%@::tabBarController:shouldSelectViewController:",APPDELEGATE_RESPONDER);
    // The empty UITabBarItem behind our Camera button should not load a view controller
    //return ![viewController isEqual:aTabBarController.viewControllers[FTReardsTabBarItemIndex]];
    return YES;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"%@::connection:didReceiveResponse:",APPDELEGATE_RESPONDER);
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"%@::connection:didReceiveResponse:",APPDELEGATE_RESPONDER);
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"%@::connectionDidFinishLoading:",APPDELEGATE_RESPONDER);
    //[FTUtility processFacebookProfilePictureData:_data];
}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    //NSLog(@"%@::isParseReachable:",APPDELEGATE_RESPONDER);
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    NSLog(@"%@::presentLoginViewControllerAnimated:",APPDELEGATE_RESPONDER);
    
}

- (void)presentLoginViewController {
    //NSLog(@"%@::presentLoginViewController:",APPDELEGATE_RESPONDER);
    //[self presentLoginViewControllerAnimated:NO];
}

- (void)presentTabBarController {
    
    //NSLog(@"%@::presentTabBarController:",APPDELEGATE_RESPONDER);
    
    /** START TAB VIEW CONTROLLERS INIT **/
    self.tabBarController = [[FTTabBarController alloc] init];
    
    // Feed ViewController
    self.feedViewController = [[FTFeedViewController alloc] initWithClassName:kFTPostClassKey];
    [self.feedViewController setFirstLaunch:firstLaunch];
    
    // Activity ViewController
    self.activityViewController = [[FTActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    // Map ViewController - Home
    self.mapViewController = [[FTMapViewController alloc] init];
    
    CGRect bounds = [[[[UIApplication sharedApplication] delegate] window] bounds];
    
    // Profile View Controller
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(bounds.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
    
    self.userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [self.userProfileViewController setUser:[PFUser currentUser]];
    
    // Rewards View Controller
    UICollectionViewFlowLayout *layoutFlow = [[UICollectionViewFlowLayout alloc] init];
    [layoutFlow setItemSize:CGSizeMake(158,185)];
    [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layoutFlow setMinimumInteritemSpacing:0];
    [layoutFlow setMinimumLineSpacing:0];
    [layoutFlow setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [layoutFlow setHeaderReferenceSize:CGSizeMake(bounds.size.width,REWARDS_MENU_HEIGHT)];
    
    self.rewardsViewController = [[FTRewardsCollectionViewController alloc] initWithCollectionViewLayout:layoutFlow];
    
    /** END TAB VIEW CONTROLLERS INIT **/
    FTNavigationController *emptyNavigationController           = [[FTNavigationController alloc] init];
    FTNavigationController *feedNavigationController            = [[FTNavigationController alloc] initWithRootViewController:self.feedViewController];
    FTNavigationController *activityFeedNavigationController    = [[FTNavigationController alloc] initWithRootViewController:self.activityViewController];
    FTNavigationController *mapNavigationController             = [[FTNavigationController alloc] initWithRootViewController:self.mapViewController];
    FTNavigationController *rewardsFeedNavigationController     = [[FTNavigationController alloc] initWithRootViewController:self.rewardsViewController];
    FTNavigationController *userProfileNavigationController     = [[FTNavigationController alloc] initWithRootViewController:self.userProfileViewController];

    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:feedNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:mapNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:rewardsFeedNavigationController];
    [FTUtility addBottomDropShadowToNavigationBarForNavigationController:userProfileNavigationController];
    
    // Feed ViewController
    UITabBarItem *feedTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                 image:[[UIImage imageNamed:BUTTON_IMAGE_FEED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                         selectedImage:[[UIImage imageNamed:BUTTON_IMAGE_FEED_SELECTED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    
    // Notifications ViewController
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                         image:[[UIImage imageNamed:BUTTON_IMAGE_NOTIFICATIONS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                 selectedImage:[[UIImage imageNamed:BUTTON_IMAGE_NOTIFICATIONS_SELECTED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // Rewards ViewController
    UITabBarItem *rewardsFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                        image:[[UIImage imageNamed:BUTTON_IMAGE_REWARDS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                selectedImage:[[UIImage imageNamed:BUTTON_IMAGE_REWARDS_SELECTED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // Map ViewController
    UITabBarItem *mapTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                image:[[UIImage imageNamed:BUTTON_IMAGE_SEARCH] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:BUTTON_IMAGE_SEARCH_SELECTED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    // User Profile ViewController
    UITabBarItem *userProfileTabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                        image:[[UIImage imageNamed:BUTTON_IMAGE_USER_PROFILE] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                selectedImage:[[UIImage imageNamed:BUTTON_IMAGE_USER_PROFILE_SELECTED] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    
    [feedNavigationController setTabBarItem:feedTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [rewardsFeedNavigationController setTabBarItem:rewardsFeedTabBarItem];
    [mapNavigationController setTabBarItem:mapTabBarItem];
    [userProfileNavigationController setTabBarItem:userProfileTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ activityFeedNavigationController,
                                               mapNavigationController,
                                               feedNavigationController,
                                               userProfileNavigationController,
                                               rewardsFeedNavigationController ];
    self.tabBarController.selectedIndex = TAB_FEED;
    
    for (int i = 0; i < [self.tabBarController.tabBar items].count; i++) {
        [[[self.tabBarController.tabBar items] objectAtIndex:i] setImageInsets:UIEdgeInsetsMake(TAB_BAR_INSET_TOP, 0, TAB_BAR_INSET_BOTTOM, 0)];
    }
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];
    [self registerForRemoteNotification];
}

- (void)logOut {
    //NSLog(@"%@::logOut:",APPDELEGATE_RESPONDER);
    // clear cache
    [[FTCache sharedCache] clear];
    
    // clear NSUserDefaults
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFTUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFTUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kFTInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.feedViewController         = nil;
    self.activityViewController     = nil;
    self.mapViewController          = nil;
    self.rewardsViewController      = nil;
    self.userProfileViewController  = nil;
}

#pragma mark - ()

- (void)registerForRemoteNotification {
    NSLog(@"%@::registerForRemoteNotification:",APPDELEGATE_RESPONDER);
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)monitorReachability {
    NSLog(@"%@::monitorReachability:",APPDELEGATE_RESPONDER);
    Reachability *hostReach = [Reachability reachabilityWithHostname:PARSE_HOST];
    
    hostReach.reachableBlock = ^(Reachability *reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        //if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        if ([self isParseReachable] && [PFUser currentUser] && self.feedViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.feedViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    NSLog(@"%@::handlePush:",APPDELEGATE_RESPONDER);
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kFTPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPost:[PFObject objectWithoutDataWithClassName:kFTPostClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kFTPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *feedNavigationController = self.tabBarController.viewControllers[FTFeedTabBarItemIndex];
                    self.tabBarController.selectedViewController = feedNavigationController;
                    
                    CGRect boudns = [[[[UIApplication sharedApplication] delegate] window] bounds];
                    
                    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
                    [flowLayout setItemSize:CGSizeMake(105.5,105)];
                    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                    [flowLayout setMinimumInteritemSpacing:0];
                    [flowLayout setMinimumLineSpacing:0];
                    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
                    [flowLayout setHeaderReferenceSize:CGSizeMake(boudns.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
                    
                    FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
                    [profileViewController setUser:[PFUser currentUser]];
                    [feedNavigationController pushViewController:profileViewController animated:YES];
                }
            }];
        }
    }
}

- (void)shouldNavigateToPost:(PFObject *)targetPost {
    
    // if we have a local copy of this post, this won't result in a network fetch
    [targetPost fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            FTNavigationController *feedNavigationController = [[self.tabBarController viewControllers] objectAtIndex:TAB_FEED];
            [self.tabBarController setSelectedViewController:feedNavigationController];
            
            FTPostDetailsViewController *postDetailViewController = [[FTPostDetailsViewController alloc] initWithPost:targetPost AndType:nil];
            [feedNavigationController pushViewController:postDetailViewController animated:YES];
        }
    }];
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    //NSLog(@"%@::autoFollowTimerFired:",APPDELEGATE_RESPONDER);
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.feedViewController.view animated:YES];
    [self.feedViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    NSLog(@"%@::shouldProceedToMainInterface:",APPDELEGATE_RESPONDER);
    if ([FTUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    
    return NO;
}

@end
