//
//  FTTimelineViewController.m
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
#import "FTPlaceProfileViewController.h"
#import "FTViewFriendsViewController.h"

@interface FTTimelineViewController ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) UIBarButtonItem *dismissProfileButton;
@property (nonatomic, strong) PFObject *currentPostMoreOption;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) FTViewFriendsViewController *viewFriendsViewController;

@property CGRect originalFrame;
@property CGFloat previousScrollViewYOffset;

@end

@implementation FTTimelineViewController

@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize dismissProfileButton;
@synthesize moviePlayer;
@synthesize viewFriendsViewController;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPostDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPostDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTTimelineViewControllerUserDeletedPostNotification object:nil];
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
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    self.originalFrame = self.navigationController.navigationBar.frame;
    
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer setScalingMode:SCALINGMODE];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.width)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setUserInteractionEnabled:NO];
    [moviePlayer.view setAlpha:1];
    [moviePlayer.backgroundView setBackgroundColor:[UIColor clearColor]];
    
    for(UIView *aSubView in moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayer];
    
    // Override the back idnicator
    dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
    [dismissProfileButton setTintColor:[UIColor whiteColor]];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPost:) name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePost:) name:FTTimelineViewControllerUserDeletedPostNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePost:) name:FTPostDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:FTPostDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = YES;
        [self loadObjects];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (moviePlayer) {
        [moviePlayer stop];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //CGRect tmpFram = self.originalFrame;
    //tmpFram.origin.y = 20;
    //self.navigationController.navigationBar.frame = tmpFram;
    
    /*
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        NSString *className = NSStringFromClass([view class]);
        if (![className isEqualToString:@"_UINavigationBarBackground"] && ![className isEqualToString:@"_UINavigationBarBackIndicatorView"]) {
            view.alpha = 1;
        }
    }
    */
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
    followingActivitiesQuery.limit = 500;

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
    [query includeKey:kFTPostPlaceKey];
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

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 0;
    }
    return 380;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    FTPostHeaderView *postHeaderView = [self dequeueReusableSectionHeaderView];
    if (!postHeaderView) {
        postHeaderView = [[FTPostHeaderView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,44)];
        postHeaderView.delegate = self;
        [self.reusableSectionHeaderViews addObject:postHeaderView];
    }
    
    PFObject *post = [self.objects objectAtIndex:section];
    [postHeaderView setPost:post];
    [postHeaderView setDate:[post createdAt]];
    
    return postHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    
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
                            
                            [[FTCache sharedCache] setAttributesForPost:gallery likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                            [galleryCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:gallery]];
                            [galleryCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:gallery] description] forState:UIControlStateNormal];
                            [galleryCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:gallery] description] forState:UIControlStateNormal];
                        }
                    }];
                }
            }
        }
        
        
        galleryCell.galleryButton.tag = indexPath.section;
        galleryCell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
        
        if (object) {
            galleryCell.imageView.file = [object objectForKey:kFTPostImageKey];
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([galleryCell.imageView.file isDataAvailable]) {
                [galleryCell.imageView loadInBackground];
            }
        }
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
        [videoCell setVideo:video];
        [videoCell setTag:indexPath.section];
        [videoCell.likeCounter setTag:indexPath.section];
        
        NSDictionary *attributesForVideo = [[FTCache sharedCache] attributesForPost:video];
        
        if (attributesForVideo) {
            [videoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:video]];
            [videoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:video] description] forState:UIControlStateNormal];
            [videoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:video] description] forState:UIControlStateNormal];
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
                            
                            [[FTCache sharedCache] setAttributesForPost:video likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                            [videoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:video]];
                            [videoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:video] description] forState:UIControlStateNormal];
                            [videoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:video] description] forState:UIControlStateNormal];
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
                videoCell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            } else {
                
                if (videoCell.imageView.file && ![videoCell.imageView.file isEqual:[NSNull null]]) {
                    
                    [videoCell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            [videoCell.imageView loadInBackground];
                        } else {
                            NSLog(@"ERROR:%@",error);
                        }
                    }];
                }
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
                            
                            [[FTCache sharedCache] setAttributesForPost:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                            [photoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:photo]];
                            [photoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:photo] description] forState:UIControlStateNormal];
                            [photoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:photo] description] forState:UIControlStateNormal];
                        }
                    }];
                }
            }
        }
        
        photoCell.photoButton.tag = indexPath.section;
        photoCell.imageView.image = [UIImage imageNamed:PLACEHOLDER_LIGHTGRAY];
        
        if (object) {
            photoCell.imageView.file = [object objectForKey:kFTPostImageKey];
            // PFQTVC will take care of asynchronously downloading files, but will only
            // load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([photoCell.imageView.file isDataAvailable]) {
                //NSLog(@"data is available");
                [photoCell.imageView loadInBackground];
            } else {
                if (photoCell.imageView.file && ![photoCell.imageView.file isEqual:[NSNull null]]) {
                    [photoCell.imageView.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            [photoCell.imageView loadInBackground];
                        } else {
                            NSLog(@"ERROR:%@",error);
                        }
                    }];
                }
            }
        }
        
        return photoCell;
    }
    
    return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

