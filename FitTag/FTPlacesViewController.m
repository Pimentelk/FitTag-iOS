//
//  FTPlacesTableViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/22/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPlacesViewController.h"

#define HEADER_HEIGHT 44
#define FOOTER_HEIGHT 44

@interface FTPlacesViewController ()
@property (nonatomic, strong) NSMutableArray *matches;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) UIView *addPlaceContainerView;
@property (nonatomic, strong) PFObject *selectedPlace;
@end

@implementation FTPlacesViewController
@synthesize placesSearchbar;
@synthesize matches;
@synthesize places;
@synthesize addPlaceContainerView;
@synthesize delegate;
@synthesize selectedPlace;
@synthesize geoPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    matches = [[NSMutableArray alloc] init];
    places = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    CGSize tableSize = self.tableView.frame.size;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableSize.width, HEADER_HEIGHT * 2)];
    [headerView setBackgroundColor:FT_GRAY];
    
    placesSearchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableSize.width, HEADER_HEIGHT)];
    [placesSearchbar setPlaceholder:@"FitTag Places"];
    [placesSearchbar setBackgroundColor:[UIColor yellowColor]];
    [placesSearchbar setDelegate:self];
    [placesSearchbar becomeFirstResponder];
    
    // Container View
    UIView *addPlaceView = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, tableSize.width, HEADER_HEIGHT)];
    
    // Add place button +
    UIButton *addPlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addPlaceButton setFrame:CGRectMake(0, 0, FOOTER_HEIGHT, FOOTER_HEIGHT)];
    [addPlaceButton setTitle:@"+" forState:UIControlStateNormal];
    [addPlaceButton setTitleColor:FT_RED forState:UIControlStateNormal];
    [addPlaceButton setBackgroundColor:[UIColor clearColor]];
    [addPlaceButton.titleLabel setFont:BENDERSOLID(40)];
    [addPlaceButton addTarget:self action:@selector(didTapAddPlaceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAddPlaceButtonAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    
    
    // Override the left idnicator
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                    action:@selector(didTapCancelButtonAction:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    // Override the right idnicator
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                                    action:@selector(didTapDoneButtonAction:)];
    [doneButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    // UILabel
    UILabel *addPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(FOOTER_HEIGHT, 0, tableSize.width-FOOTER_HEIGHT, FOOTER_HEIGHT)];
    [addPlaceLabel setText:@"Add new FitTag place"];
    [addPlaceLabel setBackgroundColor:[UIColor clearColor]];
    [addPlaceLabel setTextColor:FT_RED];
    [addPlaceLabel setFont:BENDERSOLID(20)];
    [addPlaceLabel setUserInteractionEnabled:YES];
    [addPlaceLabel addGestureRecognizer:tapGesture];
    
    // Add views to container
    [addPlaceView addSubview:addPlaceButton];
    [addPlaceView addSubview:addPlaceLabel];
    
    [headerView addSubview:placesSearchbar];
    [headerView addSubview:addPlaceView];
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView.tableHeaderView setHidden:NO];
    
    [self searchForResults:nil];
}

