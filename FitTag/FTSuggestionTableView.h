//
//  FTSuggestionTableView.h
//  FitTag
//
//  Created by Kevin Pimentel on 12/24/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSuggestionCell.h"

@protocol FTSuggestionTableViewDelegate;
@interface FTSuggestionTableView : UITableView <UITableViewDelegate,UITableViewDataSource,FTSuggestionCellDelegate>

@property (nonatomic, strong) NSMutableArray *suggestions;
@property (nonatomic, strong) NSMutableArray *suggestedUsers;
@property (nonatomic, strong) NSMutableArray *suggestedHashtags;

@property (nonatomic, weak) id<FTSuggestionTableViewDelegate> suggestionDelegate;

- (void)refreshSuggestionsWithType:(NSString *)type;
- (void)updateSuggestionWithText:(NSString *)searchText AndType:(NSString *)aType;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style type:(NSString *)type;
@end

@protocol FTSuggestionTableViewDelegate <NSObject>
@required

/*!
 Sent to the delegate when a user is selected
 @param user the PFUser associated with this selection
 */
- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectUser:(PFUser *)user completeString:(NSString *)completeString;

/*!
 Sent to the delegate when a user is selected
 @param user the PFUser associated with this selection
 */
- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectHashtag:(NSString *)hashtag completeString:(NSString *)completeString;

@end