#pragma mark - FTPhotoTimelineViewController

- (FTPostHeaderView *)dequeueReusableSectionHeaderView {
    for (FTPostHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}

#pragma mark - FTGalleryCellViewDelegate

- (void)galleryCellView:(FTGalleryCell *)galleryCellView
didTapLikeGalleryButton:(UIButton *)button
                counter:(UIButton *)counter
                gallery:(PFObject *)gallery {
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLikeGalleryButton:counter:gallery:");
    
    //NSLog(@"FTPhotoTimelineViewController::Updating photoCellView:(FTPhotoCell *) %@ didTapLikePhotoButton:(UIButton *) %@ counter:(UIButton *) %@ photo:(PFObject *) %@",photoCellView,button,counter,photo);
    
    // Disable the button so users cannot send duplicate requests
    [galleryCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [galleryCellView setLikeStatus:liked];
    
    //NSString *originalButtonTitle = counter.titleLabel.text;
    
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
            if (error) {
                NSLog(@"ERROR#: %@",error);
            }
        }];
    } else {
        [FTUtility unlikePhotoInBackground:gallery block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"ERROR#: %@",error);
            }
        }];
    }
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapCommentOnGalleryButton:(UIButton *)button
                gallery:(PFObject *)gallery {
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapCommentOnGalleryButton:gallery:");
    FTPostDetailsViewController *photoDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:gallery AndType:kFTPostTypeGallery];
    [self.navigationController pushViewController:photoDetailsVC animated:NO];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView
       didTapMoreButton:(UIButton *)button
                gallery:(PFObject *)gallery{
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapImageInGalleryAction:gallery:");
    [self actionSheetAlert:gallery];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView didTapImageInGalleryAction:(UIButton *)button
                gallery:(PFObject *)gallery
{
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapImageInGalleryAction:gallery:");
    FTPostDetailsViewController *galleryDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:gallery AndType:kFTPostTypeGallery];
    [self.navigationController pushViewController:galleryDetailsVC animated:NO];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView
         didTapLocation:(UIButton *)button
                gallery:(PFObject *)gallery {
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    if ([gallery objectForKey:kFTPostLocationKey]) {
        [mapViewController setInitialLocationObject:gallery];
        [mapViewController setSkipAnimation:YES];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)galleryCellView:(FTGalleryCell *)galleryCellView
  didTapLikeCountButton:(UIButton *)button
                gallery:(PFObject *)gallery {
    
    //NSLog(@"galleryCellView:didTapLikeCountButton:gallery:");
    [self viewFriendsViewControllerWith:gallery counter:button];
}

#pragma mark - FTVideoCellViewDelegate

- (void)videoCellView:(FTVideoCell *)videoCellView didTapCommentOnVideoButton:(UIButton *)button
                video:(PFObject *)video {
    //NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapCommentOnVideoButton:video:");
    FTPostDetailsViewController *photoDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:video AndType:kFTPostTypeVideo];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}

- (void)videoCellView:(FTVideoCell *)videoCellView
didTapLikeVideoButton:(UIButton *)button
              counter:(UIButton *)counter
                video:(PFObject *)video {
    //NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapLikeVideoButton:counter:video:");
    // Disable the button so users cannot send duplicate requests
    [videoCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [videoCellView setLikeStatus:liked];
    
    //NSString *originalButtonTitle = counter.titleLabel.text;
    
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
            if (error) {
                NSLog(@"ERROR###: %@",error);
            }
        }];
        
    } else {
        [FTUtility unlikeVideoInBackground:video block:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"ERROR###: %@",error);
            }
        }];
    }
}

