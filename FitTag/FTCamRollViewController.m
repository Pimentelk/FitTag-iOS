//
//  FTCamRollViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCamViewController.h"
#import "FTCamRollViewController.h"
#import "PhotoCellCollectionView.h"
#import "ImageCustomNavigationBar.h"
#import "FTEditPhotoViewController.h"
#import "FTOverlayView.h"
#import "FTToolBar.h"
#import "FTEditPostViewController.h"

@interface FTCamRollViewController ()

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation FTCamRollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"CameraImagePickerViewController::viewDidLoad");    
    
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    //[self.view addSubview:self.scrollView];
    
    // Set controller background color
    self.view.backgroundColor = [UIColor whiteColor];
    
    // NavigationBar & ToolBar
    [self.navigationItem setTitle: @"Camera Roll"];
    [self.navigationItem setHidesBackButton:TRUE];

    // Override the back idnicator
    UIBarButtonItem *hideCameraRoll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(closeCameraRollAction:)];
    [hideCameraRoll setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:hideCameraRoll];
    
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

- (void)closeCameraRollAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group {
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select to 100
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
    
    FTEditPostViewController *editPostViewController = [[FTEditPostViewController alloc] initWithArray:self.chosenImages];
    editPostViewController.delegate = self;
    
    [self.navigationController pushViewController:editPostViewController animated:NO];
}

-(void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
