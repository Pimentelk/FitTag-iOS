//
//  FTSearchResultsViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//
/*
#import "FTSearchResultsViewController.h"
#import "FTSearchViewController.h"
//#import "FTSearchDetailsViewController.h"
#import "FTUtility.h"
#import "FTLoadMoreCell.h"

@interface FTSearchResultsViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *popularButton;
@property (nonatomic, strong) UIButton *trendingButton;
@property (nonatomic, strong) UIButton *userButtons;
@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, strong) UIButton *ambassadorButton;
@property (nonatomic, strong) UIButton *nearbyButton;
@end

@implementation FTSearchResultsViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize headerView;
@synthesize filterView;
@synthesize filterButton;
@synthesize popularButton;
@synthesize trendingButton;
@synthesize userButtons;
@synthesize tagButton;
@synthesize ambassadorButton;
@synthesize nearbyButton;

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
        self.parseClassName = kFTPostClassName;
        
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
    
    [self.navigationItem setTitle: @"SEARCH"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    
    UIImageView *searchbarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar"]];
    [searchbarBackground setFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 35.0f)];
    [searchbarBackground setUserInteractionEnabled:YES];
    [headerView addSubview:searchbarBackground];
    
    UITextField *searchbar = [[UITextField alloc] init];
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
    
    tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tagButton setFrame: CGRectMake( userButtons.frame.origin.x + userButtons.frame.size.width, 0.0f, 56.0f, 56.0f)];
    [tagButton setBackgroundColor:[UIColor clearColor]];
    [tagButton setBackgroundImage:[UIImage imageNamed:@"search_hashtag"] forState:UIControlStateNormal];
    [tagButton setBackgroundImage:[UIImage imageNamed:@"search_hashtag_selected"] forState:UIControlStateSelected];
    [tagButton setBackgroundImage:[UIImage imageNamed:@"search_hashtag_selected"] forState:UIControlStateHighlighted];
    [tagButton addTarget:self action:@selector(tagButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:tagButton];
    [filterView bringSubviewToFront:tagButton];
    [filterView setUserInteractionEnabled:YES];
    
    ambassadorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [ambassadorButton setFrame: CGRectMake( tagButton.frame.origin.x + tagButton.frame.size.width, 0.0f, 56.0f, 56.0f)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 2.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 56.0f;
    }
    return 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController
#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query setLimit:100];
    return query;
    
    
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        //NSLog(@"object: %@",[self.objects objectAtIndex:indexPath.section]);
        return [self.objects objectAtIndex:indexPath.section];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    NSLog(@"FTSearchResultsViewController::tableView:(UITableView *) %@ cellForRowAtIndexPath:(NSIndexPath *) %@ object:(PFObject *) %@",tableView,indexPath,object);
    
    if (indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    
    static NSString *identifier = @"Cell";
    FTSearchCell *searchCell = (FTSearchCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (searchCell == nil) {
        searchCell = [[FTSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [searchCell setDelegate:self];
        [searchCell setCell:FTSearchCellTypePopular displayName:@"@kevinFittag"];
    }
    
    return searchCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    //NSLog(@"tableView:(UITableView *)%@ cellForNextPageAtIndexPath:(NSIndexPath *)%@",tableView,indexPath);
    
    FTLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[FTLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

#pragma mark - FTPhotoTimelineViewController

- (FTSearchCell *)dequeueReusableSectionHeaderView {
    for (FTSearchCell *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
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

#pragma mark - ()

- (void)popularButtonHandler:(id)sender{
    NSLog(@"popularButtonHandler:(id)%@",sender);
    if(![popularButton isSelected]){
        [popularButton setSelected:YES];
    } else {
        [popularButton setSelected:NO];
    }
}

- (void)trendingButtonHandler:(id)sender{
    NSLog(@"trendingButtonHandler:(id)%@",sender);
    if(![trendingButton isSelected]){
        [trendingButton setSelected:YES];
    } else {
        [trendingButton setSelected:NO];
    }
}

- (void)userButtonsHandler:(id)sender{
    NSLog(@"userButtonsHandler:(id)%@",sender);
    if(![userButtons isSelected]){
        [userButtons setSelected:YES];
    } else {
        [userButtons setSelected:NO];
    }
}

- (void)tagButtonHandler:(id)sender{
    NSLog(@"tagButtonHandler:(id)%@",sender);
    if(![tagButton isSelected]){
        [tagButton setSelected:YES];
    } else {
        [tagButton setSelected:NO];
    }
}

- (void)ambassadorButtonHandler:(id)sender{
    NSLog(@"ambassadorButtonHandler:(id)%@",sender);
    if(![ambassadorButton isSelected]){
        [ambassadorButton setSelected:YES];
    } else {
        [ambassadorButton setSelected:NO];
    }
}

- (void)nearbyButtonHandler:(id)sender{
    NSLog(@"nearbyHandler:(id)%@",sender);
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
}

-(void)hideFilterOptions:(id)sender{
    [filterButton removeTarget:self action:@selector(hideFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton addTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterView setHidden:YES];
}

- (void)returnHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0) {
        NSLog(@"trimmedComment = %@",trimmedComment);
        NSLog(@"popularButton = %d",[popularButton isSelected]);
        NSLog(@"trendingButton = %d",[trendingButton isSelected]);
        NSLog(@"userButtons = %d",[userButtons isSelected]);
        NSLog(@"tagButton = %d",[tagButton isSelected]);
        NSLog(@"ambassadorButton = %d",[ambassadorButton isSelected]);
        NSLog(@"nearbyButton = %d",[nearbyButton isSelected]);
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

@end
*/