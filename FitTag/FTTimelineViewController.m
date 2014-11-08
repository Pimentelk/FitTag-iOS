//
//  FTPhotoTimelineViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTTimelineViewController.h"
#import "FTUserProfileViewController.h"
#import "FTPostDetailsViewController.h"
#import "FTUtility.h"
#import "FTLoadMoreCell.h"
#import "FTMapViewController.h"

@interface FTTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) UIBarButtonItem *dismissProfileButton;
@property (nonatomic, strong) FTUserProfileViewController *profileViewController;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation FTTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize dismissProfileButton;
@synthesize flowLayout;
@synthesize profileViewController;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kFTPostClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = YES;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    // Override the back idnicator
    dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
    [dismissProfileButton setTintColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];

    // Go to selected user profile
    
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(320,335)];
    
    profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = YES;
        [self loadObjects];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 0;
    }
    return 320.0f;
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:100];
        return query;
    }
    
    // List of all users being followed by current user
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 100;
    
    // Posts from users being followed
    PFQuery *postsFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [postsFromFollowedUsersQuery whereKey:kFTPostUserKey matchesKey:kFTActivityToUserKey inQuery:followingActivitiesQuery];
    [postsFromFollowedUsersQuery whereKey:kFTPostTypeKey containedIn:@[kFTPostTypeImage,kFTPostTypeVideo,kFTPostTypeGallery]];
    
    // Posts from current user
    PFQuery *postsFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [postsFromCurrentUserQuery whereKey:kFTPostUserKey equalTo:[PFUser currentUser]];
    [postsFromCurrentUserQuery whereKey:kFTPostTypeKey containedIn:@[kFTPostTypeImage,kFTPostTypeVideo,kFTPostTypeGallery]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: postsFromFollowedUsersQuery, postsFromCurrentUserQuery, nil]];
    [query includeKey:kFTPostUserKey];
    [query orderByDescending:@"createdAt"];
        
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    return nil;
}

