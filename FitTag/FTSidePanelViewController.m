//
//  FTSidePanelViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 1/30/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTSidePanelViewController.h"
#import "FTUserProfileViewController.h"
#import "FTActivityFeedViewController.h"
#import "FTRewardsViewController.h"
#import "FTFindFriendsCell.h"
#import "FTFollowFriendsViewController.h"
#import "FTSettingsViewController.h"

#define NOTIFICATIONS @"Notifications"
#define REWARDS @"Rewards"
#define ADD_FRIENDS @"Add Friends"

@interface FTSidePanelViewController ()
@property (nonatomic, strong) NSArray *objects;
@end

@implementation FTSidePanelViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self.tableView setDelegate:self];
    
    // Configure background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Configs
    [self configNavigation];
    
    self.objects = [NSArray arrayWithObjects:NOTIFICATIONS,REWARDS,ADD_FRIENDS, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configs

- (void)configNavigation
{
    // Config the navigation bar
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    navBar.barTintColor = FT_RED;
    navBar.translucent = NO;
    
    UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithImage:BUTTON_IMAGE_SETTING
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(didTapSettingButtonAction:)];
    
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithImage:BUTTON_IMAGE_REVEAL
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapMenuButtonAction:)];
    
    [setting setTintColor:[UIColor whiteColor]];
    [menu setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:setting];
    [self.navigationItem setRightBarButtonItem:menu];
    [self.navigationController setToolbarHidden:YES];
}

#pragma mark

- (void)didTapMenuButtonAction:(UIBarButtonItem *)button {
    if (delegate && [delegate respondsToSelector:@selector(sidePanelViewController:didTapMenuButtonAction:)]) {
        [delegate sidePanelViewController:self didTapMenuButtonAction:button];
    }
}

- (void)didTapSettingButtonAction:(UIBarButtonItem *)button {
    FTSettingsViewController *settingsViewController = [[FTSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void)didTapProfileHeaderAction:(id)sender
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(self.view.bounds.size.width/3,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.bounds.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
    
    PFUser *user = [PFUser currentUser];
    
    FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setUser:user];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    
    // Config the user profile
    PFUser *user = [PFUser currentUser];
    if (user) {
        
        CGSize size = self.view.frame.size;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProfileHeaderAction:)];
        [tapGesture setNumberOfTapsRequired:1];
        
        // Profile Picture & cover photo container
        UIView *headerPhotosContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width / 2)];
        [headerPhotosContainer setBackgroundColor:FT_GRAY];
        [headerPhotosContainer setAlpha:0.0f];
        [headerPhotosContainer setClipsToBounds:YES];
        [headerPhotosContainer addGestureRecognizer:tapGesture];
        [headerView addSubview:headerPhotosContainer];
        
        // Profile Picture Image
        PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)];
        [profilePictureImageView setCenter:CGPointMake(size.width / 2, headerPhotosContainer.frame.size.height / 2)];
        [profilePictureImageView setBackgroundColor:FT_RED];
        [profilePictureImageView setClipsToBounds: YES];
        [profilePictureImageView setAlpha:0.0f];
        [profilePictureImageView.layer setCornerRadius:CORNERRADIUS(PROFILE_IMAGE_WIDTH)];
        [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        [headerView addSubview:profilePictureImageView];
        
        //NSLog(@"coverPhoto width:%f height:%f", size.width, size.width / 2);
        
        // Cover Photo
        PFImageView *coverPhotoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width / 2)];
        [coverPhotoImageView setClipsToBounds:YES];
        [coverPhotoImageView setBackgroundColor:FT_GRAY];
        [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFit];
        [headerPhotosContainer addSubview:coverPhotoImageView];
        
        // Set cover photo
        PFFile *coverPhotoFile = [user objectForKey:kFTUserCoverPhotoKey];
        if (coverPhotoFile && ![coverPhotoFile isEqual:[NSNull null]]) {
            [coverPhotoImageView setFile:coverPhotoFile];
            [coverPhotoImageView loadInBackground];
            [coverPhotoImageView setAlpha:1];
            [headerPhotosContainer setAlpha:1];
        } else {
            UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverPhotoImageView.frame];
            [coverImageView setImage:nil];
            [coverImageView setClipsToBounds:YES];
            [coverImageView setBackgroundColor:FT_GRAY];
            [coverPhotoImageView addSubview:coverImageView];
        }
        
        // Set profile photo
        PFFile *imageFile = [user objectForKey:kFTUserProfilePicMediumKey];
        if (imageFile && ![imageFile isEqual:[NSNull null]]) {
            [profilePictureImageView setFile:imageFile];
            [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
                if (!error) {
                    [UIView animateWithDuration:0.3f animations:^{
                        headerPhotosContainer.alpha = 1.0f;
                        profilePictureImageView.alpha = 1.0f;
                    }];
                }
            }];
        } else {
            UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:profilePictureImageView.frame];
            [profileImageView setImage:[UIImage imageNamed:IMAGE_PROFILE_EMPTY]];
            [profileImageView setClipsToBounds:YES];
            [profileImageView.layer setCornerRadius:CORNERRADIUS(profileImageView.frame.size.width)];
            [headerView addSubview:profileImageView];
        }
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
    
    NSString *title = self.objects[indexPath.row];
    
    if ([title isEqualToString:NOTIFICATIONS]) {
        [tableViewCell.imageView setImage:BUTTON_IMAGE_NOTIFICATIONS];
    } else if ([title isEqualToString:REWARDS]) {
        [tableViewCell.imageView setImage:BUTTON_IMAGE_REWARDS];
    } else if ([title isEqualToString:ADD_FRIENDS]) {
        [tableViewCell.imageView setImage:BUTTON_IMAGE_ADD_FRIENDS];
    }
    
    [tableViewCell.textLabel setText:self.objects[indexPath.row]];
    [tableViewCell.textLabel setFont:MULIREGULAR(18)];
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    

    NSString *title = self.objects[indexPath.row];
    
    if ([title isEqualToString:NOTIFICATIONS]) {
        
        FTActivityFeedViewController *activityVC = [[FTActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:activityVC animated:YES];
        
    } else if ([title isEqualToString:REWARDS]) {
        
        CGSize size = self.view.frame.size;
        
        // Rewards View Controller
        UICollectionViewFlowLayout *layoutFlow = [[UICollectionViewFlowLayout alloc] init];
        [layoutFlow setItemSize:CGSizeMake(size.width/2,185)];
        [layoutFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layoutFlow setMinimumInteritemSpacing:0];
        [layoutFlow setMinimumLineSpacing:0];
        [layoutFlow setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [layoutFlow setHeaderReferenceSize:CGSizeMake(size.width,REWARDS_MENU_HEIGHT)];
        
        FTRewardsCollectionViewController *rewardsViewController = [[FTRewardsCollectionViewController alloc] initWithCollectionViewLayout:layoutFlow];
        [self.navigationController pushViewController:rewardsViewController animated:YES];
        
    } else if ([title isEqualToString:ADD_FRIENDS]) {
        
        FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
        followFriendsViewController.followUserQueryType = FTFollowUserQueryTypeDefault;
        
        [self.navigationController pushViewController:followFriendsViewController animated:YES];
    }
}

@end
