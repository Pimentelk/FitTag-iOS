//
//  FTHandleViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 11/30/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#include "FTCamViewController.h"

@interface FTHandleViewController : UIViewController <UITextFieldDelegate,FTCamViewControllerDelegate>

@property (nonatomic, strong) UIImage *profilePhoto;

@end