- (void)videoCellView:(FTVideoCell *)videoCellView
     didTapMoreButton:(UIButton *)button
                video:(PFObject *)video {
    
    //NSLog(@"FTPhotoTimelineViewController::videoCellView:didTapMoreButton:video:");
    [self actionSheetAlert:video];
}

- (void)videoCellView:(FTVideoCell *)videoCellView
       didTapLocation:(UIButton *)button
                video:(PFObject *)video {
    
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    if ([video objectForKey:kFTPostLocationKey]) {
        [mapViewController setInitialLocationObject:video];
        [mapViewController setSkipAnimation:YES];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)videoCellView:(FTVideoCell *)videoCellView
    didTapVideoButton:(UIButton *)button {
    PFObject *video = [self.objects objectAtIndex:videoCellView.tag];
    if (video) {
        FTPostDetailsViewController *galleryDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:video AndType:kFTPostTypeVideo];
        [self.navigationController pushViewController:galleryDetailsVC animated:NO];
    }
}

- (void)videoCellView:(FTVideoCell *)videoCellView
didTapVideoPlayButton:(UIButton *)button
                video:(PFObject *)video {
    
    [FTUtility showHudMessage:@"loading.." WithDuration:1];
    
    //NSLog(@"videoCellView:didTapVideoPlayButton:video:");
    PFFile *videoFile = [video objectForKey:kFTPostVideoKey];
    
    [moviePlayer setContentURL:[NSURL URLWithString:videoFile.url]];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
    [videoCellView addSubview:moviePlayer.view];
    [videoCellView bringSubviewToFront:moviePlayer.view];
}

- (void)videoCellView:(FTVideoCell *)videoCellView
didTapLikeCountButton:(UIButton *)button
                video:(PFObject *)video{
    
    //NSLog(@"videoCellView::didTapLikeCountButton:video:");
    [self viewFriendsViewControllerWith:video counter:button];
}

#pragma mark - FTPhotoCellViewDelegate

