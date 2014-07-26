//
//  FTSettingsActionSheetDelegate.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSettingsActionSheetDelegate.h"
#import "FTFindFriendsViewController.h"
#import "FTAccountViewController.h"
#import "AppDelegate.h"

// ActionSheet button indexes
typedef enum {
	kFTSettingsProfile = 0,
	kFTSettingsFindFriends,
	kFTSettingsLogout,
    kFTSettingsNumberOfButtons
} kFTSettingsActionSheetButtons;

@implementation FTSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kFTSettingsActionSheetButtons)buttonIndex) {
        case kFTSettingsProfile:
        {
            FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kFTSettingsFindFriends:
        {
            FTFindFriendsViewController *findFriendsVC = [[FTFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kFTSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end

