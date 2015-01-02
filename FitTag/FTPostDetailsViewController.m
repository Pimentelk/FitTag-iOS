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
#import "FTBusinessProfileViewController.h"
#import "FTLoadMoreCell.h"
#import "FTUtility.h"
#import "FTCamViewController.h"
#import "FTMapViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTSearchViewController.h"
#import "FTViewFriendsViewController.h"

@interface FTPostDetailsViewController()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *commentSendButton;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) UIBarButtonItem *dismissProfileButton;

/* Header Views */
@property (nonatomic, strong) FTPostDetailsHeaderView *headerView;
@property (nonatomic, strong) FTPhotoDetailsFooterView *footerView;

@property (nonatomic, strong) FTBusinessProfileViewController *businessProfileViewController;
@property (nonatomic, strong) FTUserProfileViewController *userProfileViewController;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *businessFlowLayout;

@property (nonatomic, strong) FTSearchViewController *searchViewController;

@property (nonatomic, strong) FTSuggestionTableView *suggestionTableView;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@end

static const CGFloat kFTCellInsetWidth = 10.0f;

@implementation FTPostDetailsViewController
@synthesize commentTextField;
@synthesize commentSendButton;
@synthesize headerView;
@synthesize footerView;
@synthesize post;
@synthesize dismissProfileButton;
@synthesize userProfileViewController;
@synthesize businessProfileViewController;
@synthesize flowLayout;
@synthesize businessFlowLayout;
@synthesize searchViewController;
@synthesize suggestionTableView;
@synthesize cancelButton;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.post];
}

