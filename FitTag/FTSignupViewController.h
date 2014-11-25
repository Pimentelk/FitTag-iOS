//
//  FitTagSignupViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"
#import "FTCamViewController.h"

@interface FTSignupViewController : PFSignUpViewController <UITextViewDelegate, UITextFieldDelegate, FTCamViewControllerDelegate>
@property NSString *firstname;
@property NSString *lastname;
//@property NSString *about;
@property UIImage *profilePhoto;
@property BOOL isPasswordConfirmed;
@end
