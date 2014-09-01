//
//  FTEditPhotoViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface FTEditPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoURL;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *tagTextField;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) NSInteger scrollViewHeight;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@end

@implementation FTEditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize delegate;
@synthesize tagTextField;
@synthesize scrollViewHeight;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning on Edit");
}

#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.scrollView addSubview:photoImageView];
 
    CGRect footerRect = [FTPostDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    FTPostDetailsFooterView *footerView = [[FTPostDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.tagTextField = footerView.tagField;
    self.commentTextField.delegate = self;
    self.tagTextField.delegate = self;
    footerView.delegate = self;
    [self.scrollView addSubview:footerView];
    
    scrollViewHeight = photoImageView.frame.origin.y + photoImageView.frame.size.height + footerView.frame.size.height;
    
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
    
    [self shouldUploadImage:self.image];
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

- (NSArray *) checkForHashtag {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:self.commentTextField.text options:0 range:NSMakeRange(0,self.commentTextField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextField.text substringWithRange:wordRange];
        //NSLog(@"Found tag %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (NSMutableArray *) checkForMention {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:self.commentTextField.text options:0 range:NSMakeRange(0,self.commentTextField.text.length)];
    NSMutableArray *matchedResults = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString *word = [self.commentTextField.text substringWithRange:wordRange];
        //NSLog(@"Found mention %@", word);
        [matchedResults addObject:word];
    }
    return matchedResults;
}

- (void)hideCameraView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithName:@"photo.jpeg" data:imageData];
    self.thumbnailFile = [PFFile fileWithName:@"thumbnail.png" data:imageData];
    
    if ([PFUser currentUser]) {
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
    
        [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                
                    if (error) {
                        NSLog(@"self.thumbnailFile saveInBackgroundWithBlock: %@", error);
                    }
                }];
            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }
        
            if (error) {
                NSLog(@"self.photoFile saveInBackgroundWithBlock: %@", error);
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
    
    // Make sure there were no errors creating the image files
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    if ([PFUser currentUser]) {
    
        NSDictionary *userInfo = [NSDictionary dictionary];
        NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
        if (trimmedComment.length != 0) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kFTEditPhotoViewControllerUserInfoCommentKey,nil];
        }
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
        
        // both files have finished uploading
        
        NSMutableArray *hashtags = [[NSMutableArray alloc] initWithArray:[self checkForHashtag]];
        NSMutableArray *mentions = [[NSMutableArray alloc] initWithArray:[self checkForMention]];
        NSLog(@"HashTags: %@",hashtags);
        NSLog(@"Mentions: %@",mentions);
        
        // create a photo object
        PFObject *photo = [PFObject objectWithClassName:kFTPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kFTPhotoUserKey];
        [photo setObject:self.photoFile forKey:kFTPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kFTPhotoThumbnailKey];
    
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
    
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
    
        // Save the Photo PFObject
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
                        [comment setObject:hashtags forKey:kFTActivityHashtag];
                        [comment setObject:mentions forKey:kFTActivityMention];
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
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
    
        // Dismiss this screen
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        NSString *caption = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self setCoverPhoto:self.image Caption:caption];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCoverPhoto:(UIImage *)photo Caption:(NSString *)caption{
    if ([delegate respondsToSelector:@selector(setCoverPhoto:Caption:)]){
        [delegate setCoverPhoto:photo Caption:caption];
    }
}

@end

