//
//  FitTagNavigationBar.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTNavigationController.h"
#import "FTCamViewController.h"
#import "FTFollowFriendsViewController.h"
#import "FTSettingsViewController.h"
#import "FTSuggestionCell.h"
#import "FTPlaceProfileViewController.h"
#import "FTUserProfileViewController.h"
#import "FTMapViewController.h"

// Animation Duration
#define ANIMATION_DURATION 0.3

@interface FTNavigationController() <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,FTSuggestionCellDelegate>

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) FTSettingsViewController *leftViewController;

@property (nonatomic, strong) UISegmentedControl *searchSC;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIBarButtonItem *search;
@property (nonatomic, strong) UIBarButtonItem *cancel;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIView *buttonsContainer;

@property (nonatomic, strong) UIButton *hashtagSearch;
@property (nonatomic, strong) UIButton *userSearch;

@property (nonatomic, strong) UITableView *suggestionView;

@property (nonatomic, strong) NSMutableArray *suggestions;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *hashtags;

@property (nonatomic, strong) FTMapViewController *mapVC;

@property (nonatomic) BOOL isMap;

@end

@implementation FTNavigationController
@synthesize myDelegate;
@synthesize searchSC;
@synthesize segmentedControl;
@synthesize search;
@synthesize cancel;
@synthesize doneButton;
@synthesize searchBar;
@synthesize buttonsContainer;
@synthesize hashtagSearch;
@synthesize userSearch;
@synthesize suggestionView;
@synthesize suggestions;
@synthesize users;
@synthesize hashtags;
@synthesize isMap;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

#pragma mark - init

- (id)initWithMapViewController:(FTMapViewController *)mapViewController {
    
    UIViewController *rootViewController = (UIViewController *)mapViewController;
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        // init suggestion arrays
        suggestions = [[NSMutableArray alloc] init];
        users = [[NSMutableArray alloc] init];
        hashtags = [[NSMutableArray alloc] init];

        self.centerViewController = rootViewController;
        self.mapVC = mapViewController;
        
        // Menu UIBarButton
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithImage:BUTTON_IMAGE_REVEAL
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(didTapMenuButtonAction:)];
        [menu setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.leftBarButtonItem = menu;
        
        // Show the map search icon
        search =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(didTapShowSearchButtonAction:)];
        [search setStyle:UIBarButtonItemStylePlain];
        [search setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.rightBarButtonItem = search;
        
        [self searchSuggestions];
        [self configSuggestionView];
        
        // Segmented Control
        segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Map",@"Home"]];
        segmentedControl.frame = CGRectMake(0, 0, 180, 22);
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.tintColor = [UIColor whiteColor];
        [segmentedControl addTarget:self
                             action:@selector(didChangeSegmentedControl:)
                   forControlEvents: UIControlEventValueChanged];
        
        rootViewController.navigationItem.titleView = segmentedControl;
    }
    
    return self;
}

- (id)initWithFeedViewController:(FTFeedViewController *)feedViewController {
    
    UIViewController *rootViewController = (UIViewController *)feedViewController;
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        self.centerViewController = rootViewController;
        
        // Menu UIBarButton
        UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithImage:BUTTON_IMAGE_REVEAL
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(didTapMenuButtonAction:)];
        [menu setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.leftBarButtonItem = menu;
        
        // Camera UIBarButton
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                target:self
                                                                                action:@selector(didTapCameraButtonAction:)];
        [camera setStyle:UIBarButtonItemStylePlain];
        [camera setTintColor:[UIColor whiteColor]];
        
        rootViewController.navigationItem.rightBarButtonItem = camera;
        
        // Segmented Control
        segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Map",@"Home"]];
        segmentedControl.frame = CGRectMake(0, 0, 180, 22);
        segmentedControl.selectedSegmentIndex = 1;
        segmentedControl.tintColor = [UIColor whiteColor];
        [segmentedControl addTarget:self
                             action:@selector(didChangeSegmentedControl:)
                   forControlEvents: UIControlEventValueChanged];
        
        rootViewController.navigationItem.titleView = segmentedControl;
    }
    
    return self;
}

#pragma mark - Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"%@::viewDidLoad:",VIEWCONTROLLER_NAVIGATION);
    
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    self.navigationBar.barTintColor = FT_RED;
    self.navigationBar.translucent = NO;
    
    self.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (searchBar) {
        [searchBar resignFirstResponder];
    }
}

#pragma mark

