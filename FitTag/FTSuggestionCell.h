//
//  FTSuggestionTableViewCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 12/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FTSuggestionCellDelegate;
@interface FTSuggestionCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic, weak) id<FTSuggestionCellDelegate> delegate;
@end

@protocol FTSuggestionCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the cell view is tapped
 @param user the user that was selected
 */
- (void)suggestionCell:(FTSuggestionCell *)suggestionCell didSelectUser:(PFUser *)user;

/*!
 Sent to the delegate when the cell view is tapped
 @param hashtag the hashtag that was selected
 */
- (void)suggestionCell:(FTSuggestionCell *)suggestionCell didSelectHashtag:(NSString *)hashtag;

@end
