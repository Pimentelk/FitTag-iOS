//
//  ProfileViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTBusinessProfileHeaderView.h"
#import <MessageUI/MessageUI.h>

@interface FTBusinessProfileViewController : UICollectionViewController <FTBusinessProfileHeaderViewDelegate,MFMailComposeViewControllerDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) PFUser *business;
@end
