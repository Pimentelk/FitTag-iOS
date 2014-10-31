//
//  FTFindFriendsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "FTFindFriendsCell.h"

@interface FTFindFriendsViewController : PFQueryTableViewController <FTFindFriendsCellDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@end
