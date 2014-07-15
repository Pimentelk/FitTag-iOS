//
//  CameraImagePickerViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 6/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "ImageCollectionViewController.h"
#import "PhotoCellCollectionView.h"
#import "ImageCustomNavigationBar.h"

@interface ImageCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIBarButtonItem *backButton;
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
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationItem setTitle: @"Camera Roll"];
    [self.navigationItem setHidesBackButton:TRUE];
    
    // Override the back idnicator
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(hideCameraRoll)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    // Draw transparent overlay menu
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (self.view.frame.size.height - 40.0f), self.view.frame.size.width, 60.0f)];
    [overlay setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.6]];
    [self.view addSubview:overlay];
    
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

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"CameraImagePickerViewController::imagePickerController");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageView setImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
*/

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

/*
- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