- (id)initWithPost:(PFObject *)aPost AndType:(NSString *)aType {
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
        
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationItem setTitle:NAVIGATION_TITLE_COMMENT];
        
    // Cancel button
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapcancelButtonAction:)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    
    // Override the back idnicator
    dismissProfileButton = [[UIBarButtonItem alloc] init];
    [dismissProfileButton setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [dismissProfileButton setStyle:UIBarButtonItemStylePlain];
    [dismissProfileButton setTarget:self];
    [dismissProfileButton setAction:@selector(didTapBackButtonAction:)];
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
    [flowLayout setItemSize:CGSizeMake(self.view.frame.size.width/3, 105)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT)];
    
    businessFlowLayout = flowLayout;
    [businessFlowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
    
    userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    businessProfileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:businessFlowLayout];
    
    // Init search view controller
    searchViewController = [[FTSearchViewController alloc] init];
    
    // Header view
    self.headerView = [[FTPostDetailsHeaderView alloc] initWithFrame:[FTPostDetailsHeaderView rectForView] post:self.post type:self.type];
    
    NSString *caption = [self.post objectForKey:kFTPostCaptionKey];
    CGRect headerRect = self.headerView.frame;
    if (caption) {
        CGFloat height = [FTUtility findHeightForText:caption havingWidth:self.view.frame.size.width AndFont:SYSTEMFONTBOLD(14)];
        headerRect.size.height += height + 15;
        [self.headerView setFrame:headerRect];
    }
    
    CGRect footerRect = [FTPhotoDetailsFooterView rectForView];
    footerRect.origin.y = headerRect.size.height + headerRect.origin.y;
    
    // Footer view
    footerView = [[FTPhotoDetailsFooterView alloc] initWithFrame:footerRect];
    commentTextField = footerView.commentField;
    commentSendButton = footerView.commentSendButton;
    commentTextField.delegate = self;
    footerView.delegate = self;
    
    self.headerView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:)
                                                 name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.post];
    
    suggestionTableView = [[FTSuggestionTableView alloc] initWithFrame:CGRectMake(0, 150, 320, 150) style:UITableViewStylePlain];
    [suggestionTableView setBackgroundColor:[UIColor whiteColor]];
    [suggestionTableView setSuggestionDelegate:self];
    [suggestionTableView setAlpha:0];
    
    [self.view addSubview:suggestionTableView];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.headerView moviePlayer]) {
        [[self.headerView moviePlayer] stop];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView] && indexPath.row < self.objects.count) { // A comment row
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
    //NSLog(@"objectsDidLoad:%@",error);
    [super objectsDidLoad:error];
    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *BaseTextCell = @"CommentCell";
    
    // Try to dequeue a cell and create one if necessary
    FTBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseTextCell];
    if (cell == nil) {
        cell = [[FTBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BaseTextCell];
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
    
    NSLog(@"stuff:%f",self.tableView.contentOffset.y);
    
    CGRect tableViewRect = CGRectMake(0, self.footerView.frame.origin.y-210, self.tableView.frame.size.width, 210);
    [suggestionTableView setFrame:tableViewRect];
    [suggestionTableView setAlpha:0];
    [self.navigationItem setRightBarButtonItem:cancelButton];
    
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.post objectForKey:kFTPostUserKey]) {
        [commentSendButton setEnabled:YES];
    } else {
        [commentSendButton setEnabled:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self.view bringSubviewToFront:suggestionTableView];
    
    NSArray *mentionRanges = [FTUtility rangesOfMentionsInString:textField.text];
    NSArray *hashtagRanges = [FTUtility rangesOfHashtagsInString:textField.text];
    
    NSTextCheckingResult *currentMention;
    NSTextCheckingResult *currentHashtag;
    
    if (mentionRanges.count > 0) {
        for (int i = 0; i < [mentionRanges count]; i++) {
            
            NSTextCheckingResult *mention = [mentionRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingMentionRange = NSMakeRange(mention.range.location, mention.range.length + 1);

            if (NSLocationInRange(range.location, currentlyTypingMentionRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentMention = mention;
            }
        }
    }
    
    if (hashtagRanges.count > 0) {
        for (int i = 0; i < [hashtagRanges count]; i++) {
            
            NSTextCheckingResult *hashtag = [hashtagRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingHashtagRange = NSMakeRange(hashtag.range.location, hashtag.range.length + 1);
            
            if (NSLocationInRange(range.location, currentlyTypingHashtagRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentHashtag = hashtag;
            }
        }
    }
    
    if (currentMention){
        
        // Disable scrolling to prevent interfearance with controller
        [self.tableView setScrollEnabled:NO];
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_USERS];
        
        NSString *text = [[textField.text substringWithRange:currentMention.range] stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING];
        text = [text stringByAppendingString:string];
        
        if (text.length > 0) {
            
            NSLog(@"text:%@",text);
            NSLog(@"string:%@",string);
            NSLog(@"textField.text:%@",textField.text);
            
            [suggestionTableView updateSuggestionWithText:text AndType:SUGGESTION_TYPE_USERS];
        }
        
    } else if (currentHashtag){
        
        // Disable scrolling to prevent interfearance with controller
        [self.tableView setScrollEnabled:NO];
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_HASHTAGS];
        
        NSString *text = [[textField.text substringWithRange:currentHashtag.range] stringByReplacingOccurrencesOfString:@"#" withString:EMPTY_STRING];
        text = [text stringByAppendingString:string];
        
        if (text.length > 0) {
            [suggestionTableView updateSuggestionWithText:text AndType:SUGGESTION_TYPE_HASHTAGS];
        }
        
    } else {
        //NSLog(@"Not showing auto complete...");
        [self.tableView setScrollEnabled:YES];
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:0];
        }];
    }
    
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
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[FTUtility extractHashtagsFromText:trimmedComment]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[FTUtility extractMentionsFromText:trimmedComment]];
        
        PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
        [comment setObject:trimmedComment forKey:kFTActivityContentKey]; // Set comment text
        [comment setObject:[self.post objectForKey:kFTPostUserKey] forKey:kFTActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey]; // Set fromUser
        [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
        [comment setObject:self.post forKey:kFTActivityPostKey];
        [comment setObject:hashtags forKey:kFTActivityHashtagKey];
        [comment setObject:mentions forKey:kFTActivityMentionKey];
        
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FTPostDetailsViewControllerUserCommentedOnPhotoNotification
                                                                object:self.post
                                                              userInfo:@{@"comments": @(self.objects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    } else {
        [commentSendButton setEnabled:NO];
    }
    
    [textField setText:EMPTY_STRING];
    [suggestionTableView setAlpha:0];
    
    [self.tableView setScrollEnabled:YES];
    [self.navigationItem setRightBarButtonItem:nil];
    
    return [textField resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
    [self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - FTBaseTextCellDelegate

- (void)cell:(FTBaseTextCell *)cellView didTapHashTag:(NSString *)hashTag {
    if (searchViewController) {
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:hashTag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (void)cell:(FTBaseTextCell *)cellView didTapUserMention:(NSString *)mention {
    
    NSString *lowercaseStringWithoutSymbols = [FTUtility getLowercaseStringWithoutSymbols:mention];
    
    //****** Display Name ********//
    PFQuery *queryStringMatchHandle = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryStringMatchHandle whereKeyExists:kFTUserDisplayNameKey];
    [queryStringMatchHandle whereKey:kFTUserDisplayNameKey equalTo:lowercaseStringWithoutSymbols];
    [queryStringMatchHandle findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            
            //NSLog(@"users:%@",users);
            //NSLog(@"users.count:%lu",(unsigned long)users.count);
            
            if (users.count == 1) {
                
                PFUser *mentionedUser = [users objectAtIndex:0];
                NSLog(@"mentionedUser:%@",mentionedUser);
                
                if ([mentionedUser objectForKey:kFTUserTypeBusiness]) {
                    
                    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
                    
                    businessProfileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:businessFlowLayout];
                    [businessProfileViewController setBusiness:mentionedUser];
                    [businessProfileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
                    [self.navigationController pushViewController:businessProfileViewController animated:YES];
                } else {
                    userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
                    [userProfileViewController setUser:mentionedUser];
                    [userProfileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
                    [self.navigationController pushViewController:userProfileViewController animated:YES];
                }
                
            } else {
                
                UIBarButtonItem *backIndicatorButtonItem = [[UIBarButtonItem alloc] init];
                [backIndicatorButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
                [backIndicatorButtonItem setStyle:UIBarButtonItemStylePlain];
                [backIndicatorButtonItem setTarget:self];
                [backIndicatorButtonItem setAction:@selector(didTapMentionBackButtonAction:)];
                [backIndicatorButtonItem setTintColor:[UIColor whiteColor]];
                
                FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
                
                UINavigationController *followFriendsNavController = [[UINavigationController alloc] init];
                [followFriendsNavController setViewControllers:@[ followFriendsViewController ] animated:NO];
                [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicatorButtonItem];
                
                [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
                [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
                [followFriendsViewController querySearchForUser];
                
                [self presentViewController:followFriendsNavController animated:YES completion:nil];
                
            }
        }
    }];
}

- (void)cell:(FTBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    //NSLog(@"%@::didTapUserButton:",VIEWCONTROLLER_ACTIVITY);
    // Push user profile
    FTUserProfileViewController *profileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
    [profileViewController setUser:aUser];
    [profileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)didTapMentionBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - FTPostDetailsHeaderViewDelegate

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
                didTapHashTag:(NSString *)hashTag {
    if (searchViewController) {
        [searchViewController setSearchQueryType:FTSearchQueryTypeFitTag];
        [searchViewController setSearchString:hashTag];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
            didTapUserMention:(NSString *)mention {
    NSString *lowercaseStringWithoutSymbols = [FTUtility getLowercaseStringWithoutSymbols:mention];
    
    //****** Display Name ********//
    PFQuery *queryStringMatchHandle = [PFQuery queryWithClassName:kFTUserClassKey];
    [queryStringMatchHandle whereKeyExists:kFTUserDisplayNameKey];
    [queryStringMatchHandle whereKey:kFTUserDisplayNameKey equalTo:lowercaseStringWithoutSymbols];
    [queryStringMatchHandle findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            
            //NSLog(@"users:%@",users);
            //NSLog(@"users.count:%lu",(unsigned long)users.count);
            
            if (users.count == 1) {
                
                PFUser *mentionedUser = [users objectAtIndex:0];
                //NSLog(@"mentionedUser:%@",mentionedUser);
                
                if ([mentionedUser objectForKey:kFTUserTypeBusiness]) {
                    businessProfileViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:businessFlowLayout];
                    [businessProfileViewController setBusiness:mentionedUser];
                    [businessProfileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
                    [self.navigationController pushViewController:businessProfileViewController animated:YES];
                } else {
                    userProfileViewController = [[FTUserProfileViewController alloc] initWithCollectionViewLayout:flowLayout];
                    [userProfileViewController setUser:mentionedUser];
                    [userProfileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
                    [self.navigationController pushViewController:userProfileViewController animated:YES];
                }
                
            } else {
                
                UIBarButtonItem *backIndicatorButtonItem = [[UIBarButtonItem alloc] init];
                [backIndicatorButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
                [backIndicatorButtonItem setStyle:UIBarButtonItemStylePlain];
                [backIndicatorButtonItem setTarget:self];
                [backIndicatorButtonItem setAction:@selector(didTapMentionBackButtonAction:)];
                [backIndicatorButtonItem setTintColor:[UIColor whiteColor]];
                
                FTFollowFriendsViewController *followFriendsViewController = [[FTFollowFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
                
                UINavigationController *followFriendsNavController = [[UINavigationController alloc] init];
                [followFriendsNavController setViewControllers:@[ followFriendsViewController ] animated:NO];
                [followFriendsViewController.navigationItem setLeftBarButtonItem:backIndicatorButtonItem];
                
                [followFriendsViewController setFollowUserQueryType:FTFollowUserQueryTypeTagger];
                [followFriendsViewController setSearchString:lowercaseStringWithoutSymbols];
                [followFriendsViewController querySearchForUser];
                
                [self presentViewController:followFriendsNavController animated:YES completion:nil];
                
            }
        }
    }];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
          didTapCommentButton:(UIButton *)button {
    [commentTextField becomeFirstResponder];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
             didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
   didTapImageInGalleryAction:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
               didTapLocation:(UIButton *)button
                         post:(PFObject *)aPost {
    //NSLog(@"FTPhotoTimelineViewController::galleryCellView:didTapLocation:gallery:");
    // Map Home View
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    if ([aPost objectForKey:kFTPostLocationKey]) {
        [mapViewController setInitialLocationObject:aPost];
    }
    [mapViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
             didTapMoreButton:(UIButton *)button {
    
    PFUser *currentUser = [PFUser currentUser];
    PFUser *postUser = [post objectForKey:kFTPostUserKey];
    
    UIActionSheet *actionSheet = nil;
    
    if ([currentUser.objectId isEqualToString:postUser.objectId]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:ACTION_SHARE_ON_FACEBOOK,
                       ACTION_SHARE_ON_TWITTER,
                       ACTION_REPORT_INAPPROPRIATE,
                       ACTION_DELETE_POST, nil];
    } else {
        NSLog(@"!=");
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:ACTION_SHARE_ON_FACEBOOK,
                       ACTION_SHARE_ON_TWITTER,
                       ACTION_REPORT_INAPPROPRIATE, nil];
    }
    
    [actionSheet showInView:self.view];
}

- (void)postDetailsHeaderView:(FTPostDetailsHeaderView *)headerView
        didTapLikeCountButton:(UIButton *)button
                         post:(PFObject *)aPost {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    
    if ([likeCount integerValue] > 0) {
        UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
        [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
        [backIndicator setStyle:UIBarButtonItemStylePlain];
        [backIndicator setTarget:self];
        [backIndicator setAction:@selector(didTapBackButtonAction:)];
        [backIndicator setTintColor:[UIColor whiteColor]];
        
        FTViewFriendsViewController *viewFriendsViewController = [[FTViewFriendsViewController alloc] init];
        [viewFriendsViewController.navigationItem setLeftBarButtonItem:backIndicator];
        [viewFriendsViewController setUser:[PFUser currentUser]];
        [viewFriendsViewController queryForLickersOf:aPost];
        [self.navigationController pushViewController:viewFriendsViewController animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (!post) {
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
        [FTUtility prepareToSharePostOnFacebook:post];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_SHARE_ON_TWITTER]) {
        [FTUtility prepareToSharePostOnTwitter:post];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTION_REPORT_INAPPROPRIATE]) {
        [self reportPostInappropriate:post];
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
        [query whereKey:kFTActivityPostKey equalTo:post];
        [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
            if (!error) {
                for (PFObject *activity in activities) {
                    [activity deleteEventually];
                }
            }
            
            // Delete post
            [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FTTimelineViewControllerUserDeletedPostNotification object:[post objectId]];
                }
            }];
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - FTPhotoDetailsFooterViewDelegate

- (void)photoDetailsFooterView:(FTPhotoDetailsFooterView *)footerView didTapSendButton:(UIButton *)button {
    //NSLog(@"%@::photoDetailsFooterView:didTapSendButtonAction:",CONTROLLER);
    [self textFieldShouldReturn:commentTextField];
}

#pragma mark - FTSuggestionTableViewDelegate

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectHashtag:(NSString *)hashtag completeString:(NSString *)completeString {
    if (hashtag) {
        //NSString *hashtagString = [@"#" stringByAppendingString:hashtag];
        NSString *replaceString = [commentTextField.text stringByReplacingOccurrencesOfString:completeString withString:hashtag];
        [commentTextField setText:replaceString];
    }
}

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectUser:(PFUser *)user completeString:(NSString *)completeString {
    if ([user objectForKey:kFTUserDisplayNameKey]) {
        NSString *displayname = [user objectForKey:kFTUserDisplayNameKey];
        //NSString *mentionString = [@"@" stringByAppendingString:displayname];
        NSString *replaceString = [commentTextField.text stringByReplacingOccurrencesOfString:completeString withString:displayname];
        [commentTextField setText:replaceString];
    }
}

#pragma mark - ()

- (void)didTapTableViewAction:(id)sender {
    //NSLog(@"didTapTableViewAction:");
}

- (void)didTapLoadCameraButtonAction:(id)sender {
    FTCamViewController *cameraViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil)
                                message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil] show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    NSString *userType = [user objectForKey:kFTUserTypeKey];
    
    if ([userType isEqualToString:kFTUserTypeBusiness]) {
        
        //NSLog(@"user:%@",user);
        //NSLog(@"userType:%@",userType);
        
        UICollectionViewFlowLayout *businessFloyLayout = [[UICollectionViewFlowLayout alloc] init];
        [businessFloyLayout setItemSize:CGSizeMake(self.view.frame.size.width/3,105)];
        [businessFloyLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [businessFloyLayout setMinimumInteritemSpacing:0];
        [businessFloyLayout setMinimumLineSpacing:0];
        [businessFloyLayout setSectionInset:UIEdgeInsetsMake(0,0,0,0)];
        [businessFloyLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width,PROFILE_HEADER_VIEW_HEIGHT_BUSINESS)];
        
        FTBusinessProfileViewController *businessViewController = [[FTBusinessProfileViewController alloc] initWithCollectionViewLayout:businessFlowLayout];
        [businessViewController setBusiness:user];
        [businessViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
        [self.navigationController pushViewController:businessViewController animated:YES];
        
    } else if ([userType isEqualToString:kFTUserTypeUser]) {
        [userProfileViewController setUser:user];
        [userProfileViewController.navigationItem setLeftBarButtonItem:dismissProfileButton];
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *info = [note userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = kbRect.size;
    CGFloat offset = self.tableView.contentSize.height - kbSize.height;
    [self.tableView setContentOffset:CGPointMake(0,offset) animated:NO];
}

- (void)didTapcancelButtonAction:(id)sender {
    [suggestionTableView setAlpha:0];
    [self.navigationItem setRightBarButtonItem:nil];
    [commentTextField resignFirstResponder];
    [self.tableView setScrollEnabled:YES];
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
        
        [[FTCache sharedCache] setAttributesForPost:post likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
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
        [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTimelineViewControllerUserDeletedPostNotification object:[self.post objectId]];
            }
        }];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reportPostInappropriate:(PFObject *)aPost {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setMailComposeDelegate:self];
        [mailer setSubject:[NSString stringWithFormat:@"%@: %@",MAIL_INAPPROPRIATE_SUBJECT,aPost.objectId]];
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
            NSLog(MAIL_CANCELLED);
            break;
        case MFMailComposeResultSaved:
            NSLog(MAIL_SAVED);
            break;
        case MFMailComposeResultSent:
            NSLog(MAIL_SENT);
            
            [FTUtility showHudMessage:MAIL_SENT WithDuration:2];
            break;
        default:
            NSLog(MAIL_FAIL);
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