#pragma mark - PFTableViewCellDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *videoCellIdentifier = @"VideoCell";
    static NSString *photoCellIdentifier = @"PhotoCell";
    static NSString *galleryCellIdentifier = @"GalleryCell";
    
    //NSLog(@"FTTimelineViewController::Updating tableView:(UITableView *) %@ cellForRowAtIndexPath:(NSIndexPath *) %@ object:(PFObject *) %@",tableView,indexPath,object);
    
    if (indexPath.section == self.objects.count) {
        return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
    }
    
    //*********************************** If the cell is a gallery ****************************************//
    
    FTGalleryCell *galleryCell = (FTGalleryCell *)[tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
    if (galleryCell == nil) {
        galleryCell = [[FTGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:galleryCellIdentifier];
        galleryCell.delegate = self;
    }
    
    // If the cell is a gallery
    if ([[object objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeGallery]) {
    
        PFObject *gallery = [self.objects objectAtIndex:indexPath.section];
        [galleryCell setGallery:gallery];
        [galleryCell setTag:indexPath.section];
        [galleryCell.likeCounter setTag:indexPath.section];
        
        NSDictionary *attributesForGallery = [[FTCache sharedCache] attributesForPost:gallery];
        
        if (attributesForGallery) {
            [galleryCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:gallery]];
            [galleryCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:gallery] description] forState:UIControlStateNormal];
            [galleryCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:gallery] description] forState:UIControlStateNormal];
            [galleryCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:gallery] description] forState:UIControlStateNormal];
        } else {
            @synchronized(self) {
                // check if we can update the cache
                NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(indexPath.section)];
                if (!outstandingSectionHeaderQueryStatus) {
                    PFQuery *query = [FTUtility queryForActivitiesOnPost:gallery cachePolicy:kPFCachePolicyNetworkOnly];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingSectionHeaderQueries removeObjectForKey:@(indexPath.section)];
                            
                            if (error) {
                                NSLog(@"ERROR##: %@",error);
                                return;
                            }
                            
                            NSMutableArray *likers = [NSMutableArray array];
                            NSMutableArray *commenters = [NSMutableArray array];
                            
                            BOOL isLikedByCurrentUser = NO;
                            
                            for (PFObject *activity in objects) {
                                if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                }
                                
                                if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                    if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                        isLikedByCurrentUser = YES;
                                    }
                                }
                            }
                            
                            if (galleryCell.tag != indexPath.section) {
                                return;
                            }
                            
                            [[object objectForKey:kFTPostUserKey] fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                                if (!error) {
                                    [[FTCache sharedCache] setAttributesForPost:gallery
                                                                         likers:likers
                                                                     commenters:commenters
                                                             likedByCurrentUser:isLikedByCurrentUser
                                                                    displayName:[user objectForKey:kFTUserDisplayNameKey]];
                                    
                                    [galleryCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:gallery]];
                                    [galleryCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:gallery] description] forState:UIControlStateNormal];
                                    [galleryCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:gallery] description] forState:UIControlStateNormal];
                                    [galleryCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:gallery] description] forState:UIControlStateNormal];
                                } else {
                                    NSLog(@"ERROR##: %@",error);
                                }
                            }];
                        }
                    }];
                }
            }
        }
        
        
        galleryCell.galleryButton.tag = indexPath.section;
        galleryCell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
        /*
        if (object) {
            galleryCell.imageView.file = [object objectForKey:kFTPostImageKey];
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([galleryCell.imageView.file isDataAvailable]) {
                [galleryCell.imageView loadInBackground];
            }
        }
        */
        
        return galleryCell;
    }
    
    //*********************************** If the cell is a video ****************************************//
    
    FTVideoCell *videoCell = (FTVideoCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    if (videoCell == nil) {
        videoCell = [[FTVideoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:videoCellIdentifier];
        videoCell.delegate = self;
    }
    
    // If the cell is a video
    if ([[object objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeVideo]) {
        
        PFObject *video = [self.objects objectAtIndex:indexPath.section];
        PFFile *videoFile = [video objectForKey:kFTPostVideoKey];
        [videoCell.moviePlayer setContentURL:[NSURL URLWithString:videoFile.url]];
        [videoCell setVideo:video];
        [videoCell setTag:indexPath.section];
        [videoCell.likeCounter setTag:indexPath.section];
        
        NSDictionary *attributesForVideo = [[FTCache sharedCache] attributesForPost:video];
        
        if (attributesForVideo) {
            [videoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:video]];
            [videoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:video] description] forState:UIControlStateNormal];
            [videoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:video] description] forState:UIControlStateNormal];
            [videoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:video] description] forState:UIControlStateNormal];
        } else {
            @synchronized(self) {
                // check if we can update the cache
                NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(indexPath.section)];
                if (!outstandingSectionHeaderQueryStatus) {
                    PFQuery *query = [FTUtility queryForActivitiesOnPost:video cachePolicy:kPFCachePolicyNetworkOnly];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingSectionHeaderQueries removeObjectForKey:@(indexPath.section)];
                            
                            if (error) {
                                NSLog(@"ERROR##: %@",error);
                                return;
                            }
                            
                            NSMutableArray *likers = [NSMutableArray array];
                            NSMutableArray *commenters = [NSMutableArray array];
                            
                            BOOL isLikedByCurrentUser = NO;
                            
                            for (PFObject *activity in objects) {
                                if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                }
                                
                                if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                    if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                        isLikedByCurrentUser = YES;
                                    }
                                }
                            }
                            
                            
                            if (videoCell.tag != indexPath.section) {
                                return;
                            }
                            
                            [[object objectForKey:kFTPostUserKey] fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                                if (!error) {
                                    [[FTCache sharedCache] setAttributesForPost:video
                                                                         likers:likers
                                                                     commenters:commenters
                                                             likedByCurrentUser:isLikedByCurrentUser
                                                                    displayName:[user objectForKey:kFTUserDisplayNameKey]];
                                    
                                    [videoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:video]];
                                    [videoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:video] description] forState:UIControlStateNormal];
                                    [videoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:video] description] forState:UIControlStateNormal];
                                    [videoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:video] description] forState:UIControlStateNormal];
                                } else {
                                    NSLog(@"ERROR##: %@",error);
                                }
                            }];
                        }
                    }];
                }
            }
        }

        videoCell.videoButton.tag = indexPath.section;
        videoCell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
        
        if (object) {
            videoCell.imageView.file = [object objectForKey:kFTPostImageKey];            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([videoCell.imageView.file isDataAvailable]) {
                [videoCell.imageView loadInBackground];
            }
        }
        return videoCell;
    }
    
    //*********************************** If the cell is an image ****************************************//
    
    FTPhotoCell *photoCell = (FTPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
    
    if (photoCell == nil) {
        photoCell = [[FTPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:photoCellIdentifier];
        photoCell.delegate = self;
    }
    
    if([[object objectForKey:kFTPostTypeKey] isEqualToString:kFTPostTypeImage]) {
        
        PFObject *photo = [self.objects objectAtIndex:indexPath.section];
        [photoCell setPhoto:photo];
        [photoCell setTag:indexPath.section];
        [photoCell.likeCounter setTag:indexPath.section];
        
        NSDictionary *attributesForPhoto = [[FTCache sharedCache] attributesForPost:photo];
        
        if (attributesForPhoto) {
            [photoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:photo]];
            [photoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:photo] description] forState:UIControlStateNormal];
            [photoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:photo] description] forState:UIControlStateNormal];
            [photoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:photo] description] forState:UIControlStateNormal];
        } else {
            
            @synchronized(self) {
                // check if we can update the cache
                NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(indexPath.section)];
                if (!outstandingSectionHeaderQueryStatus) {
                    PFQuery *query = [FTUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingSectionHeaderQueries removeObjectForKey:@(indexPath.section)];
                            
                            if (error) {
                                NSLog(@"ERROR##: %@",error);
                                return;
                            }
                            
                            NSMutableArray *likers = [NSMutableArray array];
                            NSMutableArray *commenters = [NSMutableArray array];
                            
                            BOOL isLikedByCurrentUser = NO;
                            
                            for (PFObject *activity in objects) {
                                if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [likers addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                } else if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeComment] && [activity objectForKey:kFTActivityFromUserKey]) {
                                    [commenters addObject:[activity objectForKey:kFTActivityFromUserKey]];
                                }
                                
                                if ([[[activity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                    if ([[activity objectForKey:kFTActivityTypeKey] isEqualToString:kFTActivityTypeLike]) {
                                        isLikedByCurrentUser = YES;
                                    }
                                }
                            }
                            
                            if (photoCell.tag != indexPath.section) {
                                return;
                            }
                            
                            [[object objectForKey:kFTPostUserKey] fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                                if (!error) {
                                    [[FTCache sharedCache] setAttributesForPost:photo
                                                                         likers:likers
                                                                     commenters:commenters
                                                             likedByCurrentUser:isLikedByCurrentUser
                                                                    displayName:[user objectForKey:kFTUserDisplayNameKey]];
                                    
                                    [photoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:photo]];
                                    [photoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:photo] description] forState:UIControlStateNormal];
                                    [photoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:photo] description] forState:UIControlStateNormal];
                                    [photoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:photo] description] forState:UIControlStateNormal];
                                } else {
                                    NSLog(@"ERROR##: %@",error);
                                }
                            }];
                        }
                    }];
                }
            }
        }
        
        photoCell.photoButton.tag = indexPath.section;
        photoCell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
        
        if (object) {
            photoCell.imageView.file = [object objectForKey:kFTPostImageKey];
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([photoCell.imageView.file isDataAvailable]) {
                [photoCell.imageView loadInBackground];
            }
        }
        
        return photoCell;
    }
    
    return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
}