- (void)configSuggestionView {
    
    //NSLog(@"configSuggestionView");
    
    // Add Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboardAction:) name:UIKeyboardDidShowNotification object:nil];
    
    // SearchBar
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    
    // Cancel button
    cancel =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelSearchButtonAction:)];
    [cancel setStyle:UIBarButtonItemStylePlain];
    [cancel setTintColor:[UIColor whiteColor]];
    
    // config the suggestions tableview
    suggestionView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [suggestionView setDelegate:self];
    [suggestionView setDataSource:self];
    [suggestionView setAlpha:0];
    
    [self.view addSubview:suggestionView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat searchSCWidth = 240;
    CGFloat searchSCHeight = 22;
    CGFloat centerX = (self.view.frame.size.width - searchSCWidth) / 2;
    CGFloat centerY = (40 - searchSCHeight) / 2;
    
    // Segmented Control
    searchSC = [[UISegmentedControl alloc] initWithItems:@[@"Users", @"Hashtags"]];
    searchSC.frame = CGRectMake(centerX, centerY, searchSCWidth, searchSCHeight);
    searchSC.selectedSegmentIndex = 0;
    searchSC.tintColor = FT_RED;
    [searchSC addTarget:self
                 action:@selector(didChangeSearchSegmentedControl:)
       forControlEvents: UIControlEventValueChanged];
    
    [headerView addSubview:searchSC];
    
    suggestionView.tableHeaderView = headerView;
    
    [self updateUserSegment];
}

- (void)updateUserSegment {
    
    //NSLog(@"updateUserSegment");
    //NSLog(@"%@::didTapTaggersLabelAction:",VIEWCONTROLLER_MAP);
    
    [searchBar setImage:[self imageFromText:@"@"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
    
    [self.suggestions removeAllObjects];
    [self.suggestions addObjectsFromArray:users];
    
    [suggestionView reloadData];
}

- (void)updateHashtagSegment {
    
    //NSLog(@"updateHashtagSegment");
    
    [searchBar setImage:[self imageFromText:@"#"]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];
    
    [self.suggestions removeAllObjects];
    [self.suggestions addObjectsFromArray:hashtags];
    [suggestionView reloadData];
}

- (UIImage *)imageFromText:(NSString *)text {
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}];
    
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        UIGraphicsBeginImageContext(size);
    
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// Set the frame of the suggestionview when the keyboard showsup
- (void)didShowKeyboardAction:(NSNotification *)aNotification {
    //NSLog(@"didShowKeyboardAction:");
    
    NSDictionary *info = [aNotification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    // Set the suggestionView frame
    CGRect frameRect = self.view.frame;
    CGFloat suggestionsY = self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y;
    CGFloat suggestionHeight = frameRect.size.height - kbFrame.size.height - suggestionsY;
    [suggestionView setFrame:CGRectMake(0, suggestionsY, frameRect.size.width, suggestionHeight)];
}

// Update suggestions based on the search text
- (void)updateSuggestions:(NSString *)searchText {
    
    [suggestions removeAllObjects];
    
    if (searchSC.selectedSegmentIndex == 0) {
        
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:users];
            [suggestionView reloadData];
            return;
        }
        
        for (PFUser *user in users) {
            NSString *displayName = [user objectForKey:kFTUserDisplayNameKey];
            NSRange substringRange = [[displayName lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:user];
            }
        }
        
    } else {
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:hashtags];
            [suggestionView reloadData];
            return;
        }
        
        for (NSString *hashtag in hashtags) {
            NSRange substringRange = [[hashtag lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:hashtag];
            }
        }
    }
    
    [suggestionView reloadData];
}

// Get the suggestions and populate the arrays
- (void)searchSuggestions {
    
    NSLog(@"searchSuggestions");
    
    PFQuery *usersQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [usersQuery  whereKeyExists:kFTUserDisplayNameKey];
    [usersQuery  whereKeyExists:kFTUserProfilePicSmallKey];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *userObjects, NSError *error) {
        if (!error) {
            
            NSMutableArray *userSuggestions = [[NSMutableArray alloc] initWithArray:userObjects];
            NSMutableArray *displayNames = [[NSMutableArray alloc] init];
            
            // Get array of names
            for (PFUser *user in users) {
                [displayNames addObject:[user objectForKey:kFTUserDisplayNameKey]];
            }
            
            for (PFUser *userSuggestion in userSuggestions) {
                
                NSString *displayName = [userSuggestion objectForKey:kFTUserDisplayNameKey];
                
                if (![displayNames containsObject:displayName]) {
                    //NSLog(@"displayName:%@",displayName);
                    [users addObject:userSuggestion];
                }
            }
            //NSLog(@"users:%@",users);
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
    
    PFQuery *hashtagQuery = [PFQuery queryWithClassName:kFTPostClassKey];
    [hashtagQuery whereKeyExists:kFTPostHashTagKey];
    [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.suggestions removeAllObjects];
            
            NSMutableArray *hashtagSuggestions = [[NSMutableArray alloc] initWithArray:objects]; // array of PFObjects
            
            for (PFObject *object in hashtagSuggestions) { // loop throught PFObjects
                NSMutableArray *postHashtags = [object objectForKey:kFTPostHashTagKey]; // array of hashtags
                for (NSString *postHashtag in postHashtags) { // loop through array of hashtags
                    if (![hashtags containsObject:postHashtag]) { // if unique insert into our array else skip
                        //NSLog(@"postHashtag:%@",postHashtag);
                        [hashtags addObject:postHashtag];
                    }
                }
            }
            //NSLog(@"hashtagObjects:%@",hashtags);
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
}

- (void)didTapMenuButtonAction:(UIBarButtonItem *)button {
        
    [self didTapCancelSearchButtonAction:nil];
    
    if (myDelegate && [myDelegate respondsToSelector:@selector(navigationController:didTapMenuButton:)]) {
        [myDelegate navigationController:self didTapMenuButton:button];
    }
}

// Shows the searchbar in the title view and hides the search icon
// replaces search icon with a cancel button
- (void)didTapShowSearchButtonAction:(UIBarButtonItem *)button {
    
    //NSLog(@"didTapShowSearchButtonAction:");
    
    // Searchbar
    if (searchBar) {
        [searchBar becomeFirstResponder];
        [self.centerViewController.navigationItem setTitleView:searchBar];
    }
    
    // Show the map search icon
    if (cancel) {
        self.centerViewController.navigationItem.rightBarButtonItem = cancel;
    }
    
    if (suggestionView) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [suggestionView setAlpha:1];
        }];
    }
}

