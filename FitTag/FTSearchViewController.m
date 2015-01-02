//
//  FTSearchViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/6/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchViewController.h"
#import "FTSearchCell.h"

#define DATACELL_IDENTIFIER @"DataCell"

@interface FTSearchViewController()

@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end

@implementation FTSearchViewController
@synthesize searchQueryType;
@synthesize searchString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // Set background image
    [self.tableView setBackgroundColor:FT_GRAY];
    
    // Fittag navigationbar color
    self.navigationController.navigationBar.barTintColor = FT_RED;
    self.tableView.delegate = self;
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (searchString.length > 0) {
        [self.navigationItem setTitle:searchString];
        [self loadObjects];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_SEARCH];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - ()

- (PFQuery *)queryForTable {
    //NSLog(@"%@,searchQueryForTable::queryForTable",VIEWCONTROLLER_SEARCH);
    switch (searchQueryType) {
        case FTSearchQueryTypeFitTag: {
            
            // Remove hashtags & mentions
            NSString *cleanedSearchString = [[searchString stringByReplacingOccurrencesOfString:@"#" withString:EMPTY_STRING] lowercaseString];
                      cleanedSearchString = [[cleanedSearchString stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING] lowercaseString];
            
            PFQuery *hashtagQuery = [PFQuery queryWithClassName:kFTPostClassKey];
            [hashtagQuery whereKey:kFTPostHashTagKey equalTo:cleanedSearchString];
            [hashtagQuery orderByDescending:@"createdAt"];
            [hashtagQuery includeKey:kFTPostUserKey];
            return hashtagQuery;
        }
            break;
        default:
            break;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query setLimit:0];
    return query;
}

- (void)didTapBackButtonAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    FTLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[FTLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

@end