- (void)searchForResults:(NSString *)text {
    
    PFQuery *placeQuery = [PFQuery queryWithClassName:kFTPlaceClassKey];
    
    if (text) {
        [placeQuery whereKey:kFTPlaceNameKey containsString:text];
    }
    
    [placeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.places removeAllObjects];
            [self.matches removeAllObjects];
            
            [self.places addObjectsFromArray:objects];
            [self.matches addObjectsFromArray:objects];
            
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //NSLog(@"searchText:%@",searchBar.text);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (searchBar.text.length <= 0 || [searchBar.text isEqualToString:EMPTY_STRING]) {
        [FTUtility showHudMessage:@"Type something!" WithDuration:2];
        return;
    }
    
    [placesSearchbar resignFirstResponder];
    
    // normal
    PFQuery *placeQuery = [PFQuery queryWithClassName:kFTPlaceClassKey];
    [placeQuery whereKey:kFTPlaceNameKey containsString:searchBar.text];
    
    // lower
    PFQuery *placeQueryLower = [PFQuery queryWithClassName:kFTPlaceClassKey];
    [placeQueryLower whereKey:kFTPlaceNameKey containsString:[searchBar.text lowercaseString]];
    
    // capital
    PFQuery *placeQueryCapital = [PFQuery queryWithClassName:kFTPlaceClassKey];
    [placeQueryCapital whereKey:kFTPlaceNameKey containsString:[searchBar.text capitalizedString]];
    
    // uppercase
    PFQuery *placeQueryUpper = [PFQuery queryWithClassName:kFTPlaceClassKey];
    [placeQueryUpper whereKey:kFTPlaceNameKey containsString:[searchBar.text uppercaseString]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[placeQuery,placeQueryLower,placeQueryCapital,placeQueryUpper]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [self.matches removeAllObjects];
            [self.matches addObjectsFromArray:objects];
            
            NSLog(@"objects:%@",objects);
            
            NSMutableArray *names = [[NSMutableArray alloc] init];
            
            // Get array of names
            for (PFObject *place in places) {
                [names addObject:[place objectForKey:kFTPlaceNameKey]];
            }
            
            for (PFObject *match in matches) {
                
                NSString *name = [match objectForKey:kFTPlaceNameKey];
                
                if (![names containsObject:name]) {
                    NSLog(@"added");
                    [places addObject:match];
                }
            }
            
            [self.tableView reloadData];
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [matches removeAllObjects];
    
    if ([searchText isEqualToString:EMPTY_STRING]) {
        [matches addObjectsFromArray:places];
        [self.tableView reloadData];
        return;
    }
    
    for (PFObject *place in places) {
        NSString *match = [place objectForKey:kFTPlaceNameKey];
        NSRange substringRange = [[match lowercaseString] rangeOfString:[searchText lowercaseString]];
        if (substringRange.location != NSNotFound) {
            [matches addObject:place];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - ()

- (void)didTapCancelButtonAction:(id)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(placesViewController:didTapCancelButton:)]) {
        [delegate placesViewController:self didTapCancelButton:sender];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapDoneButtonAction:(id)sender {
    
    if (selectedPlace) {
        if (delegate && [delegate respondsToSelector:@selector(placesViewController:didTapSelectPlace:)]) {
            [delegate placesViewController:self didTapSelectPlace:selectedPlace];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddPlaceButtonAction:(id)sender {
    //NSLog(@"didTapAddPlaceButtonAction:");
    FTAddPlaceViewController *addPlaceViewController = [[FTAddPlaceViewController alloc] init];
    [addPlaceViewController setDelegate:self];
    [addPlaceViewController setGeoPoint:geoPoint];
    [self.navigationController pushViewController:addPlaceViewController animated:YES];
    
    /*
     if (delegate && [delegate respondsToSelector:@selector(placesViewController:didTapAddNewPlaceButton:)]) {
     [delegate placesViewController:self didTapAddNewPlaceButton:sender];
     }
     */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return matches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [(UITableViewCell *)[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DataCell"];
    
    PFObject *place = (PFObject *)[matches objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@",[place objectForKey:kFTPlaceNameKey]];
    cell.textLabel.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath:%@",[matches objectAtIndex:indexPath.row]);
    PFObject *place = (PFObject *)[matches objectAtIndex:indexPath.row];
    selectedPlace = place;
}

#pragma mark - FTAddPlaceViewController

- (void)addPlaceViewController:(FTAddPlaceViewController *)addPlaceViewController didAddNewplace:(PFObject *)place location:(PFObject *)location {
    NSLog(@"addPlaceViewController:didAddNewplace:location:");
    
    [self.navigationController popViewControllerAnimated:YES];
    
    selectedPlace = place;
    [placesSearchbar setText:[place objectForKey:kFTPlaceNameKey]];
    [places addObject:place];
    
    [self.tableView reloadData];
}

@end
