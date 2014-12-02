//
//  FTCameraViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 8/10/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#define FLASH_IMAGE_ON @"flash"
#define FLASH_IMAGE_OFF @"no_flash"
#define FLASH_IMAGE_AUTO @"auto_flash"

// GUI Images

#define BUTTON_IMAGE_CAMERA_ROLL @"camera_roll"
#define BUTTON_IMAGE_VIDEO @"video_button"
#define BUTTON_IMAGE_RECORD @"record_video_button"
#define BUTTON_IMAGE_TAKE_PICTURE @"take_picture"
#define BUTTON_IMAGE_TOGGLE_CAMERA @"toggle_camera"
#define BUTTON_IMAGE_TOGGLE_CROSSHAIRS @"toggle_crosshairs"
#define BUTTON_IMAGE_CROSSHAIRS @"no_crosshairs"
#define BUTTON_IMAGE_CAMERA_CROSSHAIRS @"crosshairs"
#define BUTTON_IMAGE_CAMERA_OVERLAY @"camera_overlay"

#define BUTTON_TITTLE_NEXT @"NEXT"

#include <math.h>

#import "FTCamViewController.h"
#import "FTCamRollViewController.h"
#import "FTEditVideoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * DeviceAuthorizedContext = &DeviceAuthorizedContext;

@interface FTCamViewController ()

@property (nonatomic, readonly, assign) FTCamFlashButtonState camFlashButtonState;

@property (nonatomic, strong) FTEditPhotoViewController *editPhotoViewController;
@property (nonatomic, strong) FTEditVideoViewController *editVideoViewController;

@property (nonatomic, strong) UIView *liveView;

@property (nonatomic, strong) UIButton *changeCameraButton;
@property (nonatomic, strong) UIButton *showCameraButton;
@property (nonatomic, strong) UIButton *snapStillImageButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *cameraRollButton;

@property (nonatomic, strong) UIBarButtonItem *nextBarButton;

@property (nonatomic) UIImageView *crosshairs;
@property (nonatomic) UIImageView *cameraOverlay;

@property (nonatomic) UIButton *toggleFlashButton;
@property (nonatomic) UIButton *toggleCrosshairs;

// Track flash mode
@property (nonatomic) NSArray *flashImages;
@property (nonatomic) UIView *progressViewBorder;
@property (nonatomic) UIProgressView *progressView;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue;
//@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic, strong) FTCameraEngine *camEngine;
@end

@implementation FTCamViewController
@synthesize isCapturing = _isCapturing;
@synthesize isPaused = _isPaused;
@synthesize changeCameraButton;
@synthesize cameraRollButton;
@synthesize showCameraButton;
@synthesize editVideoViewController;
@synthesize snapStillImageButton;
@synthesize cameraOverlay;
@synthesize crosshairs;
@synthesize delegate;
@synthesize flashImages;
@synthesize toggleFlashButton;
@synthesize toggleCrosshairs;
@synthesize recordButton;
@synthesize progressViewBorder;
@synthesize progressView;
@synthesize nextBarButton;
@synthesize editPhotoViewController;
@synthesize camFlashButtonState;
@synthesize camEngine;
@synthesize previewLayer;
@synthesize liveView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the default flash state to auto
    camFlashButtonState = FTCamFlashButtonStateAuto;
    
    // Check for device authorization
	[self checkDeviceAuthorizationStatus];
    
    // configure layout
    [self configureView];
    
    // Show last taken image as cam roll button
    [self showCameraRollPreviewImage];
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [progressView setProgress:0];
    [self.tabBarController.tabBar setHidden:YES];
    
    dispatch_async([self sessionQueue], ^{
                
        camEngine = [FTCameraEngine engine];
        [camEngine startup];
        [camEngine setDelegate:self];
        [camEngine setFlashMode:AVCaptureFlashModeAuto];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            previewLayer = [camEngine getPreviewLayer];
            [previewLayer removeFromSuperlayer];
            [previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * .65)];
            [liveView.layer addSublayer:previewLayer];
        });
        
        [self addObserver:self
               forKeyPath:@"deviceAuthorized"
                  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context:DeviceAuthorizedContext];
        
        [self addObserver:self
               forKeyPath:@"camEngine.stillImageOutput.capturingStillImage"
                  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context:CapturingStillImageContext];
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(subjectAreaDidChange:)
                                                     name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object:[[self videoDeviceInput] device]];
        
        __weak FTCamViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter]
                                               addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                               object:[self session]
                                               queue:nil
                                               usingBlock:^(NSNotification *note) {
                                                   
                                                   FTCamViewController *strongSelf = weakSelf;
                                                   dispatch_async([strongSelf sessionQueue], ^{
                                                       // Manually restarting the session since it must have been stopped due to an error.
                                                       [[strongSelf session] startRunning];
                                                       [[strongSelf recordButton] setTitle:NSLocalizedString(@"", @"Recording button record title")
                                                                                  forState:UIControlStateNormal];
                                                   });
                                               }]];
         */
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:VIEWCONTROLLER_CAM];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Show the tabbar
    [self.tabBarController.tabBar setHidden:NO];
    
     dispatch_async([self sessionQueue], ^{
         //[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
         //[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
     
         [self removeObserver:self forKeyPath:@"deviceAuthorized" context:DeviceAuthorizedContext];
         [self removeObserver:self forKeyPath:@"camEngine.stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
         [camEngine shutdown];
         camEngine = nil;
     });
}

