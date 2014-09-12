//
//  FTPhotoTimelineViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPhotoTimelineViewController.h"
#import "FTAccountViewController.h"
#import "FTPhotoDetailsViewController.h"
#import "FTUtility.h"
#import "FTLoadMoreCell.h"

@interface FTPhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end
@implementation FTPhotoTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

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
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 0.0f, 0.0f)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
    }
    return 320.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
    
    NSLog(@"tableView:didSelectRowAtIndexPath:");
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:100];
        return query;
    }
     
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
    [followingActivitiesQuery whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeFollow];
    [followingActivitiesQuery whereKey:kFTActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 100;
    
    PFQuery *postsFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [postsFromFollowedUsersQuery whereKey:kFTPostUserKey matchesKey:kFTActivityToUserKey inQuery:followingActivitiesQuery];
    [postsFromFollowedUsersQuery whereKeyExists:kFTPostImageKey];
    
    PFQuery *postsFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [postsFromCurrentUserQuery whereKey:kFTPostUserKey equalTo:[PFUser currentUser]];
    [postsFromCurrentUserQuery whereKeyExists:kFTPostImageKey];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    BOOL isVideo = NO;
    if([object[@"type"] isEqualToString:@"video"]){
        isVideo = YES;
    } else if([object[@"type"] isEqualToString:@"image"]) {
        isVideo = NO;
    } else { // If type is undefined
        return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
    }
    
    //NSLog(@"FTPhotoTimelineViewController::Updating tableView:(UITableView *) %@ cellForRowAtIndexPath:(NSIndexPath *) %@ object:(PFObject *) %@",tableView,indexPath,object);
    if (indexPath.section == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    // If the cell is a video
    if (isVideo) {
        
        static NSString *videoCellIdentifier = @"VideoCell";
        FTVideoCell *videoCell = (FTVideoCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
        
        if (videoCell == nil) {
            videoCell = [[FTVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
            videoCell.delegate = self;
            [videoCell.videoButton addTarget:self action:@selector(didTapOnVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        PFObject *video = [self.objects objectAtIndex:indexPath.section];
        //NSLog(@"video: %@",video);
        [videoCell setVideo:video];
        videoCell.tag = indexPath.section;
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
                    PFQuery *query = [FTUtility queryForActivitiesOnVideo:video cachePolicy:kPFCachePolicyNetworkOnly];
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
                            
                            [[FTCache sharedCache] setAttributesForPost:video likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                            
                            if (videoCell.tag != indexPath.section) {
                                return;
                            }
                            
                            [videoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:video]];
                            [videoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:video] description] forState:UIControlStateNormal];
                            [videoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:video] description] forState:UIControlStateNormal];
                            [videoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:video] description] forState:UIControlStateNormal];
                        }
                    }];
                    
                }
            }
        }
        
        videoCell.videoButton.tag = indexPath.section;
        
        if (object) {
            videoCell.imageView.file = [object objectForKey:kFTPostImageKey];
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([videoCell.imageView.file isDataAvailable]) {
                [videoCell.imageView loadInBackground];
            }
        }
        
        return videoCell;
    }
    
    // If the cell is not a video
    if(!isVideo) {
        
        static NSString *photoCellIdentifier = @"PhotoCell";
        FTPhotoCell *photoCell = (FTPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];

        if (photoCell == nil) {
            photoCell = [[FTPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellIdentifier];
            photoCell.delegate = self;
            [photoCell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
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
                    PFQuery *query = [FTUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
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
                            
                            [[FTCache sharedCache] setAttributesForPost:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                            
                            if (photoCell.tag != indexPath.section) {
                                return;
                            }
                            
                            [photoCell setLikeStatus:[[FTCache sharedCache] isPostLikedByCurrentUser:photo]];
                            [photoCell.likeCounter setTitle:[[[FTCache sharedCache] likeCountForPost:photo] description] forState:UIControlStateNormal];
                            [photoCell.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:photo] description] forState:UIControlStateNormal];
                            [photoCell.usernameRibbon setTitle:[[[FTCache sharedCache] displayNameForPost:photo] description] forState:UIControlStateNormal];
                        }
                    }];
             
                }
            }
        }
        
        photoCell.photoButton.tag = indexPath.section;
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    FTLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[FTLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
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

#pragma mark - FTVideoCellViewDelegate

-(void)videoCellView:(FTVideoCell *)videoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user{
    FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

-(void)videoCellView:(FTVideoCell *)videoCellView didTapCommentOnVideoButton:(UIButton *)button video:(PFObject *)video{
    FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:video];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}

-(void)videoCellView:(FTVideoCell *)videoCellView didTapLikeVideoButton:(UIButton *)button counter:(UIButton *)counter video:(PFObject *)video{
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

-(void)videoCellView:(FTVideoCell *)videoCellView didTapMoreButton:(UIButton *)button video:(PFObject *)video{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ReTag", @"Share on Facebook", @"Tweet", @"Report as Inappropriate",  nil];
    [actionSheet showInView:self.view];
}

#pragma mark - FTPhotoCellViewDelegate

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapLikePhotoButton:(UIButton *)button counter:(UIButton *)counter photo:(PFObject *)photo {
    
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
    FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}

- (void)photoCellView:(FTPhotoCell *)photoCellView didTapMoreButton:(UIButton *)button photo:(PFObject *)photo{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ReTag", @"Share on Facebook", @"Tweet", @"Report as Inappropriate",  nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
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
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:video];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

@end
