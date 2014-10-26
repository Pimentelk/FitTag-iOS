//
//  UITableViewCell+FTSocialCell.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

typedef enum {
    FTSocialMediaTypeNone = 0,
    FTSocialMediaTypeFacebook = 1 << 0,
    FTSocialMediaTypeTwitter = 1 << 1
} FTSocialMediaType;

@protocol FTSocialCellDelegate;
@interface FTSocialCell : UITableViewCell

/*! type param */
@property (nonatomic, assign) FTSocialMediaType type;

/*! FTGalleryCell Delegate */
@property (nonatomic,weak) id <FTSocialCellDelegate> delegate;

@end

@protocol FTSocialCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the facebook button is tapped
 */
- (void)socialCell:(FTSocialCell *)socialCell didChangeFacebookSwitch:(UISwitch *)lever;

/*!
 Sent to the delegate when the twitter button is tapped
 */
- (void)socialCell:(FTSocialCell *)socialCell didChangeTwitterSwitch:(UISwitch *)lever;

@end