#pragma mark - configure

- (void)configureView {
    
    // Background color
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // NavigationBar & TabBar
    [self.navigationItem setTitle:NAVIGATION_TITLE_CAM];
    [self.navigationItem setHidesBackButton:NO];
    
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:FT_RED_COLOR_RED green:FT_RED_COLOR_GREEN blue:FT_RED_COLOR_BLUE alpha:1.0f]];
    
    nextBarButton = [[UIBarButtonItem alloc] init];
    [nextBarButton setTitle:BUTTON_TITTLE_NEXT];
    [nextBarButton setTarget:self];
    [nextBarButton setAction:@selector(didTapNextButtonAction:)];
    [nextBarButton setTintColor:[UIColor whiteColor]];
    [nextBarButton setEnabled:NO];
    
    [self.navigationItem setRightBarButtonItem:nextBarButton];
    
    // Override the back idnicator
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    float previewHeight = self.view.frame.size.height * .65;
    float navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    // Camera Overlay
    cameraOverlay = [[UIImageView alloc] init];
    [cameraOverlay setImage:[UIImage imageNamed:BUTTON_IMAGE_CAMERA_OVERLAY]];
    [cameraOverlay setFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, 33)];
    
    [self.view addSubview:cameraOverlay];
    
    // Add crosshairs
    
    crosshairs = [[UIImageView alloc] init];
    [crosshairs setImage:[UIImage imageNamed:BUTTON_IMAGE_CAMERA_CROSSHAIRS]];
    [crosshairs setFrame:CGRectMake(0, 33, self.view.frame.size.width, previewHeight - 66)];
    
    // Camera View
    
    liveView = [[UIImageView alloc] init];
    [liveView setBackgroundColor:[UIColor blackColor]];
    [liveView setFrame:CGRectMake(0, 0, self.view.frame.size.width, previewHeight)];
    [liveView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPreviewLayerAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    [liveView addGestureRecognizer:tapGesture];
    
    // Container
    
    UIView *container = [[UIImageView alloc] init];
    [container setBackgroundColor:[UIColor blackColor]];
    [container setFrame:CGRectMake(0, cameraOverlay.frame.origin.y, crosshairs.frame.size.width, crosshairs.frame.size.height + (cameraOverlay.frame.size.height * 2))];
    
    [self.view addSubview:container];
    [container addSubview:liveView];
    [container addSubview:crosshairs];
    
    [liveView sendSubviewToBack:container];
    [self.view bringSubviewToFront:cameraOverlay];
    
    // Camera Overlay
    
    UIView *cameraBarOverlay = [[UIImageView alloc] init];
    [cameraBarOverlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BUTTON_IMAGE_CAMERA_OVERLAY]]];
    [cameraBarOverlay setFrame:CGRectMake(0, previewHeight+11, self.view.frame.size.width, 33.0f)];
    [cameraBarOverlay setUserInteractionEnabled:YES];
    
    [self.view addSubview:cameraBarOverlay];
    
    // Toggle Camera
    
    changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeCameraButton setFrame:CGRectMake((self.view.frame.size.width - 26) / 2, 4, 26, 25)];
    [changeCameraButton setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_TOGGLE_CAMERA] forState:UIControlStateNormal];
    [changeCameraButton addTarget:self action:@selector(didTapChangeCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [changeCameraButton setTintColor:[UIColor grayColor]];
    [changeCameraButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Toggle Flash
    
    toggleFlashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleFlashButton setFrame:CGRectMake(250, 4, 18, 24)];
    [toggleFlashButton setImage:[UIImage imageNamed:FLASH_IMAGE_AUTO] forState:UIControlStateNormal];
    [toggleFlashButton addTarget:self action:@selector(didTapToggleFlashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toggleFlashButton setTintColor:[UIColor grayColor]];
    [toggleFlashButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Toggle Crosshairs
    
    toggleCrosshairs = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleCrosshairs setFrame:CGRectMake(40.0f, 4.0f, 25.0f, 25.0f)];
    [toggleCrosshairs setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_TOGGLE_CROSSHAIRS] forState:UIControlStateNormal];
    [toggleCrosshairs setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_CROSSHAIRS] forState:UIControlStateSelected];
    [toggleCrosshairs addTarget:self action:@selector(didTapCrosshairsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toggleCrosshairs setTintColor:[UIColor grayColor]];
    [toggleCrosshairs setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add buttons to the overlay bar
    
    [cameraBarOverlay addSubview:toggleCrosshairs];
    [cameraBarOverlay addSubview:changeCameraButton];
    [cameraBarOverlay addSubview:toggleFlashButton];
    
    // Setup the progressview
    
    progressViewBorder = [[UIView alloc] init];
    [progressViewBorder setFrame:CGRectMake(0, cameraBarOverlay.frame.size.height + cameraBarOverlay.frame.origin.y, self.view.frame.size.width, 10)];
    [progressViewBorder setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"progress_bg"]]];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1,5);
    
    self.progressView = [[UIProgressView alloc] init];
    [self.progressView setFrame:CGRectMake(0,3,self.view.frame.size.width,10)];
    [self.progressView setProgressTintColor:[UIColor whiteColor]];
    [self.progressView setUserInteractionEnabled:NO];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor clearColor]];
    [self.progressView setProgress:0];
    [self.progressView setTransform:transform];
    
    [progressViewBorder setHidden:YES];
    [progressViewBorder addSubview:self.progressView];
    [progressViewBorder bringSubviewToFront:self.progressView];
    
    [self.view addSubview:progressViewBorder];
    
    // Take picture button
    
    snapStillImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [snapStillImageButton setFrame:CGRectMake((self.view.frame.size.width - 74.0f) / 2,
                                     (long)[self getTopPaddingNavigationBarHeight:navigationBarHeight
                                                                    previewHeight:previewHeight
                                                                    elementHeight:74.0f
                                                                      frameHeight:self.view.frame.size.height], 74.0f, 74.0f)];
    
    [snapStillImageButton setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_TAKE_PICTURE] forState:UIControlStateNormal];
    [snapStillImageButton addTarget:self action:@selector(didTapSnapStillImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [snapStillImageButton setTintColor:[UIColor grayColor]];
    [snapStillImageButton setHidden:NO];
    
    [self.view addSubview:snapStillImageButton];
    
    // Record record Video Button
    
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_RECORD] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(didTapStartRecordingButtonAction:) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(didReleaseRecordingButtonAction:) forControlEvents:UIControlEventTouchDragExit];
    [recordButton addTarget:self action:@selector(didReleaseRecordingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setHidden:YES];
    [recordButton setFrame:CGRectMake((self.view.frame.size.width - 74.0f)/2,
                                      (long)[self getTopPaddingNavigationBarHeight:navigationBarHeight
                                                                     previewHeight:previewHeight
                                                                     elementHeight:74.0f
                                                                       frameHeight:self.view.frame.size.height], 74.0f, 74.0f)];
    [self.view addSubview:recordButton];
    
    // Show Camera Button
    
    if (!self.isProfilePciture && !self.isCoverPhoto) {
        showCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [showCameraButton setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_VIDEO] forState:UIControlStateNormal];
        [showCameraButton addTarget:self action:@selector(toggleVideoControlsAction:) forControlEvents:UIControlEventTouchDown];
        [showCameraButton setTintColor:[UIColor grayColor]];
        [showCameraButton setFrame:CGRectMake(250, [self getTopPaddingNavigationBarHeight:navigationBarHeight
                                                                            previewHeight:previewHeight
                                                                            elementHeight:39
                                                                              frameHeight:self.view.frame.size.height], 44, 39)];
        [self.view addSubview:showCameraButton];
        [self.nextBarButton setEnabled:YES];
    }
    
    // Camera roll button
    
    cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraRollButton setFrame:CGRectMake(40, [self getTopPaddingNavigationBarHeight:navigationBarHeight
                                                                       previewHeight:previewHeight
                                                                       elementHeight:50
                                                                         frameHeight:self.view.frame.size.height], 50, 50)];
    
    //[cameraRollButton setBackgroundImage:[UIImage imageNamed:BUTTON_IMAGE_CAMERA_ROLL] forState:UIControlStateNormal];
    [cameraRollButton addTarget:self action:@selector(didTapCameraRollButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cameraRollButton setTintColor:[UIColor grayColor]];
    [cameraRollButton setClipsToBounds:YES];
    
    [self.view addSubview:cameraRollButton];
}

