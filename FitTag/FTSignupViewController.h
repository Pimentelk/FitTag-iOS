//
//  FitTagSignupViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"
#import "FTCamViewController.h"


@interface FTSignupViewController : PFSignUpViewController <UITextViewDelegate, UITextFieldDelegate,FTCamViewControllerDelegate>
//@property (nonatomic,strong) NSString *firstname;
//@property (nonatomic,strong) NSString *lastname;
@property (nonatomic,strong) UIImage *profilePhoto;
//@property (nonatomic) BOOL isPasswordConfirmed;
//@property NSString *about;

- (void)didTapHideKeyboardAction;
@end