#pragma mark - FTPhotoTimelineViewController

- (FTPhotoCell *)dequeueReusableSectionHeaderView {
    for (FTPhotoCell *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}

#pragma mark - FTGalleryCellViewDelegate

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    
    // Push account view controller
    [profileViewController setUser:user];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapLikeGalleryButton:(UIButton *)button counter:(UIButton *)counter gallery:(PFObject *)gallery {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLikeGalleryButton:counter:gallery:");
    
    //NSLog(@"FTPhotoTimelineViewController::Updating photoCellView:(FTPhotoCell *) %@ didTapLikePhotoButton:(UIButton *) %@ counter:(UIButton *) %@ photo:(PFObject *) %@",photoCellView,button,counter,photo);
    
    // Disable the button so users cannot send duplicate requests
    [galleryCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [galleryCellView setLikeStatus:liked];
    
    NSString *originalButtonTitle = counter.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:counter.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[FTCache sharedCache] incrementLikerCountForPost:gallery];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[FTCache sharedCache] decrementLikerCountForPost:gallery];
    }
    
    
    [[FTCache sharedCache] setPostIsLikedByCurrentUser:gallery liked:liked];
    
    [counter setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        [FTUtility likePhotoInBackground:gallery block:^(BOOL succeeded, NSError *error) {
            FTPhotoCell *actualView = (FTPhotoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:succeeded];
            
            if (!succeeded) {
                //[actualView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if (error) {
                NSLog(@"ERROR###: %@",error);
            }
        }];
    } else {
        // warnParseOperationOnMainThread()
        [FTUtility unlikePhotoInBackground:gallery block:^(BOOL succeeded, NSError *error) {
            FTPhotoCell *actualView = (FTPhotoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                //[actualView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if(error){
                NSLog(@"ERROR#: %@",error);
            }
        }];
    }
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapCommentOnGalleryButton:(UIButton *)button  gallery:(PFObject *)gallery {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapCommentOnGalleryButton:gallery:");
    FTPostDetailsViewController *photoDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:gallery AndType:kFTPostTypeGallery];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapMoreButton:(UIButton *)button gallery:(PFObject *)gallery{
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapImageInGalleryAction:gallery:");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ReTag", @"Share on Facebook", @"Tweet", @"Report as Inappropriate",  nil];
    [actionSheet showInView:self.view];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapImageInGalleryAction:(UIButton *)button gallery:(PFObject *)gallery {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapImageInGalleryAction:gallery:");
    FTPostDetailsViewController *galleryDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:gallery AndType:kFTPostTypeGallery];
    [self.navigationController pushViewController:galleryDetailsVC animated:YES];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapLocation:(UIButton *)button gallery:(PFObject *)gallery {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    PFGeoPoint *geoPoint = [gallery objectForKey:kFTPostLocationKey];
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            [mapViewController setInitialLocation: location];
    }
    
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

