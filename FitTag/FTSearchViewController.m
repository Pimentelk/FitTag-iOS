//
//  FTSearchResultsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchViewController.h"
#import "FTPhotoDetailsViewController.h"
#import "FTAccountViewController.h"
#import "FTUtility.h"
#import "FTLoadMoreCell.h"
#import "FTMapViewController.h"

static NSString *const NothingFoundCellIdentifier = @"NothingFoundCell";

@interface FTSearchViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;

// Searchbar
@property (nonatomic, strong) UITextField *searchbar;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *popularButton;
@property (nonatomic, strong) UIButton *trendingButton;
@property (nonatomic, strong) UIButton *userButtons;
@property (nonatomic, strong) UIButton *businessButton;
@property (nonatomic, strong) UIButton *ambassadorButton;
@property (nonatomic, strong) UIButton *nearbyButton;
@end

@implementation FTSearchViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize headerView;
@synthesize filterView;
@synthesize filterButton;
@synthesize popularButton;
@synthesize trendingButton;
@synthesize userButtons;
@synthesize businessButton;
@synthesize ambassadorButton;
@synthesize nearbyButton;
@synthesize searchbar;
@synthesize searchResults;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FTPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}
- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // I created a dummy class to avoid it automatically download data
        self.parseClassName = @"Dummy";
        
        //self.textKey = @"restaurantName";
        
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = NO;
        
        self.objectsPerPage = 10;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [super viewDidLoad];
    
    // Set title
    [self.navigationItem setTitle: @"SEARCH"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Set back indicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Set map indicator
    UIBarButtonItem *mapIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_button"] style:UIBarButtonItemStylePlain target:self action:@selector(loadNearbyMap:)];
    [mapIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:mapIndicator];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    
    UIImageView *searchbarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar"]];
    [searchbarBackground setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    [searchbarBackground setUserInteractionEnabled:YES];
    [headerView addSubview:searchbarBackground];
    
    searchbar = [[UITextField alloc] init];
    [searchbar setFrame:CGRectMake(7.0f, 1.0f, 280.0f, 31.0f)];
    [searchbar setFont:[UIFont systemFontOfSize:12.0f]];
    [searchbar setReturnKeyType:UIReturnKeyGo];
    [searchbar setTextColor:[UIColor blackColor]];
    [searchbar setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [searchbar setBackgroundColor:[UIColor clearColor]];
    [searchbar setPlaceholder:@"Search..."];
    [searchbar setDelegate:self];
    [headerView addSubview:searchbar];
    [headerView bringSubviewToFront:searchbar];
    
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setFrame: CGRectMake( self.headerView.bounds.size.width - 30.0f, 7.0f, 20.0f, 20.0f)];
    //[filterButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [filterButton setBackgroundColor:[UIColor clearColor]];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"cancelfilter"] forState:UIControlStateSelected];
    [filterButton addTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:filterButton];
    [headerView bringSubviewToFront:filterButton];
    
    filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, headerView.bounds.size.height, self.tableView.bounds.size.width, 56.0f)];
    [filterView setBackgroundColor:[UIColor clearColor]];
    [filterView setUserInteractionEnabled:YES];
    [headerView addSubview:filterView];
    [headerView setUserInteractionEnabled:YES];
    [headerView bringSubviewToFront:filterView];
    
    popularButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [popularButton setFrame: CGRectMake( 0.0f, 0.0f, 50.0f, 56.0f)];
    [popularButton setBackgroundColor:[UIColor clearColor]];
    [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular"] forState:UIControlStateNormal];
    [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular_selected"] forState:UIControlStateSelected];
    [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular_selected"] forState:UIControlStateHighlighted];
    [popularButton addTarget:self action:@selector(popularButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:popularButton];
    [filterView bringSubviewToFront:popularButton];
    [filterView setUserInteractionEnabled:YES];
    
    trendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [trendingButton setFrame: CGRectMake( popularButton.frame.origin.x + popularButton.frame.size.width, 0.0f, 48.0f, 56.0f)];
    [trendingButton setBackgroundColor:[UIColor clearColor]];
    [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending"] forState:UIControlStateNormal];
    [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending_selected"] forState:UIControlStateSelected];
    [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending_selected"] forState:UIControlStateHighlighted];
    [trendingButton addTarget:self action:@selector(trendingButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:trendingButton];
    [filterView bringSubviewToFront:trendingButton];
    [filterView setUserInteractionEnabled:YES];
    
    userButtons = [UIButton buttonWithType:UIButtonTypeCustom];
    [userButtons setFrame: CGRectMake( trendingButton.frame.origin.x + trendingButton.frame.size.width, 0.0f, 62.0f, 56.0f)];
    [userButtons setBackgroundColor:[UIColor clearColor]];
    [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users"] forState:UIControlStateNormal];
    [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users_selected"] forState:UIControlStateSelected];
    [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users_selected"] forState:UIControlStateHighlighted];
    [userButtons addTarget:self action:@selector(userButtonsHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:userButtons];
    [filterView bringSubviewToFront:userButtons];
    [filterView setUserInteractionEnabled:YES];
    
    businessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [businessButton setFrame: CGRectMake( userButtons.frame.origin.x + userButtons.frame.size.width, 0.0f, 56.0f, 56.0f)];
    [businessButton setBackgroundColor:[UIColor clearColor]];
    [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business"] forState:UIControlStateNormal];
    [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business_selected"] forState:UIControlStateSelected];
    [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business_selected"] forState:UIControlStateHighlighted];
    [businessButton addTarget:self action:@selector(businessButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:businessButton];
    [filterView bringSubviewToFront:businessButton];
    [filterView setUserInteractionEnabled:YES];
    
    ambassadorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [ambassadorButton setFrame: CGRectMake( businessButton.frame.origin.x + businessButton.frame.size.width, 0.0f, 56.0f, 56.0f)];
    [ambassadorButton setBackgroundColor:[UIColor clearColor]];
    [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador"] forState:UIControlStateNormal];
    [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador_selected"] forState:UIControlStateSelected];
    [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador_selected"] forState:UIControlStateHighlighted];
    [ambassadorButton addTarget:self action:@selector(ambassadorButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:ambassadorButton];
    [filterView bringSubviewToFront:ambassadorButton];
    [filterView setUserInteractionEnabled:YES];
    
    nearbyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearbyButton setFrame: CGRectMake( ambassadorButton.frame.origin.x + ambassadorButton.frame.size.width, 0.0f, 48.0f, 56.0f)];
    [nearbyButton setBackgroundColor:[UIColor clearColor]];
    [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby"] forState:UIControlStateNormal];
    [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby_selected"] forState:UIControlStateSelected];
    [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby_selected"] forState:UIControlStateHighlighted];
    [nearbyButton addTarget:self action:@selector(nearbyButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:nearbyButton];
    [filterView bringSubviewToFront:nearbyButton];
    [filterView setUserInteractionEnabled:YES];
    [filterView setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self clearSelectedFilters];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (searchResults == nil) {
        return 0;
    } else if ([searchResults count] == 0) {
        return 1;
    } else {
        return [searchResults count];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath %ld",(long)indexPath.row);
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
    
    NSLog(@"tableView:didSelectRowAtIndexPath:");
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"willSelectRowAtIndexPath %ld",(long)indexPath.row);

    if ([searchResults count] == 0) {
        return nil;
    } else {
        return indexPath;
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"FTSearchResultsViewController::tableView:(UITableView *) %@ cellForRowAtIndexPath:(NSIndexPath *) %@ object:(PFObject *) %@",tableView,indexPath,object);

    static NSString *identifier = @"SearchCell";
        
    //Custom Cell
    FTSearchCell *searchCell = (FTSearchCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (searchCell == nil) {
        searchCell = [[FTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [searchCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [searchCell setDelegate:self];
    }
    
    if ([searchResults count] == 0) {
        static NSString *emptyIdentifier = @"EmptyCell";
        FTSearchCell *emptyCell = (FTSearchCell *)[tableView dequeueReusableCellWithIdentifier:emptyIdentifier];
        if (emptyCell == nil) {
            emptyCell = [[FTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyIdentifier];
        }
        [emptyCell setName:@"No results found..."];
        return emptyCell;
        
    } else {
        @synchronized(self) {
            
            //PFObject *object = [PFObject objectWithClassName:self.parseClassName];
            //object = [searchResults objectAtIndex:indexPath.row];
            
            if ([popularButton isSelected]) {
                
                PFObject *object = [PFObject objectWithClassName:kFTActivityClassKey];
                object = [searchResults objectAtIndex:indexPath.row];
                //NSLog(@"PFOBJECT: %@",object);
                
                if ([[object objectForKey:kFTPostTypeKey] isEqualToString:@"video"]) {
                    //NSLog(@"likeCountForVideo: %@",[[[FTCache sharedCache] likeCountForVideo:object] description]);
                    //NSLog(@"commentCountForVideo: %@",[[[FTCache sharedCache] commentCountForVideo:object] description]);
                }
                
                if ([[object objectForKey:kFTPostTypeKey] isEqualToString:@"image"]) {
                    //NSLog(@"likeCountForPhoto: %@",[[[FTCache sharedCache] likeCountForPhoto:object] description]);
                    //NSLog(@"commentCountForPhoto: %@",[[[FTCache sharedCache] commentCountForPhoto:object] description]);
                }
                
                [searchCell setName:[object[@"user"] objectForKey:kFTUserDisplayNameKey]];
                [searchCell setIcon:[self setIconType]];
                [searchCell setPost:object];
                
                /*
                PFRelation *relation = [object relationforKey:kFTPostKey];
                [[relation query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    if (!error) {
                        NSLog(@"Object id: %@ count: %d for.",object.objectId,number);
                    }
                }];
                */
            }
            
            if ([businessButton isSelected]) {
                PFObject *object = [PFObject objectWithClassName:kFTActivityClassKey];
                object = [searchResults objectAtIndex:indexPath.row];
                [searchCell setName:[object[@"fromUser"] objectForKey:kFTUserDisplayNameKey]];
                [searchCell setIcon:[self setIconType]];
                [searchCell setPost:[object objectForKey:kFTActivityPostKey]];
            }
            
            if ([trendingButton isSelected]) {
                PFObject *object = [PFObject objectWithClassName:kFTActivityClassKey];
                object = [searchResults objectAtIndex:indexPath.row];
                [searchCell setName:[object[@"fromUser"] objectForKey:kFTUserDisplayNameKey]];
                [searchCell setIcon:[self setIconType]];
                [searchCell setPost:[object objectForKey:kFTActivityPostKey]];
            }
            
            if([userButtons isSelected]){
                PFObject *object = [PFObject objectWithClassName:@"_User"];
                object = [searchResults objectAtIndex:indexPath.row];
                [searchCell setName:[object objectForKey:kFTUserDisplayNameKey]];
                [searchCell setIcon:[self setIconType]];
                [searchCell setUser:(PFUser *)object];
            }
        }
    }
    return searchCell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark - ()

- (NSInteger)setIconType{
    if ([popularButton isSelected]) {
        return 1;
    } else if ([trendingButton isSelected]) {
        return 2;
    } else if ([userButtons isSelected]) {
        return 3;
    } else if ([businessButton isSelected]) {
        return 4;
    } else if ([ambassadorButton isSelected]) {
        return 5;
    } else if ([nearbyButton isSelected]) {
        return 6;
    } else {
        return 0;
    }
}

- (void)clearSelectedFilters{
    [popularButton setSelected:NO];
    [trendingButton setSelected:NO];
    [userButtons setSelected:NO];
    [businessButton setSelected:NO];
    [ambassadorButton setSelected:NO];
    [nearbyButton setSelected:NO];
}

- (void)popularButtonHandler:(id)sender{
    [self clearSelectedFilters];
    if(![popularButton isSelected]){
        [popularButton setSelected:YES];
    } else {
        [popularButton setSelected:NO];
    }
}

- (void)trendingButtonHandler:(id)sender{
    [self clearSelectedFilters];
    if(![trendingButton isSelected]){
        [trendingButton setSelected:YES];
    } else {
        [trendingButton setSelected:NO];
    }
}

- (void)userButtonsHandler:(id)sender{
    [self clearSelectedFilters];
    if(![userButtons isSelected]){
        [userButtons setSelected:YES];
    } else {
        [userButtons setSelected:NO];
    }
}

- (void)businessButtonHandler:(id)sender{
    [self clearSelectedFilters];
    if(![businessButton isSelected]){
        [businessButton setSelected:YES];
    } else {
        [businessButton setSelected:NO];
    }
}

- (void)ambassadorButtonHandler:(id)sender{
    [self clearSelectedFilters];
    if(![ambassadorButton isSelected]){
        [ambassadorButton setSelected:YES];
    } else {
        [ambassadorButton setSelected:NO];
    }
}

- (void)nearbyButtonHandler:(id)sender{
    [self clearSelectedFilters];
    if(![nearbyButton isSelected]){
        [nearbyButton setSelected:YES];
    } else {
        [nearbyButton setSelected:NO];
    }
}

- (void)showFilterOptions:(id)sender{
    [self.headerView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 91.0f)];
    [filterButton removeTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton addTarget:self action:@selector(hideFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterView setHidden:NO];
    self.tableView.tableHeaderView = headerView;
}

-(void)hideFilterOptions:(id)sender{
    [self.headerView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    [filterButton removeTarget:self action:@selector(hideFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton addTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterView setHidden:YES];
    self.tableView.tableHeaderView = headerView;
}

- (void)returnHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadNearbyMap:(id)sender{
    FTMapViewController *mapViewController = [[FTMapViewController alloc] init];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (NSArray *) checkForHashtag:(UITextField *)textField {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textField.text options:0 range:NSMakeRange(0,textField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [textField.text substringWithRange:wordRange];
        //NSLog(@"Found tag %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (NSMutableArray *) checkForMention:(UITextField *)textField {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textField.text options:0 range:NSMakeRange(0,textField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [textField.text substringWithRange:wordRange];
        //NSLog(@"Found mention %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if (trimmedComment.length != 0) {
        
        [searchResults removeAllObjects];
        searchResults = [NSMutableArray arrayWithCapacity:50];
        
        PFQuery *query = nil;
        
        if ([popularButton isSelected]) {
            
            PFQuery *postsActivitiesQuery = [PFQuery queryWithClassName:kFTActivityClassKey];
            [postsActivitiesQuery whereKey:kFTActivityTypeKey containedIn:@[kFTActivityTypeLike,kFTActivityTypeComment]];
            [postsActivitiesQuery includeKey:kFTActivityPostKey];
            
            PFQuery *postsQuery = [PFQuery queryWithClassName:kFTPostClassKey];
            [query whereKey:kFTPostUserKey matchesKey:kFTActivityToUserKey inQuery:postsActivitiesQuery];
            
            query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects: postsQuery, nil]];
            [query includeKey:kFTPostUserKey];
            [query orderByDescending:@"createdAt"];
        } else if ([trendingButton isSelected]) {
            query = [PFQuery queryWithClassName:kFTActivityClassKey];
            [query whereKey:kFTActivityContentKey containsString:[trimmedComment lowercaseString]];
            [query includeKey:kFTActivityFromUserKey];
            [query includeKey:kFTActivityPostKey];
            [query orderByDescending:@"createdAt"];
        } else if ([userButtons isSelected]) {
            query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:kFTUserDisplayNameKey containsString:[trimmedComment lowercaseString]];
            [query orderByAscending:@"createdAt"];
        } else if ([businessButton isSelected]) {
            query = [PFQuery queryWithClassName:kFTActivityClassKey];
            [query whereKey:kFTActivityHashtag equalTo:[trimmedComment lowercaseString]];
            [query includeKey:kFTActivityFromUserKey];
            [query includeKey:kFTActivityPostKey];
            [query orderByDescending:@"createdAt"];
        } else if ([ambassadorButton isSelected]) {
            // Query where user type is ambassador
        } else if ([nearbyButton isSelected]) {
            // Query where current location is near 50 miles of other users
            /*
            CGFloat kilometers = 50 / 0.62137; // M / 0.62137 = Kilometers
            
            query = [PFQuery queryWithClassName:@"_User"];
            [query setLimit:1000];
            [query whereKey:kFTUserDisplayNameKey containsString:[trimmedComment lowercaseString]];
            [query whereKey:kFTUserLocationKey
               nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                                   longitude:self.location.coordinate.longitude]
           withinKilometers:kilometers];
           */
        }
        
        if (query != nil) {
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSArray *results = objects;
                    [searchResults addObjectsFromArray:results];
                
                    if (searchResults != nil) {
                        [self loadObjects];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Empty search" message:@"no results found" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil] show];
                    }
                    //NSLog(@"searchResults = %@",searchResults);

                    if ([popularButton isSelected]) {
                        NSMutableDictionary *resultsDictionary =[[NSMutableDictionary alloc] init];
                        for (PFObject *object in objects) {
                            [resultsDictionary setValue:object forKey:object.objectId];
                        }
                        NSLog(@"resultsDictionary: %@",resultsDictionary);
                    }
                }
            }];
        }
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

#pragma mark - FTSearchCellDelegate

-(void)cellView:(PFTableViewCell *)cellView didTapCellLabelButton:(UIButton *)button post:(PFObject *)post{
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapAmbassadorCellIconButton:(UIButton *)button post:(PFObject *)post{
    
}

-(void)cellView:(PFTableViewCell *)cellView didTapHashtagCellIconButton:(UIButton *)button post:(PFObject *)post{
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapNearbyCellIconButton:(UIButton *)button post:(PFObject *)post{
    
}

-(void)cellView:(PFTableViewCell *)cellView didTapPopularCellIconButton:(UIButton *)button post:(PFObject *)post{
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapTrendingCellIconButton:(UIButton *)button post:(PFObject *)post{
    if (post != nil) {
        FTPhotoDetailsViewController *photoDetailsVC = [[FTPhotoDetailsViewController alloc] initWithPhoto:post];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

-(void)cellView:(PFTableViewCell *)cellView didTapUserCellIconButton:(UIButton *)button user:(PFUser *)user{
    if (user != nil) {
        FTAccountViewController *accountViewController = [[FTAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        [accountViewController setUser:user];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}
@end
