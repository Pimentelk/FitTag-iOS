//
//  FTSuggestionTableView.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSuggestionTableView.h"

@interface FTSuggestionTableView()
@property (nonatomic,strong) NSString *searchString;
@end

@implementation FTSuggestionTableView
@synthesize suggestions;
@synthesize suggestedUsers;
@synthesize suggestedHashtags;
@synthesize suggestionDelegate;
@synthesize searchString;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    return [self initWithFrame:frame style:style type:SUGGEST_ALL];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style type:(NSString *)type {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        // arrays
        suggestions = [[NSMutableArray alloc] init];
        suggestedUsers = [[NSMutableArray alloc] init];
        suggestedHashtags = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setDataSource:self];
        [self setDelegate:self];
        [self searchSuggestionsWithType:type];
    }
    
    return self;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SuggestionCell = @"SuggestionCell";
    
    FTSuggestionCell *cell = (FTSuggestionCell *)[tableView dequeueReusableCellWithIdentifier:SuggestionCell];
    if (cell == nil) {
        cell = [[FTSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SuggestionCell];
        [cell setDelegate:self];
    }
    
    if ([[suggestions objectAtIndex:indexPath.row] isKindOfClass:[PFUser class]]) {
        [cell setUser:[suggestions objectAtIndex:indexPath.row]];
    } else {
        [cell setHashtag:[suggestions objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

#pragma mark - FTSuggestionCellDelegate

- (void)suggestionView:(FTSuggestionCell *)suggestionView didSelectUser:(PFUser *)user {
    if (suggestionDelegate && [suggestionDelegate respondsToSelector:@selector(suggestionTableView:didSelectUser:completeString:)]) {
        [suggestionDelegate suggestionTableView:self didSelectUser:user completeString:searchString];
    }
}

- (void)suggestionView:(FTSuggestionCell *)suggestionView didSelectHashtag:(NSString *)hashtag {
    if (suggestionDelegate && [suggestionDelegate respondsToSelector:@selector(suggestionTableView:didSelectHashtag:completeString:)]) {
        [suggestionDelegate suggestionTableView:self didSelectHashtag:hashtag completeString:searchString];
    }
}

#pragma mark - ()

- (void)refreshSuggestionsWithType:(NSString *)type {
    
    [suggestions removeAllObjects];
    
    if ([type isEqualToString:SUGGESTION_TYPE_USERS]) {
        [suggestions addObjectsFromArray:suggestedUsers];
    } else if ([type isEqualToString:SUGGESTION_TYPE_HASHTAGS]) {
        [suggestions addObjectsFromArray:suggestedHashtags];
    } else if ([type isEqualToString:SUGGESTION_TYPE_PLACES]) {
        //[suggestions addObjectsFromArray:suggestedUsers];
    } else {
        return;
    }
    
    [self reloadData];
}

- (void)updateSuggestionWithText:(NSString *)searchText
                         AndType:(NSString *)aType {
    
    searchString = searchText;
    
    [suggestions removeAllObjects];
    
    if ([aType isEqualToString:SUGGESTION_TYPE_USERS]) {
        
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:suggestedUsers];
            [self reloadData];
            return;
        }
        
        for (PFUser *user in suggestedUsers) {
            NSString *displayName = [user objectForKey:kFTUserDisplayNameKey];
            NSRange substringRange = [[displayName lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:user];
            }
        }
        
    } else {
        
        if ([searchText isEqualToString:EMPTY_STRING]) {
            [suggestions addObjectsFromArray:suggestedHashtags];
            [self reloadData];
            return;
        }
        
        for (NSString *hashtag in suggestedHashtags) {
            NSRange substringRange = [[hashtag lowercaseString] rangeOfString:[searchText lowercaseString]];
            if (substringRange.location != NSNotFound) {
                [suggestions addObject:hashtag];
            }
        }
        
    }
    
    [self reloadData];
}

- (void)searchSuggestionsWithType:(NSString *)type {
    
    PFQuery *usersQuery = [PFQuery queryWithClassName:kFTUserClassKey];
    [usersQuery  whereKeyExists:kFTUserDisplayNameKey];
    [usersQuery  whereKeyExists:kFTUserProfilePicSmallKey];
    
    // If type is business
    if ([type isEqualToString:SUGGEST_BUSINESS]) {
        [usersQuery whereKey:kFTUserTypeKey equalTo:kFTUserTypeBusiness];
    }
    
    [usersQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *userObjects, NSError *error) {
        if (!error) {
            
            NSMutableArray *userSuggestions = [[NSMutableArray alloc] initWithArray:userObjects];
            NSMutableArray *displayNames = [[NSMutableArray alloc] init];
            
            // Get array of names
            for (PFUser *user in suggestedUsers) {
                [displayNames addObject:[user objectForKey:kFTUserDisplayNameKey]];
            }
            
            for (PFUser *userSuggestion in userSuggestions) {
                
                NSString *displayName = [userSuggestion objectForKey:kFTUserDisplayNameKey];
                
                if (![displayNames containsObject:displayName]) {
                    [suggestedUsers addObject:userSuggestion];
                }
            }
        }
        
        if (error) {
            NSLog(@"error:%@",error);
        }
    }];
    
    PFQuery *hashtagQuery = [PFQuery queryWithClassName:kFTPostClassKey];
    [hashtagQuery whereKeyExists:kFTPostHashTagKey];
    [hashtagQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [hashtagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //[self.suggestions removeAllObjects];
            
            NSMutableArray *hashtagSuggestions = [[NSMutableArray alloc] initWithArray:objects]; // array of PFObjects
            
            for (PFObject *object in hashtagSuggestions) { // loop throught PFObjects
                NSMutableArray *postHashtags = [object objectForKey:kFTPostHashTagKey]; // array of hashtags
                for (NSString *postHashtag in postHashtags) { // loop through array of hashtags
                    if (![suggestedHashtags containsObject:postHashtag]) { // if unique insert into our array else skip
                        //NSLog(@"postHashtag:%@",postHashtag);
                        [suggestedHashtags addObject:postHashtag];
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

@end
