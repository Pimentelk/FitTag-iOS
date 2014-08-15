//
//  CameraImagePickerViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCamViewController.h"
#import "ImageCollectionViewController.h"
#import "PhotoCellCollectionView.h"
#import "ImageCustomNavigationBar.h"
#import "FTEditPhotoViewController.h"
#import "FTOverlayView.h"

@interface ImageCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation ImageCollectionViewController

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

@synthesize backButton;
@synthesize navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"CameraImagePickerViewController::viewDidLoad");    
    
    // Set controller background color
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // NavigationBar & ToolBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.navigationItem setTitle: @"Camera Roll"];
    [self.navigationItem setHidesBackButton:TRUE];
    [self.navigationController.toolbar setDelegate:self];

    // Override the back idnicator
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(hideCameraRoll)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
        
    // Set up delegate and datasource
    [self.collectionView registerClass:[PhotoCellCollectionView class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView setDelegate: self];
    [self.collectionView setDataSource: self];
    
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    ALAssetsLibrary *assetsLibrary = [ImageCollectionViewController defaultAssetsLibrary];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
        self.assets = tmpAssets;
        
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraImagePickerViewController::didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)loadCamera{
    NSLog(@"loadCamera...");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Camera is available...");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
        [picker setDelegate: self];
        [picker setShowsCameraControls: NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"Camera is not available...");
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
}

- (void)hideCameraRoll
{
    NSLog(@"hideCameraRoll");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCellCollectionView *cell = (PhotoCellCollectionView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[PhotoCellCollectionView class]]) {
        ALAsset *asset = self.assets[indexPath.row];
        cell.asset = asset;
        cell.backgroundColor = [UIColor blueColor];
        cell.photoImageView.image = [[UIImage alloc] initWithCGImage:asset.thumbnail];
        
    }

    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    if (self.onCompletion){self.onCompletion(image);}
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"FTFeedViewController::imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSLog(@"FTFeedViewController::imagePickerController");
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    FTEditPhotoViewController *viewController = [[FTEditPhotoViewController alloc] initWithImage:image];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController pushViewController:viewController animated:NO];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"FTFeedViewController::actionSheet");
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

#pragma mark - FTCameraToolBarDelegate

- (void)showCameraPreview
{
    NSLog(@"FTFeedViewController::showCameraPreview");
    
    /*
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if(cameraDeviceAvailable){
        [self shouldStartCameraController];
    }
    */
    
    FTCamViewController *cameraViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}

#pragma mark - ()
- (BOOL)shouldPresentPhotoCaptureController {
    
    NSLog(@"FTFeedViewController::shouldPresentPhotoCaptureController");
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartCameraController {
    
    NSLog(@"FTFeedViewController::shouldStartCameraController");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
        cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        FTOverlayView *overlayView = [[FTOverlayView alloc] init];
        cameraUI.cameraOverlayView = overlayView;

        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = NO;
    cameraUI.delegate = self;
    cameraUI.navigationBarHidden = NO;
    cameraUI.navigationBar.barStyle = UIBarStyleDefault;
    
    [self.navigationController presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    
    NSLog(@"FTFeedViewController::shouldStartPhotoLibraryPickerController");
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

-(void)toggleCamera:(id)sender
{
    NSLog(@"FTFeedViewController::toggleCamera");
    
    
}

@end