#pragma mark - ()

- (void)showCameraRollPreviewImage {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Block called for every asset selected
    void (^selectionBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset *asset, NSUInteger index, BOOL *innerStop) {
        // The end of the enumeration is signaled by asset == nil.
        if (asset == nil) {
            return;
        }
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        // Retrieve the image orientation from the ALAsset
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber *orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        CGFloat scale  = 1;
        
        // this is the most recent saved photo
        UIImageView *photo = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[representation fullResolutionImage]
                                                                                    scale:scale orientation:orientation]];
        if (photo) {
            //UIImageView *cameraRollHexagon = [FTUtility getProfileHexagonWithFrame:self.cameraRollButton.frame];
            //photo.frame = cameraRollHexagon.frame;
            //photo.layer.mask = cameraRollHexagon.layer.mask;
            photo.frame = self.cameraRollButton.frame;
            photo.layer.cornerRadius = CORNERRADIUS(self.cameraRollButton.frame.size.width);
            photo.clipsToBounds = YES;            
            [self.view addSubview:photo];
        }
    };
    
    // Block called when enumerating asset groups
    void (^enumerationBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop) {
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Get the photo at the last index
        NSUInteger index              = [group numberOfAssets] - 1;
        NSIndexSet *lastPhotoIndexSet = [NSIndexSet indexSetWithIndex:index];
        [group enumerateAssetsAtIndexes:lastPhotoIndexSet options:0 usingBlock:selectionBlock];
    };
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:enumerationBlock
                         failureBlock:^(NSError *error) {
                             // handle error
                         }];
}

