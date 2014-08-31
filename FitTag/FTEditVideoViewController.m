//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditVideoViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTEditVideoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSData *video;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *tagTextField;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier videoPostBackgroundTaskId;
@property (nonatomic, assign) NSInteger scrollViewHeight;
@property (nonatomic, strong) PFFile *videoFile;
@property (nonatomic, strong) PFFile *imageFile;
@end

@implementation FTEditVideoViewController
@synthesize scrollView;
@synthesize commentTextField;
@synthesize fileUploadBackgroundTaskId;
@synthesize videoPostBackgroundTaskId;
@synthesize tagTextField;
@synthesize scrollViewHeight;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithVideo:(NSData *)aVideo {
    NSLog(@"FTEditVideoViewController::initWithVideo:");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aVideo) {
            return nil;
        }
        
        self.video = aVideo;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.videoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning on Edit");
}

#pragma mark - UIViewController

- (void)loadView {
    NSLog(@"FTEditVideoViewController::loadView");
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    UIImageView *videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [videoImageView setBackgroundColor:[UIColor blackColor]];
    //[photoImageView setImage:self.video];
    [videoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:videoImageView];
    
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    footerRect.origin.y = videoImageView.frame.origin.y + videoImageView.frame.size.height;
    
    FTPostDetailsFooterView *footerView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.tagTextField = footerView.tagField;
    self.commentTextField.delegate = self;
    self.tagTextField.delegate = self;
    footerView.delegate = self;
    [self.scrollView addSubview:footerView];
    
    scrollViewHeight = videoImageView.frame.origin.y + videoImageView.frame.size.height + footerView.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, scrollViewHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NavigationBar & ToolBar
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.toolbar setHidden:YES];
    [self.navigationItem setTitle: @"TAG YOUR FIT"];
    [self.navigationItem setHidesBackButton:NO];
    
    // Override the back idnicator
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(hideCameraView:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self shouldUploadVideo:self.video];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
}

#pragma mark - FTPhotoPostDetailsFooterViewDelegate

-(void)facebookShareButton:(id)sender{
    // Share to facebook
}

-(void)twitterShareButton:(id)sender{
    // Share to twitter
}

-(void)sendPost:(id)sender{
    [self doneButtonAction:sender];
}

#pragma mark - ()

- (void)hideCameraView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldUploadVideo:(NSData *)aVideo {
    NSLog(@"FTEditVideoViewController::shouldUploadVideo:");
    if(!aVideo){
        return NO;
    }
    
    self.videoFile = [PFFile fileWithName:@"video.mov" data:aVideo];
    
    if ([PFUser currentUser]) {
        // Request a background execution task to allow us to finish uploading the video even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        
        [self.videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!succeeded){
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }
            
            if(error){
                NSLog(@"self.videoFile saveInBackgroundWithBlock: %@", error);
            }
        }];
    }
    
    return YES;
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

- (void)doneButtonAction:(id)sender {
    NSLog(@"FTEditVideoViewController::doneButtonAction:%@",sender);
    // Make sure there were no errors creating the image files
    if (!self.videoFile){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    if ([PFUser currentUser]) {
        
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kFTEditVideoViewControllerUserInfoCommentKey,nil];
        }
        
        // create a video object
        PFObject *video = [PFObject objectWithClassName:kFTVideoClassKey];
        [video setObject:[PFUser currentUser] forKey:kFTVideoUserKey];
        //[video setObject:self.imageFile forKey:kFTVideoImageKey];
        [video setObject:self.videoFile forKey:kFTVideoKey];
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *videoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [videoACL setPublicReadAccess:YES];
        video.ACL = videoACL;
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.videoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.videoPostBackgroundTaskId];
        }];

        // Save the video PFObject
        [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[FTCache sharedCache] setAttributesForVideo:video likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                
                // userInfo might contain any caption which might have been posted by the uploader
                if (userInfo) {
                    NSString *commentText = [userInfo objectForKey:kFTEditVideoViewControllerUserInfoCommentKey];
                    
                    if (commentText && commentText.length != 0) {
                        // create and save photo caption
                        PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
                        [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
                        [comment setObject:video forKey:kFTActivityPhotoKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                        [comment setObject:commentText forKey:kFTActivityContentKey];
                        
                        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [ACL setPublicReadAccess:YES];
                        comment.ACL = ACL;
                        
                        [comment saveEventually];
                        [[FTCache sharedCache] incrementCommentCountForVideo:video];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification object:video];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Couldn't post your video"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Dismiss", nil] show];
            }
        }];
        
        
        /*
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                [[FTCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                
                // userInfo might contain any caption which might have been posted by the uploader
                if (userInfo) {
                    NSString *commentText = [userInfo objectForKey:kFTEditPhotoViewControllerUserInfoCommentKey];
                    
                    if (commentText && commentText.length != 0) {
                        // create and save photo caption
                        PFObject *comment = [PFObject objectWithClassName:kFTActivityClassKey];
                        [comment setObject:kFTActivityTypeComment forKey:kFTActivityTypeKey];
                        [comment setObject:photo forKey:kFTActivityPhotoKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityFromUserKey];
                        [comment setObject:[PFUser currentUser] forKey:kFTActivityToUserKey];
                        [comment setObject:commentText forKey:kFTActivityContentKey];
                        
                        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        [ACL setPublicReadAccess:YES];
                        comment.ACL = ACL;
                        
                        [comment saveEventually];
                        [[FTCache sharedCache] incrementCommentCountForPhoto:photo];
                    }
                } else {
                    [photo saveEventually];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FTTabBarControllerDidFinishEditingPhotoNotification object:photo];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [[UIApplication sharedApplication] endBackgroundTask:self.videoPostBackgroundTaskId];
        }];
        */
        
        // Dismiss this screen
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        //NSString *caption = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //[self setCoverPhoto:self.video Caption:caption];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