// hides the cancel button and shows a search icon
// hides the search view, suggestion view, and shows the map/home tabs
- (void)didTapCancelSearchButtonAction:(UIBarButtonItem *)button {
    
    if (searchBar) {
        [searchBar resignFirstResponder];
    }
    
    if (segmentedControl) {
        [self.centerViewController.navigationItem setTitleView:segmentedControl];
    }
    
    if (search) {
        self.centerViewController.navigationItem.rightBarButtonItem = search;
    }
    
    if (suggestionView) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [suggestionView setAlpha:0];
        }];
    }
}

- (void)didTapCameraButtonAction:(id)sender {
    
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[ camViewController ] animated:NO];
    
    [self presentViewController:navController animated:YES completion:^(){
        [self.tabBarController setSelectedIndex:TAB_FEED];
    }];
}

- (void)didTapBackButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didChangeSegmentedControl:(UISegmentedControl *)control {
    
    [self.tabBarController setSelectedIndex:control.selectedSegmentIndex];
    
    if (control.selectedSegmentIndex == 0) {
        control.selectedSegmentIndex = 1;
    } else {
        control.selectedSegmentIndex = 0;
    }    
}

- (void)didChangeSearchSegmentedControl:(UISegmentedControl *)control {
    
    //NSLog(@"control.selectedSegmentIndex:%ld",control.selectedSegmentIndex);
    
    if (control.selectedSegmentIndex == 0) {
        [self updateUserSegment];
    } else {
        [self updateHashtagSegment];
    }
}

#pragma mark - UISearchBarDelegate

/*
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar {
    [self.navigationItem setRightBarButtonItem:doneButton];
    return YES;
}
*/

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    //NSLog(@"started editing..");
    
    [self.suggestions removeAllObjects];
    
    if (searchSC.selectedSegmentIndex == 0) {
        [self.suggestions addObjectsFromArray:users];
    } else {
        [self.suggestions addObjectsFromArray:hashtags];
    }
    
    [suggestionView reloadData];
    
    if (aSearchBar.text.length > 0) {
        [self updateSuggestions:aSearchBar.text];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    //NSLog(@"searchText:%@",searchBar.text);

    //[self.navigationItem setRightBarButtonItem:postButton];
    
    [searchBar resignFirstResponder];
    [suggestionView setAlpha:0];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSuggestions:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    [self didTapCancelSearchButtonAction:nil];
    
    BOOL isUser = NO;
    
    if (searchSC.selectedSegmentIndex == 0) {
        isUser = YES;
    }
    
    [self.mapVC didTapSearch:aSearchBar.text forUser:isUser];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FTSuggestionCell *cell = (FTSuggestionCell *)[tableView dequeueReusableCellWithIdentifier:@"DataCell"];
    if (cell == nil) {
        cell = [[FTSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DataCell"];
        [cell setDelegate:self];
    }
    
    if (suggestions && suggestions.count) {
        //NSLog(@"%@",[suggestions objectAtIndex:indexPath.row]);
        if (searchSC.selectedSegmentIndex == 0) {
            PFUser *user = (PFUser *)[suggestions objectAtIndex:indexPath.row];
            [cell setUser:user];
        } else {
            [cell setHashtag:[suggestions objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

#pragma mark - FTSuggestionTableViewCellDelegate

- (void)suggestionCell:(FTSuggestionCell *)suggestionCell
      didSelectHashtag:(NSString *)hashtag {
    
    [self didTapCancelSearchButtonAction:nil];
    [self.mapVC didTapSearchHashtags:hashtag];
}

- (void)suggestionCell:(FTSuggestionCell *)suggestionCell
         didSelectUser:(PFUser *)aUser {
    
    [self didTapCancelSearchButtonAction:nil];
    [self.mapVC didTapSearchUsers:aUser];
}

@end