- (void)toggleVideoControlsAction:(id)sender {
    if ([recordButton isHidden]) {
        [crosshairs setHidden:YES];
        [toggleFlashButton setHidden:YES];
        [toggleCrosshairs setHidden:YES];
        [recordButton setHidden:NO];
        [snapStillImageButton setHidden:YES];
        [progressViewBorder setHidden:NO];
        [self.navigationItem setTitle: @"VIDEO"];
    } else {
        [crosshairs setHidden:NO];
        [toggleFlashButton setHidden:NO];
        [toggleCrosshairs setHidden:NO];
        [recordButton setHidden:YES];
        [snapStillImageButton setHidden:NO];
        [progressViewBorder setHidden:YES];
        [self.navigationItem setTitle:NAVIGATION_TITLE_CAM];
    }
}

- (void)didTapPreviewLayerAction:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"didTapPreviewLayerAction");
    [camEngine focusAndExposeTap:gestureRecognizer];
}

- (void)didTapNextButtonAction:(id)sender {
    [camEngine stopCapture];
}

- (void)didTapBackButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapToggleFlashButtonAction:(UIButton *)sender {
    switch (camFlashButtonState) {
        case FTCamFlashButtonStateAuto:
            NSLog(@"FTCamFlashButtonStateAuto -> FTCamFlashButtonStateOn");
            camFlashButtonState = FTCamFlashButtonStateOn;
            [toggleFlashButton setImage:[UIImage imageNamed:FLASH_IMAGE_ON] forState:UIControlStateNormal];
            [toggleFlashButton setFrame:CGRectMake(250, 4, 24, 24)];
            [camEngine setFlashMode:AVCaptureFlashModeOn];
            break;
        case FTCamFlashButtonStateOn:
            NSLog(@"FTCamFlashButtonStateOn -> FTCamFlashButtonStateOff");
            camFlashButtonState = FTCamFlashButtonStateOff;
            [toggleFlashButton setImage:[UIImage imageNamed:FLASH_IMAGE_OFF] forState:UIControlStateNormal];
            [toggleFlashButton setFrame:CGRectMake(250, 4, 24, 24)];
            [camEngine setFlashMode:AVCaptureFlashModeOff];
            break;
        case FTCamFlashButtonStateOff:
            NSLog(@"FTCamFlashButtonStateOff -> FTCamFlashButtonStateAuto");
            camFlashButtonState = FTCamFlashButtonStateAuto;
            [toggleFlashButton setImage:[UIImage imageNamed:FLASH_IMAGE_AUTO] forState:UIControlStateNormal];
            [toggleFlashButton setFrame:CGRectMake(250, 4, 24, 24)];
            [camEngine setFlashMode:AVCaptureFlashModeAuto];
            break;
        default:
            NSLog(@"Default");
            camFlashButtonState = FTCamFlashButtonStateAuto;
            [toggleFlashButton setFrame:CGRectMake(250, 4.0f, 18.0f, 24)];
            [camEngine setFlashMode:AVCaptureFlashModeAuto];
            break;
    }
}

