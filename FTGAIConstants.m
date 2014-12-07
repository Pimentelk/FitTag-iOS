//
//  FTGAIConstants.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/6/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTGAIConstants.h"

#pragma mark - GAI Event Catagory
NSString *const kFTTrackEventCatagoryTypeUIAction           = @"ui_action";
NSString *const kFTTrackEventCatagoryTypeError              = @"error";


#pragma mark - GAI Event Action
NSString *const kFTTrackEventActionTypeButtonPress          = @"button_press";
NSString *const kFTTrackEventActionTypeUserSignUp           = @"user_signup";
NSString *const kFTTrackEventActionTypeUserLogIn            = @"user_login";


#pragma mark - GAI Event Label
NSString *const kFTTrackEventLabelTypeTwitter               = @"twitter_button";
NSString *const kFTTrackEventLabelTypeFacebook              = @"facebook_button";

NSString *const kFTTrackEventLabelTypeSignUp                = @"signup_button";
NSString *const kFTTrackEventLabelTypeSignUpBegin           = @"signup_begin";
NSString *const kFTTrackEventLabelTypeSignUpSuccess         = @"signup_success";
NSString *const kFTTrackEventLabelTypeSignUpShould          = @"signup_should";
NSString *const kFTTrackEventLabelTypeSignUpCancel          = @"signup_cancel";
NSString *const kFTTrackEventLabelTypeSignUpSubmit          = @"signup_submit";

NSString *const kFTTrackEventLabelTypeLogIn                 = @"login_button";
NSString *const kFTTrackEventLabelTypeLogInCancel           = @"login_cancel";
NSString *const kFTTrackEventLabelTypeLogInShould           = @"login_should";
NSString *const kFTTrackEventLabelTypeLogInSuccess          = @"login_success";

NSString *const kFTTrackEventLabelTypeForgotPassword        = @"fotgot_password_button";
