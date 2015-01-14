//
//  FTHandleViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/30/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTHandleViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTHandleViewController()
@property (nonatomic, strong) UITextField *handleTextField;
@property (nonatomic, strong) UIButton *profileImageButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger scrollViewHeight;
@end

@implementation FTHandleViewController
@synthesize handleTextField;
@synthesize profileImageButton;
@synthesize scrollView;
@synthesize scrollViewHeight;

- (void)dealloc {
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    [self.view setBackgroundColor:FT_RED];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.scrollView setBackgroundColor:FT_RED];
    [self.scrollView setScrollEnabled:YES];
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureToHideKeyboardAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didGestureToHideKeyboardAction:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.scrollView setGestureRecognizers:@[ tapGesture, swipeGesture ]];
    
    // Set the logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:FITTAG_LOGO]];
    [logo setCenter:CGPointMake(160, 80)];
    [self.scrollView addSubview:logo];
    
    // Set the profile image button
    profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileImageButton setBackgroundColor:FT_GRAY];
    [profileImageButton addTarget:self action:@selector(didTapLoadCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [profileImageButton setClipsToBounds:YES];
    [profileImageButton.layer setCornerRadius:CORNERRADIUS(TAKE_PHOTO_BUTTON)];
    [profileImageButton setImage:[UIImage imageNamed:IMAGE_PROFILE_EMPTY] forState:UIControlStateNormal];
    
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser objectForKey:kFTUserProfilePicSmallKey]) {
        PFFile *file = [currentUser objectForKey:kFTUserProfilePicSmallKey];
        if (file && ![file isEqual:[NSNull null]]) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    [self.profileImageButton setImage:photo forState:UIControlStateNormal];
                }
            }];
        }
    }
    
    [self.scrollView addSubview:profileImageButton];
    
    CGRect profileImageButtonRect = CGRectMake(0, 0, TAKE_PHOTO_BUTTON, TAKE_PHOTO_BUTTON);
    [profileImageButton setFrame:profileImageButtonRect];
    
    CGFloat logoEnds = (logo.frame.size.height * 2) + logo.center.y;
    [profileImageButton setCenter:CGPointMake(160, logoEnds)];
    
    // Set the handle message
    CGFloat handleMessageY = profileImageButton.frame.size.height + profileImageButton.frame.origin.y;
    
    UILabel *handleMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, handleMessageY, scrollView.frame.size.width-20, 100)];
    [handleMessage setNumberOfLines:0];
    [handleMessage setFont:SYSTEMFONTBOLD(14)];
    [handleMessage setTextAlignment:NSTextAlignmentCenter];
    [handleMessage setTextColor:[UIColor whiteColor]];
    [handleMessage setText:@"Handle"];
    [handleMessage setText:@"A handle is required. The handle is the name by which you choose to represent yourself. You can change your handle in the settings at any time."];
    
    [self.scrollView addSubview:handleMessage];
    
    CGFloat handleTextFieldY = handleMessage.frame.size.height + handleMessage.frame.origin.y + 10;
    handleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, handleTextFieldY, scrollView.frame.size.width-20, 40)];
    [handleTextField setTextColor:[UIColor blackColor]];
    [handleTextField setBackgroundColor:[UIColor whiteColor]];
    [handleTextField setLeftViewMode:UITextFieldViewModeAlways];
    [handleTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [handleTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [handleTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [handleTextField setPlaceholder:@"User Handle"];
    
    [self.scrollView addSubview:handleTextField];
    
    // Submit button
    CGFloat submitHandleY = handleTextField.frame.origin.y + handleTextField.frame.size.height + 20;
    UIButton *submitHandleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitHandleButton setFrame:CGRectMake(10, submitHandleY, scrollView.frame.size.width-20, 45)];
    [submitHandleButton addTarget:self action:@selector(didTapSubmitHandleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [submitHandleButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitHandleButton setBackgroundColor:[UIColor brownColor]];
    [submitHandleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitHandleButton setClipsToBounds:YES];
    [submitHandleButton.layer setCornerRadius:10];
    [submitHandleButton.titleLabel setFont:MULIREGULAR(18)];
    [submitHandleButton.titleLabel setTextColor:[UIColor whiteColor]];
    
    [self.scrollView addSubview:submitHandleButton];
    
    // set the scrollview height
    scrollViewHeight = self.view.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, scrollViewHeight)];
}

- (void)didGestureToHideKeyboardAction:(UIButton *)button {
    [handleTextField resignFirstResponder];
}

- (void)didTapSubmitHandleButtonAction:(UIButton *)button {
    
    PFUser *user = [PFUser currentUser];
    
    if (handleTextField.text.length <= 0) {
        [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_EMPTY WithDuration:2];
        return;
    }
    
    if (handleTextField.text.length > 15) {
        [FTUtility showHudMessage:HUD_MESSAGE_CHARACTER_LIMIT WithDuration:2];
        return;
    }
    
    if (self.profilePhoto) {
        UIImage *signupProfilePhoto = self.profilePhoto;
        UIImage *resizedImage = [signupProfilePhoto resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                         bounds:CGSizeMake(640,640)
                                                           interpolationQuality:kCGInterpolationHigh];
        
        UIImage *thumbImage = [signupProfilePhoto thumbnailImage:86.0f
                                               transparentBorder:0.0f
                                                    cornerRadius:10.0f
                                            interpolationQuality:kCGInterpolationDefault];
        
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
        NSData *thumbnailImageData = UIImagePNGRepresentation(thumbImage);
        
        if (imageData && thumbnailImageData) {
            PFFile *mediumPicFile = [PFFile fileWithName:@"medium.jpeg" data:imageData];
            [user setObject:mediumPicFile forKey:kFTUserProfilePicMediumKey];
            
            PFFile *smallPicFile = [PFFile fileWithName:@"small.jpeg" data:thumbnailImageData];
            [user setObject:smallPicFile forKey:kFTUserProfilePicSmallKey];
        }        
    }
    
    NSCharacterSet *alphaNumericUnderscoreSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    alphaNumericUnderscoreSet = [alphaNumericUnderscoreSet invertedSet];
    handleTextField.text = [handleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSRange range = [handleTextField.text rangeOfCharacterFromSet:alphaNumericUnderscoreSet];
    if (range.location != NSNotFound) {
        [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_INVALID WithDuration:2];
        return;
    }
    
    [user setObject:[handleTextField.text lowercaseString] forKey:kFTUserDisplayNameKey];
    if (handleTextField.text.length > 0 && handleTextField.text.length <= 15) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_UPDATED WithDuration:2];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            NSLog(@"FTHandleViewController::Error:%@",error.description);
            switch (error.code) {
                case 142:
                    [FTUtility showHudMessage:HUD_MESSAGE_HANDLE_TAKEN WithDuration:2];
                    break;
                case 101:
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [FTUtility showHudMessage:@"User not found" WithDuration:2];
                    [[UIApplication sharedApplication].delegate performSelector:@selector(logOut)];
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

- (void)didTapLoadCameraButtonAction:(id)sender {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isProfilePciture = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[camViewController] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height * 3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,scrollViewHeight);
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

#pragma mark - FTEditPhotoViewControllerDelegate

- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo {
    //NSLog(@"%@::camViewController:photo:",VIEWCONTROLLER_SIGNUP);
    self.profilePhoto = photo;
    [self.profileImageButton setImage:photo forState:UIControlStateNormal];
}

@end