- (void)didTapCrosshairsButtonAction:(id)sender {
    if ([toggleCrosshairs isSelected]) {
        [toggleCrosshairs setSelected:NO];
        [crosshairs setHidden:NO];
    } else {
        [toggleCrosshairs setSelected:YES];
        [crosshairs setHidden:YES];
    }
}

- (void)didTapCameraRollButtonAction:(id)sender {
    FTCamRollViewController *camRollViewController = [[FTCamRollViewController alloc] init];
    camRollViewController.delegate = self;
    if (self.isProfilePciture) {
        camRollViewController.isProfilePicture = YES;
    } else if (self.isCoverPhoto) {
        camRollViewController.isCoverPhoto = YES;
    }
    [self.navigationController pushViewController:camRollViewController animated:YES];    
}

- (void)didTapChangeCameraButtonAction:(id)sender {
    [camEngine switchCamera];
}

#pragma mark UI

- (void)checkDeviceAuthorizationStatus {
	NSString *mediaType = AVMediaTypeVideo;
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted){
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		} else {
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage){
			[camEngine runStillImageCaptureAnimation];
		}
        
	} else if (context == DeviceAuthorizedContext) {
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning) {
				[[self changeCameraButton] setEnabled:YES];
				[[self recordButton] setEnabled:YES];
				[[self snapStillImageButton] setEnabled:YES];
			} else {
				[[self changeCameraButton] setEnabled:NO];
				[[self recordButton] setEnabled:NO];
				[[self snapStillImageButton] setEnabled:NO];
			}
		});
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

- (void)didTapStartRecordingButtonAction:(UIButton *)button {
    NSLog(@"%@::didTapStartRecordingButtonAction",VIEWCONTROLLER_CAM);
    if ([camEngine isPaused] && [camEngine isCapturing])
        [camEngine resumeCapture];
    else
        [camEngine startCapture];
}

- (void)shouldUpdateProgressView:(NSNumber *)progress {
    NSLog(@"%@::updateProgress:",VIEWCONTROLLER_CAM);
    /*
    if (![progress isEqualToNumber:[NSDecimalNumber notANumber]]) {
        NSLog(@"progress: %f",[progress floatValue]);
        [self.progressView setProgress:[progress floatValue] animated:YES];
    }
    */
}

- (void)pauseMovieRecording:(id)sender {
    NSLog(@"%@::pauseMovieRecording:",VIEWCONTROLLER_CAM);
    [camEngine pauseCapture];
}

- (void)didReleaseRecordingButtonAction:(UIButton *)button {
    NSLog(@"%@::didReleaseRecordingButtonAction:",VIEWCONTROLLER_CAM);
    [camEngine pauseCapture];
}

- (void)didTapSnapStillImageButtonAction:(id)sender {
    NSLog(@"%@::snapStillImage:",VIEWCONTROLLER_CAM);
    [camEngine captureStillImage];
}

- (NSInteger) getTopPaddingNavigationBarHeight:(NSInteger)navBar
                                 previewHeight:(NSInteger)preview
                                 elementHeight:(NSInteger)element
                                   frameHeight:(NSInteger)frame {
    return preview + ((((navBar + frame) - preview) - element) / 2);
}

