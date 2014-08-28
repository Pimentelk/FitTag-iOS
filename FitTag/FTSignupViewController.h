//
//  FitTagSignupViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"

@interface FTSignupViewController : PFSignUpViewController <UITextViewDelegate, UITextFieldDelegate, FTEditPhotoViewControllerDelegate>
@property NSString *firstname;
@property NSString *lastname;
@property NSString *about;
@property UIImage *coverPhoto;
@property BOOL isPasswordConfirmed;
@end
