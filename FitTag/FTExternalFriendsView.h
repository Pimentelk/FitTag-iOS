//
//  FTExternalFriendsView.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//
/*
 * FTExternalFriendsView is a view to facilitate viralability
 * 1) Users can send group messages to their phone contacts
 * 2) Users can post to their twitter
 * 3) Users can share on this facebook
 */

#import "FTContactCell.h"

@interface FTExternalFriendsView : UIView <UITableViewDataSource,UITableViewDelegate,FTContactCellDelegate>
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
@end
