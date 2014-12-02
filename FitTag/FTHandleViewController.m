//
//  FTHandleViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/30/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTHandleViewController.h"

@interface FTHandleViewController()
@property (nonatomic, strong) UITextField *handleTextField;
@end

@implementation FTHandleViewController
@synthesize handleTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureToHideKeyboardAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureToHideKeyboardAction:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.view setGestureRecognizers:@[ tapGesture, swipeGesture ]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, self.view.frame.size.width-20, 40)];
    [headerLabel setNumberOfLines:0];
    [headerLabel setFont:BENDERSOLID(22)];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setTextColor:[UIColor blackColor]];
    [headerLabel setText:@"User Handle"];
    
    [self.view addSubview:headerLabel];
    
    UILabel *handleMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, self.view.frame.size.width-20, 100)];
    [handleMessage setNumberOfLines:0];
    [handleMessage setFont:BENDERSOLID(14)];
    [handleMessage setTextAlignment:NSTextAlignmentCenter];
    [handleMessage setTextColor:[UIColor blackColor]];
    [handleMessage setText:@"Handle"];
    [handleMessage setText:@"A handle is required. The handle is the name by which you choose to represent yourself. You can change your handle in the settings at any time."];
    
    [self.view addSubview:handleMessage];
    
    CGFloat handleTextFieldY = handleMessage.frame.size.height + handleMessage.frame.origin.y + 10;
    handleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, handleTextFieldY, self.view.frame.size.width-20, 40)];
    [handleTextField setTextColor:[UIColor blackColor]];
    [handleTextField setBackgroundColor:FT_GRAY];
    [handleTextField setLeftViewMode:UITextFieldViewModeAlways];
    [handleTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [handleTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [handleTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [self.view addSubview:handleTextField];
    
    UIButton *saveHandleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveHandleButton setFrame:CGRectMake((self.view.frame.size.width - 80) / 2, handleTextField.frame.origin.y + handleTextField.frame.size.height + 20, 80, 40)];
    [saveHandleButton addTarget:self action:@selector(didTapSaveHandleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveHandleButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveHandleButton setBackgroundColor:FT_GRAY];
    [saveHandleButton setClipsToBounds:YES];
    [saveHandleButton.layer setCornerRadius:10];
    [saveHandleButton.titleLabel setFont:BENDERSOLID(18)];
    [saveHandleButton.titleLabel setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:saveHandleButton];
}

- (void)didGestureToHideKeyboardAction:(UIButton *)button {
    [handleTextField resignFirstResponder];
}

- (void)didTapSaveHandleButtonAction:(UIButton *)button {
    
    PFUser *user = [PFUser currentUser];
    
    if (handleTextField.text.length <= 0) {
        [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_EMPTY WithDuration:2];
        return;
    }
    
    if (handleTextField.text.length > 15) {
        [FTUtility showHudMessage:HUD_MESSAGE_CHARACTER_LIMIT WithDuration:2];
        return;
    }
    
    NSCharacterSet *alphaNumericSet = [NSCharacterSet alphanumericCharacterSet];
    if ([[handleTextField.text stringByTrimmingCharactersInSet:alphaNumericSet] isEqualToString:EMPTY_STRING]) {
        [user setObject:[handleTextField.text lowercaseString] forKey:kFTUserDisplayNameKey];
    } else {
        [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_INVALID WithDuration:2];
        return;
    }
    
    if (handleTextField.text.length > 0 && handleTextField.text.length <= 15) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_UPDATED WithDuration:2];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            switch (error.code) {
                case 142:
                    [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_TAKEN WithDuration:2];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}

@end
