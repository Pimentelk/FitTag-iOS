//
//  ProfileViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface FTBusinessProfileViewController : UICollectionViewController <MFMailComposeViewControllerDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) PFUser *business;
@end
