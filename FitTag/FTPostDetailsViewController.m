//
//  FTPostDetailViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 10/4/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsViewController.h"
#import "FTBaseTextCell.h"
#import "FTActivityCell.h"
#import "FTConstants.h"
#import "FTUserProfileViewController.h"
#import "FTLoadMoreCell.h"
#import "FTUtility.h"
#import "MBProgressHUD.h"
#import "FTCamViewController.h"
#import "FTMapViewController.h"

@interface FTPostDetailsViewController()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *commentSendButton;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) UIBarButtonItem *dismissProfileButton;

/* Header Views */
@property (nonatomic, strong) FTPostDetailsHeaderView *headerView;
@property (nonatomic, strong) FTPhotoDetailsFooterView *footerView;

@property (nonatomic, strong) FTUserProfileViewController *profileViewController;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

static const CGFloat kFTCellInsetWidth = 0.0f;

@implementation FTPostDetailsViewController
@synthesize commentTextField;
@synthesize commentSendButton;
@synthesize headerView;
@synthesize footerView;
@synthesize post;
@synthesize dismissProfileButton;
@synthesize profileViewController;
@synthesize flowLayout;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.post];
}

- (id)initWithPost:(PFObject* )aPost AndType:(NSString *)aType {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kFTActivityClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
        self.post = aPost;
        self.type = aType;
        
        self.likersQueryInProgress = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NAVIGATION_TITLE_COMMENT];
    
    // Override the back idnicator
    dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapPopProfileButtonAction:)];
    [dismissProfileButton setTintColor:[UIColor whiteColor]];
    
    // Override the back idnicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Profile view layout
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(105.5,105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0.0f,0.0f,0.0f,0.0f)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(320,335)];
    
    profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    // Load Camera
    UIBarButtonItem *loadCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_CAMERA]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(loadCamera:)];
    [loadCamera setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:loadCamera];

    self.headerView = [[FTPostDetailsHeaderView alloc] initWithFrame:[FTPostDetailsHeaderView rectForView]
                                                                post:self.post type:self.type];
    self.headerView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    footerView = [[FTPhotoDetailsFooterView alloc] initWithFrame:[FTPhotoDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    commentSendButton = footerView.commentSendButton;
    commentTextField.delegate = self;
    footerView.delegate = self;
    
    self.tableView.tableFooterView = footerView;
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.post];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[FTCache sharedCache] attributesForPost:self.post] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kFTActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kFTActivityFromUserKey];
            
            NSString *nameString = EMPTY_STRING;
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kFTUserDisplayNameKey];
            }
            
            return [FTActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kFTCellInsetWidth];
        }
    }
    
    // The pagination row
    return 44.0f;
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kFTActivityPostKey equalTo:self.post];
    [query includeKey:kFTActivityFromUserKey];
    [query whereKey:kFTActivityTypeKey equalTo:kFTActivityTypeComment];
    [query orderByAscending:@"createdAt"];
    
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

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";
    
    // Try to dequeue a cell and create one if necessary
    FTBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[FTBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kFTCellInsetWidth;
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:kFTActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kFTActivityContentKey]];
    [cell setDate:[object createdAt]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    FTLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FTLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.post objectForKey:kFTPostUserKey]) {
        [commentSendButton setEnabled:YES];
    } else {
        [commentSendButton setEnabled:NO];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.post objectForKey:kFTPostUserKey]) {
        [commentSendButton setEnabled:YES];
    } else {
        [commentSendButton setEnabled:NO];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.post objectForKey:kFTPostUserKey]) {
        [commentSendButton setEnabled:YES];
    } else {
        [commentSendButton setEnabled:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.post objectForKey:kFTPostUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
        [comment setObject:trimmedComment forKey:kFTActivityContentKey]; // Set comment text
        [comment setObject:[self.post objectForKey:kFTPostUserKey] forKey:kFTActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey]; // Set fromUser
        [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
        [comment setObject:self.post forKey:kFTActivityPostKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.post objectForKey:kFTPostUserKey]];
        comment.ACL = ACL;
        
        [[FTCache sharedCache] incrementCommentCountForPost:self.post];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                [[FTCache sharedCache] decrementCommentCountForPost:self.post];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil)
                                                                message:NSLocalizedString(@"This photo is no longer available", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification
                                                                object:self.post
                                                              userInfo:@{@"comments": @(self.objects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    } else {
        [commentSendButton setEnabled:NO];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}

#pragma mark - FTBaseTextCellDelegate

- (void)cell:(FTBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}

#pragma mark - FTPostDetailsHeaderViewDelegate

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapImageInGalleryAction:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView didTapLocation:(UIButton *)button post:(PFObject *)aPost {
    NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    PFGeoPoint *geoPoint = [aPost objectForKey:kFTPostLocationKey];
    if (geoPoint) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        [mapViewController setInitialLocation: location];
    }
    
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

#pragma mark - FTPhotoDetailsFooterViewDelegate

- (void)photoDetailsFooterView:(FTPhotoDetailsFooterView *)footerView didTapSendButton:(UIButton *)button {
    //NSLog(@"%@::photoDetailsFooterView:didTapSendButtonAction:",CONTROLLER);
    [self textFieldShouldReturn:commentTextField];
}

#pragma mark - ()

- (void)loadCamera:(id)sender {
    FTCamViewController *cameraViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapPopProfileButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)showShareSheet {
    [[self.post objectForKey:kFTPostImageKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
            
            // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
            if ([[[PFUser currentUser] objectId] isEqualToString:[[self.post objectForKey:kFTPostUserKey] objectId]] && [self.objects count] > 0) {
                PFObject *firstActivity = self.objects[0];
                if ([[[firstActivity objectForKey:kFTActivityFromUserKey] objectId] isEqualToString:[[self.post objectForKey:kFTPostUserKey] objectId]]) {
                    NSString *commentString = [firstActivity objectForKey:kFTActivityContentKey];
                    [activityItems addObject:commentString];
                }
            }
            
            [activityItems addObject:[UIImage imageWithData:data]];
            [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://anypic.org/#pic/%@", self.post.objectId]]];
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }];
}
*/

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil)
                                message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil] show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    // Push account view controller
    [profileViewController setUser:user];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }
    
    self.likersQueryInProgress = YES;
    PFQuery *query = [FTUtility queryForActivitiesOnPost:post cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
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
        
        [[post objectForKey:kFTPostUserKey] fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            if (!error) {
                [[FTCache sharedCache] setAttributesForPost:post
                                                     likers:likers
                                                 commenters:commenters
                                         likedByCurrentUser:isLikedByCurrentUser
                                                displayName:[user objectForKey:kFTUserDisplayNameKey]];
            } else {
                NSLog(@"ERROR##: %@",error);
            }
        }];

        [self.headerView.commentCounter setTitle:[[[FTCache sharedCache] commentCountForPost:post] description] forState:UIControlStateNormal];
        [self.headerView reloadLikeBar];
    }];
}

- (BOOL)currentUserOwnsPhoto {
    return [[[self.post objectForKey:kFTPostUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kFTActivityClassKey];
    [query whereKey:kFTActivityPostKey equalTo:self.post];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.post deleteEventually];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.post objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