#pragma mark - FTVideoCellViewDelegate

- (void)videoCellView:(FTVideoCell *)videoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user{
    NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapUserButton:user:");
    // Push account view controller
    [profileViewController setUser:user];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)videoCellView:(FTVideoCell *)videoCellView didTapCommentOnVideoButton:(UIButton *)button video:(PFObject *)video {
    NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapCommentOnVideoButton:video:");
    FTPostDetailsViewController *photoDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:video AndType:kFTPostTypeVideo];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}

- (void)videoCellView:(FTVideoCell *)videoCellView didTapLikeVideoButton:(UIButton *)button counter:(UIButton *)counter video:(PFObject *)video {
    NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapLikeVideoButton:counter:video:");
    // Disable the button so users cannot send duplicate requests
    [videoCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [videoCellView setLikeStatus:liked];
    
    NSString *originalButtonTitle = counter.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:counter.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[FTCache sharedCache] incrementLikerCountForPost:video];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[FTCache sharedCache] decrementLikerCountForPost:video];
    }
    
    [[FTCache sharedCache] setPostIsLikedByCurrentUser:video liked:liked];
    
    [counter setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        
        [FTUtility likeVideoInBackground:video block:^(BOOL succeeded, NSError *error) {
            FTVideoCell *actualView = (FTVideoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:succeeded];
            
            if (!succeeded) {
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if (error) {
                NSLog(@"ERROR###: %@",error);
            }
        }];
        
    } else {
        
        [FTUtility unlikeVideoInBackground:video block:^(BOOL succeeded, NSError *error) {
            FTVideoCell *actualView = (FTVideoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if(error){
                NSLog(@"ERROR###: %@",error);
            }
        }];
    }
}

- (void)videoCellView:(FTVideoCell *)videoCellView didTapMoreButton:(UIButton *)button video:(PFObject *)video {
    NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapMoreButton:video:");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ReTag", @"Share on Facebook", @"Tweet", @"Report as Inappropriate",  nil];
    [actionSheet showInView:self.view];
}