- (void)photoCellView:(FTPhotoCell *)photoCellView
didTapLikePhotoButton:(UIButton *)button
              counter:(UIButton *)counter
                photo:(PFObject *)photo {
    //NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapLikePhotoButton:photo:");
    //NSLog(@"FTPhotoTimelineViewController::Updating photoCellView:(FTPhotoCell *) %@ didTapLikePhotoButton:(UIButton *) %@ counter:(UIButton *) %@ photo:(PFObject *) %@",photoCellView,button,counter,photo);
    
	// Disable the button so users cannot send duplicate requests
    [photoCellView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [photoCellView setLikeStatus:liked];
    
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
            if (error) {
                NSLog(@"%@::likePhotoInBackground",ERROR_MESSAGE);
            }
        }];
    } else {
        // warnParseOperationOnMainThread()
        [FTUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@::unlikePhotoInBackground",ERROR_MESSAGE);
            }
        }];
    }
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapCommentOnPhotoButton:(UIButton *)button
                photo:(PFObject *)photo {
    //NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapCommentOnPhotoButton:photo:");
    FTPostDetailsViewController *postDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:photo AndType:kFTPostTypeVideo];
    [self.navigationController pushViewController:postDetailsVC animated:NO];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView
     didTapMoreButton:(UIButton *)button
                photo:(PFObject *)photo {
    //NSLog(@"FTPhotoTimelineViewController::photoCellView:didTapMoreButton:photo:");
    [self actionSheetAlert:photo];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView
       didTapLocation:(UIButton *)button
                photo:(PFObject *)photo {
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    if ([photo objectForKey:kFTPostLocationKey]) {
        [mapViewController setInitialLocationObject:photo];
        [mapViewController setSkipAnimation:YES];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView
    didTapPhotoButton:(UIButton *)button {
    PFObject *photo = [self.objects objectAtIndex:photoCellView.tag];
    if (photo) {
        FTPostDetailsViewController *postDetailsVC = [[FTPostDetailsViewController alloc] initWithPost:photo AndType:kFTPostTypeVideo];
        [self.navigationController pushViewController:postDetailsVC animated:NO];
    }
}

- (void)photoCellView:(FTPhotoCell *)photoCellView
didTapLikeCountButton:(UIButton *)button
                photo:(PFObject *)photo {
    
    //NSLog(@"photoCellView::didTapLikeCountButton:photo:");
    [self viewFriendsViewControllerWith:photo counter:button];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (!self.currentPostMoreOption) {
        [[[UIAlertView alloc] initWithTitle:@"Post Error"
                                    message:@"There was a problem with this post."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_SHARE_ON_FACEBOOK]) {
        //NSLog(@"didTapFacebookShareButtonAction");
        // Check that the user account is linked
        //[FTUtility prepareToSharePostOnFacebook:self.currentPostMoreOption];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_SHARE_ON_TWITTER]) {
        [FTUtility prepareToSharePostOnTwitter:self.currentPostMoreOption];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_REPORT_INAPPROPRIATE]) {
        [self reportPostInappropriate:self.currentPostMoreOption];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_DELETE_POST]) {
        [[[UIAlertView alloc] initWithTitle:ACTION_DELETE_POST
                                    message:@"Are you sure you want to delete this post?"
                                   delegate:self
                          cancelButtonTitle:@"no"
                          otherButtonTitles:@"delete", nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"delete"]) {
        
        // Delete all activites related to this photo
        PFQuery *query = [PFQuery queryWithClassName:kFTActivityClassKey];
        [query whereKey:kFTActivityPostKey equalTo:self.currentPostMoreOption];
        [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
            if (!error) {
                for (PFObject *activity in activities) {
                    [activity deleteEventually];
                }
            }
            
            // Delete post
            [self.currentPostMoreOption deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTTimelineViewControllerUserDeletedPostNotification object:[self.currentPostMoreOption objectId]];
                }
            }];
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //scrollView.bounces = NO;
    if (scrollView.contentSize.height - scrollView.contentOffset.y + 40 < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            [self loadNextPage];
        }
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    scrollView.contentInset = UIEdgeInsetsMake(frame.origin.y+44, 0, frame.origin.y+68, 0);
    //[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height+frame.origin.y+44)];
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
    
    if (scrollView.contentSize.height - scrollView.contentOffset.y + 100 < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            [self loadNextPage];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling {
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha {
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        NSString *className = NSStringFromClass([view class]);
        
        if (![className isEqualToString:@"_UINavigationBarBackground"] && ![className isEqualToString:@"_UINavigationBarBackIndicatorView"]) {
            view.alpha = alpha;
        }
    }
}

- (void)animateNavBarTo:(CGFloat)y {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}
*/

#pragma mark - UIHeaderViewDelegate

- (void)postHeaderView:(FTPostHeaderView *)postHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    
    NSString *userType = [user objectForKey:kFTUserTypeKey];    
    
    if ([userType isEqualToString:kFTUserTypeBusiness]) {
        
        FTPlaceProfileViewController *placeViewController = [[FTPlaceProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [placeViewController setContact:user];
        
        [self.navigationController pushViewController:placeViewController animated:YES];
        
    } else if ([userType isEqualToString:kFTUserTypeUser]) {
        // Go to selected user profile
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setMinimumLineSpacing:0];
        [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
        
        FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
        [profileViewController setUser:user];
        [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
        
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - ()

- (void)viewFriendsViewControllerWith:(PFObject *)object counter:(UIButton *)counter {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCount = [numberFormatter numberFromString:counter.titleLabel.text];

    if ([likeCount integerValue] > 0) {
        UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
        [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
        [backIndicator setStyle:UIBarButtonItemStylePlain];
        [backIndicator setTarget:self];
        [backIndicator setAction:@selector(didTapBackButtonAction:)];
        [backIndicator setTintColor:[UIColor whiteColor]];
        
        viewFriendsViewController = [[FTViewFriendsViewController alloc] init];
        [viewFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
        [viewFriendsViewController setUser:[PFUser currentUser]];
        [viewFriendsViewController queryForLickersOf:object];
        
        [self.navigationController pushViewController:viewFriendsViewController animated:YES];
    }
}

- (void)movieFinishedCallBack:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
}

- (void)loadStateDidChange:(NSNotification *)notification {
    //NSLog(@"loadStateDidChange: %@",notification);
    switch (moviePlayer.loadState) {
        case MPMovieLoadStatePlayable: {
            //NSLog(@"moviePlayer... MPMovieLoadStatePlayable");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMovieLoadStatePlaythroughOK: {
            //NSLog(@"moviePlayer... MPMovieLoadStatePlaythroughOK");
        }
            break;
        case MPMovieLoadStateStalled: {
            //NSLog(@"moviePlayer... MPMovieLoadStateStalled");
        }
            break;
        case MPMovieLoadStateUnknown: {
            //NSLog(@"moviePlayer... MPMovieLoadStateUnknown");
        }
            break;
        default:
            break;
    }
}

- (void)moviePlayerStateChange:(NSNotification *)notification {
    //NSLog(@"moviePlayerStateChange: %@",notification);
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateStopped");
        }
            break;
        case MPMoviePlaybackStatePlaying: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePlaying");
            [UIView animateWithDuration:1 animations:^{
                [moviePlayer.view setAlpha:1];
            }];
        }
            break;
        case MPMoviePlaybackStatePaused: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStatePaused");
            [UIView animateWithDuration:0.3 animations:^{
                [moviePlayer.view setAlpha:0];
                [moviePlayer prepareToPlay];
            }];
        }
            break;
        case MPMoviePlaybackStateInterrupted: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateInterrupted");
        }
            break;
        case MPMoviePlaybackStateSeekingForward: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingForward");
        }
            break;
        case MPMoviePlaybackStateSeekingBackward: {
            //NSLog(@"moviePlayer... MPMoviePlaybackStateSeekingBackward");            
        }
            break;
        default:
            break;
    }
}

- (void)actionSheetAlert:(PFObject *)post {
    
    self.currentPostMoreOption = nil;
    self.currentPostMoreOption = post;
    
    PFUser *currentUser = [PFUser currentUser];
    PFUser *postUser = [post objectForKey:kFTPostUserKey];
    
    UIActionSheet *actionSheet = nil;
    
    if ([currentUser.objectId isEqualToString:postUser.objectId]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:/*ACTION_SHARE_ON_FACEBOOK,*/
                                                           ACTION_SHARE_ON_TWITTER,
                                                           ACTION_REPORT_INAPPROPRIATE,
                                                           ACTION_DELETE_POST, nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:/*ACTION_SHARE_ON_FACEBOOK,*/
                                                           ACTION_SHARE_ON_TWITTER,
                                                           ACTION_REPORT_INAPPROPRIATE, nil];
    }
    [actionSheet showInView:self.view];
}

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    return nil;
}

- (void)userDidLikeOrUnlikePost:(NSNotification *)note {
    [self loadObjects];
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePost:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
        [FTUtility showHudMessage:@"post deleted" WithDuration:2];
    });
}

- (void)userDidPublishPost:(NSNotification *)note {
    [FTUtility showHudMessage:@"post uploaded" WithDuration:1];
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    //NSLog(@"FTTimelineViewController::userFollowingChanged:");
    self.shouldReloadOnAppear = YES;
    [self loadObjects];
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reportPostInappropriate:(PFObject *)post {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setMailComposeDelegate:self];
        [mailer setSubject:[NSString stringWithFormat:@"%@: %@",MAIL_INAPPROPRIATE_SUBJECT,post.objectId]];
        [mailer setToRecipients:[NSArray arrayWithObjects:MAIL_TECH_EMAIL, nil]];
        [mailer setMessageBody:EMPTY_STRING isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:MAIL_FAIL
                                    message:MAIL_NOT_SUPPORTED
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled:
            //NSLog(MAIL_CANCELLED);
            break;
        case MFMailComposeResultSaved:
            //NSLog(MAIL_SAVED);
            break;
        case MFMailComposeResultSent:
            //NSLog(MAIL_SENT);
            [FTUtility showHudMessage:MAIL_SENT WithDuration:2];
            break;
        default:
            //NSLog(MAIL_FAIL);
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