#pragma mark - ()

- (void)didTakeProfilePictureAction:(UIImage *)photo {
    //NSLog(@"%@::didTakeProfilePictureAction:",VIEWCONTROLLER_CAM);
    if ([delegate respondsToSelector:@selector(camViewController:profilePicture:)]){
        [delegate camViewController:self profilePicture:photo];
    }
}

- (void)didSelectProfilePictureAction:(UIImage *)photo {
    //NSLog(@"%@::didSelectProfilePictureAction:",VIEWCONTROLLER_CAM);
    if ([delegate respondsToSelector:@selector(camViewController:profilePicture:)]){
        [delegate camViewController:self profilePicture:photo];
    }
}

- (void)didTakeCoverPhotoAction:(UIImage *)photo {
    //NSLog(@"%@::didTakeCoverPhotoAction:",VIEWCONTROLLER_CAM);
    if ([delegate respondsToSelector:@selector(camViewController:coverPhoto:)]){
        [delegate camViewController:self coverPhoto:photo];
    }
}

- (void)didSelectCoverPhotoAction:(UIImage *)photo {
    //NSLog(@"%@::didSelectCoverPhotoAction:",VIEWCONTROLLER_CAM);
    if ([delegate respondsToSelector:@selector(camViewController:coverPhoto:)]){
        [delegate camViewController:self coverPhoto:photo];
    }
}

#pragma mark - FTCamRollViewControllerDelegate

- (void)camRollViewController:(FTCamRollViewController *)camRollViewController profilePhoto:(UIImage *)photo {
    //NSLog(@"photo: %@",photo);
    [self didSelectProfilePictureAction:photo];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)camRollViewController:(FTCamRollViewController *)camRollViewController coverPhoto:(UIImage *)photo {
    //NSLog(@"photo: %@",photo);
    [self didSelectCoverPhotoAction:photo];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FTCameraEngineDelegate

- (void)cameraEngine:(FTCameraEngine *)cameraEngine
progressStatusUpdate:(CGFloat)update {
    dispatch_async([self sessionQueue], ^{
        
        CGFloat time = (CGFloat)[cameraEngine maxDuration];
        CGFloat progress = (CGFloat) (update / time);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress animated:NO];
        });
    });
}

- (void)cameraEngine:(FTCameraEngine *)cameraEngine recordingStatusChange:(BOOL)isPaused {
    
    dispatch_async([self sessionQueue], ^{ // Background queue started
        // While the movie is recording, update the progress bar
        
        // Dispatch changes to the view to main queue, they can't be updated in the background.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isPaused) {
                // Things that should happen when not recording
                [[self changeCameraButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
            } else {
                // Things that shouldn't be allowed when recording
                [[self changeCameraButton] setEnabled:NO];
                [[self recordButton] setEnabled:YES];
            }
        });
    });
}

- (void)cameraEngine:(FTCameraEngine *)cameraEngine stopRecording:(BOOL)isPaused {
    NSLog(@"stopRecording");
    [[self changeCameraButton] setEnabled:NO];
    [[self recordButton] setEnabled:NO];
}

- (void)cameraEngine:(FTCameraEngine *)cameraEngine capturedVideoData:(NSData *)data {
    editVideoViewController = [[FTEditVideoViewController alloc] initWithVideo:data];
    [self.navigationController pushViewController:editVideoViewController animated:NO];
}

- (void)cameraEngine:(FTCameraEngine *)cameraEngine capturedVideoData:(NSData *)data path:(NSString *)path {
    editVideoViewController = [[FTEditVideoViewController alloc] initWithVideo:data];
    [self.navigationController pushViewController:editVideoViewController animated:NO];
}

- (void)cameraEngine:(FTCameraEngine *)cameraEngine capturedImage:(UIImage *)image {
    if (!self.isProfilePciture && !self.isCoverPhoto) {
        // Prepare to upload the taken image
        self.editPhotoViewController = [[FTEditPhotoViewController alloc] initWithImage:image];
        [self.navigationController pushViewController:editPhotoViewController animated:NO];
    } else if (self.isProfilePciture){
        // Return the profile image
        [self didTakeProfilePictureAction:image];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.isCoverPhoto) {
        [self didTakeCoverPhotoAction:image];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
