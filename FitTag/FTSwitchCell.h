//
//  UITableViewCell+FTSocialCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTSwitchTypeNone = 0,
    FTSwitchTypeFacebook = 1 << 0,
    FTSwitchTypeTwitter = 1 << 1,
    FTSwitchTypeComment = 1 << 2,
    FTSwitchTypeLike = 1 << 3,
    FTSwitchTypeFollow = 1 << 4,
    FTSwitchTypeMention = 1 << 5,
} FTSwitchType;

@protocol FTSwitchCellDelegate;
@interface FTSwitchCell : UITableViewCell

/*! type param */
@property (nonatomic, assign) FTSwitchType type;

/*! FTSocialCellDelegate Delegate */
@property (nonatomic,weak) id <FTSwitchCellDelegate> delegate;

@end

@protocol FTSwitchCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the facebook switch is changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeFacebookSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the twitter switch changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeTwitterSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the like switch changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeLikeSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the comment switch changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeCommentSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the mention switch changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeMentionSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the follow switch changes
 */
- (void)switchCell:(FTSwitchCell *)switchCell didChangeFollowSwitch:(UISwitch *)lever;

@end