- (void)videoCellView:(FTVideoCell *)videoCellView didTapLocation:(UIButton *)button video:(PFObject *)video {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    PFGeoPoint *geoPoint = [video objectForKey:kFTPostLocationKey];
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        [mapViewController setInitialLocation: location];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)videoCellView:(FTVideoCell *)videoCellView didTapVideoButton:(UIButton *)button {
    PFObject *video = [self.objects objectAtIndex:videoCellView.tag];
    if (video) {
        FTPostDetailsViewController *galleryDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:video AndType:kFTPostTypeVideo];
        [self.navigationController pushViewController:galleryDetailsVC animated:YES];
    }
}

#pragma mark - FTPhotoCellViewDelegate

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapUserButton:user:");
    // Push account view controller
    [profileViewController setUser:user];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLikePhotoButton:(UIButton *)button counter:(UIButton *)counter photo:(PFObject *)photo {
    NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapLikePhotoButton:photo:");
    //NSLog(@"FTPhotoTimelineViewController::Updating photoCellView:(FTPhotoCell *) %@ didTapLikePhotoButton:(UIButton *) %@ counter:(UIButton *) %@ photo:(PFObject *) %@",photoCellView,button,counter,photo);
    
	// Disable the button so users cannot send duplicate requests
    [photoCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [photoCellView setLikeStatus:liked];
    
    NSString *originalButtonTitle = counter.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:counter.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[FTCache sharedCache] incrementLikerCountForPost:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[FTCache sharedCache] decrementLikerCountForPost:photo];
    }
    
    
    [[FTCache sharedCache] setPostIsLikedByCurrentUser:photo liked:liked];
    
    [counter setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];

    if (liked) {
        [FTUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            FTPhotoCell *actualView = (FTPhotoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:succeeded];
            
            if (!succeeded) {
                //[actualView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if (error) {
                NSLog(@"ERROR###: %@",error);
            }
        }];
    } else {
        // warnParseOperationOnMainThread()
        [FTUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            FTPhotoCell *actualView = (FTPhotoCell *)[self tableView:self.tableView viewForHeaderInSection:counter.tag];
            [actualView shouldEnableLikeButton:YES];
            [actualView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                //[actualView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
                [actualView.likeCounter setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
            
            if(error){
                NSLog(@"ERROR###: %@",error);
            }
            
        }];
    }
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapCommentOnPhotoButton:photo:");
    FTPostDetailsViewController *postDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:photo AndType:kFTPostTypeVideo];
    [self.navigationController pushViewController:postDetailsVC animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapMoreButton:(UIButton *)button photo:(PFObject *)photo{
    NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapMoreButton:photo:");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ReTag", @"Share on Facebook", @"Tweet", @"Report as Inappropriate",  nil];
    [actionSheet showInView:self.view];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLocation:(UIButton *)button photo:(PFObject *)photo {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    PFGeoPoint *geoPoint = [photo objectForKey:kFTPostLocationKey];
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        [mapViewController setInitialLocation: location];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapPhotoButton:(UIButton *)button {
    PFObject *photo = [self.objects objectAtIndex:photoCellView.tag];
    if (photo) {
        FTPostDetailsViewController *postDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:photo AndType:kFTPostTypeVideo];
        [self.navigationController pushViewController:postDetailsVC animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    [[[UIAlertView alloc] initWithTitle:@"Disabled"
                                message:@"Hey! These controls have been disabled :("
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            [self loadNextPage];
        }
    }
}

#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    return nil;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    //NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)didTapOnPhotoAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:photo];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

- (void)didTapOnVideoAction:(UIButton *)sender {
    PFObject *video = [self.objects objectAtIndex:sender.tag];
    if (video) {
        FTPostDetailsViewController *galleryDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:video AndType:kFTPostTypeVideo];
        [self.navigationController pushViewController:galleryDetailsVC animated:YES];
    }
}
*/
@end
