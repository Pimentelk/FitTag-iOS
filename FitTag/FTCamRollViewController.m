//
//  FTCamRollViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCamViewController.h"
#import "FTCamRollViewController.h"
#import "ImageCustomNavigationBar.h"
#import "FTEditPhotoViewController.h"
#import "FTOverlayView.h"
#import "FTToolBar.h"
#import "FTEditPostViewController.h"

@interface FTCamRollViewController () {
    ELCImagePickerController *elcPicker;
}

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation FTCamRollViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"FTCamRollViewController::viewDidLoad");
    
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.view addSubview:self.scrollView];
    
    // Set controller background color
    self.view.backgroundColor = [UIColor whiteColor];
    
    // NavigationBar & ToolBar
    [self.navigationItem setTitle: @"Camera Roll"];
    [self.navigationItem setHidesBackButton:TRUE];

    // Close the camera roll
    UIBarButtonItem *hideCameraRollButtonItem = [[UIBarButtonItem alloc] init];
    [hideCameraRollButtonItem setStyle:UIBarButtonItemStylePlain];
    [hideCameraRollButtonItem setTarget:self];
    [hideCameraRollButtonItem setAction:@selector(didTapCloseCameraRollButtonAction:)];
    [hideCameraRollButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    
    [hideCameraRollButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:hideCameraRollButtonItem];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    self.specialLibrary = library;
    NSMutableArray *groups = [NSMutableArray array];
    [_specialLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [groups addObject:group];
        } else {
            // this is the end
            [self displayPickerForGroup:[groups objectAtIndex:0]];
        }
    } failureBlock:^(NSError *error) {
        self.chosenImages = nil;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"A problem occured %@", [error description]);
        // an error here means that the asset groups were inaccessable.
        // Maybe the user or system preferences refused access.
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_CAM_ROLL];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didTapCloseCameraRollButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapBackButtonAction:(id)sender {
    [elcPicker dismissViewControllerAnimated:NO completion:^(){
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:^(){
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    
    elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    [elcPicker.navigationItem setLeftBarButtonItem:backButtonItem];
    
    //Set the maximum number of images to select to 100
    if (self.isProfilePicture || self.isCoverPhoto) {
        elcPicker.maximumImagesCount = 1;
    } else {
        elcPicker.maximumImagesCount = 4;
    }
    
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types , (NSString *)kUTTypeMovie
    
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:NO completion:nil];
}

#pragma mark - ELCImagePickerController

-(void)elcImagePickerController:(ELCImagePickerController *)picker
  didFinishPickingMediaWithInfo:(NSArray *)info {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    for (UIView *v in [self.tableView.view subviews]) {
        [v removeFromSuperview];
    }
    
    CGRect workingFrame = CGRectMake(0.0f, 0.0f, 80.0f, 80.0f);
    workingFrame.origin.x = 0;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto) {
            
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]) {
                UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
                
                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                [imageview setContentMode:UIViewContentModeScaleAspectFit];
                imageview.frame = workingFrame;
                
                [self.tableView.view addSubview:imageview];
                
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            } else {
                //NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
            
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo) {
            
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]) {
                
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
                [images addObject:image];
                
                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                [imageview setContentMode:UIViewContentModeScaleAspectFit];
                imageview.frame = workingFrame;
                
                [self.tableView.view addSubview:imageview];
                
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            } else {
                //NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
            
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    NSLog(@"Images: %@",images);
    
    self.chosenImages = images;
    
    if (self.isProfilePicture) {
        [self didSelectProfilePictureAction:[images objectAtIndex:0]];
    } else if (self.isCoverPhoto) {
        [self didSelectCoverPhotoAction:[images objectAtIndex:0]];
    } else {
        FTEditPostViewController *editPostViewController = [[FTEditPostViewController alloc] initWithArray:self.chosenImages];
        editPostViewController.delegate = self;
        [self.navigationController pushViewController:editPostViewController animated:NO];
    }
}

- (void)didSelectProfilePictureAction:(UIImage *)photo {
    if ([delegate respondsToSelector:@selector(camRollViewController:profilePhoto:)]){
        [delegate camRollViewController:self profilePhoto:photo];
    }
}

- (void)didSelectCoverPhotoAction:(UIImage *)photo {
    if ([delegate respondsToSelector:@selector(camRollViewController:coverPhoto:)]){
        [delegate camRollViewController:self coverPhoto:photo];
    }
}

@end
