//
//  FTInviteFriendsViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "FTSocialMediaFriendsView.h"

@interface FTInviteFriendsViewController : UIViewController <MFMessageComposeViewControllerDelegate,FTSocialMediaFriendsViewDelegate>
@property (nonatomic) BOOL isSettingsChild;
@end
