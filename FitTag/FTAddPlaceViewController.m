//
//  FTAddPlaceViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTAddPlaceViewController.h"
#import "FTCamViewController.h"

@interface FTAddPlaceViewController () <FTCamViewControllerDelegate>
@property (nonatomic,strong) UITextField *nameTextField;
@property (nonatomic,strong) UITextField *contactTextField;
@property (nonatomic,strong) UITextView *descriptionTextView;
@property (nonatomic,strong) FTLocationManager *locationManager;
@property (nonatomic,strong) UIImage *icon;
@property (nonatomic,strong) PFUser *contact;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIScrollView *originalScrollView;
@property (nonatomic,strong) UIBarButtonItem *saveButton;
@property (nonatomic,strong) UIButton *placeImageButton;
@property (nonatomic,strong) UIImage *businessPhoto;
@property (nonatomic,strong) FTSuggestionTableView *suggestionTableView;
@end

@implementation FTAddPlaceViewController
@synthesize nameTextField;
@synthesize descriptionTextView;
@synthesize locationManager;
@synthesize icon;
@synthesize contact;
@synthesize contactTextField;
@synthesize scrollView;
@synthesize originalScrollView;
@synthesize saveButton;
@synthesize placeImageButton;
@synthesize businessPhoto;
@synthesize geoPoint;
@synthesize suggestionTableView;
@synthesize delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDownGestureAction:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.scrollView addGestureRecognizer:swipeGesture];
    
    originalScrollView = self.scrollView;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] init];
    [backIndicator setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backIndicator setStyle:UIBarButtonItemStylePlain];
    [backIndicator setTarget:self];
    [backIndicator setAction:@selector(didTapBackButtonAction:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    CGSize frameSize = self.view.frame.size;
    
    // Form container
    UIView *formView = [[UIView alloc] initWithFrame:self.view.frame];
    [formView setBackgroundColor:[UIColor clearColor]];
    
    // UIImage - Icon
    placeImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [placeImageButton setFrame:CGRectMake(10, 10, 100, 100)];
    [placeImageButton setUserInteractionEnabled:YES];
    [placeImageButton addTarget:self action:@selector(didTapPlaceImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [placeImageButton setBackgroundColor:FT_GRAY];
    [placeImageButton.layer setCornerRadius:CORNERRADIUS(100)];
    [placeImageButton setClipsToBounds:YES];
    [placeImageButton setImage:IMAGE_BUSINESS_ICON forState:UIControlStateNormal];
    [formView addSubview:placeImageButton];
    
    CGFloat imageViewY = placeImageButton.frame.origin.y + placeImageButton.frame.size.height + 20;
    
    // UITextField - name
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, imageViewY, frameSize.width-20, 30)];
    [nameTextField setPlaceholder:@"Name"];
    [nameTextField setTextAlignment:NSTextAlignmentLeft];
    [nameTextField setTextColor:[UIColor blackColor]];
    [nameTextField setBackgroundColor:[UIColor whiteColor]];
    [nameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [formView addSubview:nameTextField];
    
    CGFloat namePointY = nameTextField.frame.size.height + nameTextField.frame.origin.y + 20;
    
    // UITextView - description
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, namePointY, frameSize.width-20, 80)];
    [descriptionTextView setBackgroundColor:[UIColor whiteColor]];
    [descriptionTextView setTextColor:[UIColor blackColor]];
    [descriptionTextView.layer setCornerRadius:15];
    [descriptionTextView.layer setBorderColor:[FT_GRAY CGColor]];
    [descriptionTextView.layer setBorderWidth:1];
    [formView addSubview:descriptionTextView];
    
    CGFloat descriptionPointY = descriptionTextView.frame.size.height + descriptionTextView.frame.origin.y + 20;
    
    // FTAutoCompleteTextView - PFUser - Contact
    contactTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, descriptionPointY, frameSize.width-20, 30)];
    [contactTextField setPlaceholder:@"Contact"];
    [contactTextField setTextAlignment:NSTextAlignmentLeft];
    [contactTextField setTextColor:[UIColor blackColor]];
    [contactTextField setBackgroundColor:[UIColor whiteColor]];
    [contactTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [contactTextField setDelegate:self];
    [formView addSubview:contactTextField];
    
    [self.scrollView addSubview:formView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Cancel button
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                               target:self
                                                               action:@selector(didTapSaveButtonAction:)];
    [saveButton setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height)];
    
    suggestionTableView = [[FTSuggestionTableView alloc] initWithFrame:CGRectMake(0, 150, 320, 150) style:UITableViewStylePlain type:SUGGEST_BUSINESS];
    [suggestionTableView setBackgroundColor:[UIColor whiteColor]];
    [suggestionTableView setSuggestionDelegate:self];
    [suggestionTableView setAlpha:0];
    
    [self.view addSubview:suggestionTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FTSuggestionTableViewDelegate

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectHashtag:(NSString *)hashtag completeString:(NSString *)completeString {
    if (hashtag) {
        NSString *replaceString = [contactTextField.text stringByReplacingOccurrencesOfString:completeString withString:hashtag];
        [contactTextField setText:replaceString];
    }
}

- (void)suggestionTableView:(FTSuggestionTableView *)suggestionTableView didSelectUser:(PFUser *)user completeString:(NSString *)completeString {
    if ([user objectForKey:kFTUserDisplayNameKey]) {
        NSString *displayname = [user objectForKey:kFTUserDisplayNameKey];
        NSString *replaceString = [contactTextField.text stringByReplacingOccurrencesOfString:completeString withString:displayname];
        [contactTextField setText:replaceString];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self.view bringSubviewToFront:suggestionTableView];
    
    NSArray *mentionRanges = [FTUtility rangesOfMentionsInString:textField.text];
    NSArray *hashtagRanges = [FTUtility rangesOfHashtagsInString:textField.text];
    
    NSTextCheckingResult *currentMention;
    NSTextCheckingResult *currentHashtag;
    
    if (mentionRanges.count > 0) {
        for (int i = 0; i < [mentionRanges count]; i++) {
            
            NSTextCheckingResult *mention = [mentionRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingMentionRange = NSMakeRange(mention.range.location, mention.range.length + 1);
            
            if (NSLocationInRange(range.location, currentlyTypingMentionRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentMention = mention;
            }
        }
    }
    
    if (hashtagRanges.count > 0) {
        for (int i = 0; i < [hashtagRanges count]; i++) {
            
            NSTextCheckingResult *hashtag = [hashtagRanges objectAtIndex:i];
            //Check if the currentRange intersects the mention
            //Have to add an extra space to the range for if you're at the end of a hashtag. (since NSLocationInRange uses a < instead of <=)
            NSRange currentlyTypingHashtagRange = NSMakeRange(hashtag.range.location, hashtag.range.length + 1);
            
            if (NSLocationInRange(range.location, currentlyTypingHashtagRange)) {
                //If the cursor is over the hashtag, then snag that hashtag for matching purposes.
                currentHashtag = hashtag;
            }
        }
    }
    
    if (currentMention){
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_USERS];
        
        NSString *text = [[textField.text substringWithRange:currentMention.range] stringByReplacingOccurrencesOfString:@"@" withString:EMPTY_STRING];
        text = [text stringByAppendingString:string];
        
        if (text.length > 0) {
            [suggestionTableView updateSuggestionWithText:text AndType:SUGGESTION_TYPE_USERS];
        }
        
    } else if (currentHashtag){
        
        // Fade in
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:1];
        }];
        
        // refresh the suggestions array
        [suggestionTableView refreshSuggestionsWithType:SUGGESTION_TYPE_HASHTAGS];
        
        NSString *text = [[textField.text substringWithRange:currentHashtag.range] stringByReplacingOccurrencesOfString:@"#" withString:EMPTY_STRING];
        text = [text stringByAppendingString:string];
        
        if (text.length > 0) {
            [suggestionTableView updateSuggestionWithText:text AndType:SUGGESTION_TYPE_HASHTAGS];
        }
        
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            [suggestionTableView setAlpha:0];
        }];
    }
    return YES;
}


#pragma mark - ()

- (void)didTapBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapPlaceImageButtonAction:(UIButton *)button {
    FTCamViewController *camViewController = [[FTCamViewController alloc] init];
    camViewController.delegate = self;
    camViewController.isProfilePciture = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController setViewControllers:@[camViewController] animated:NO];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    
    [self.scrollView setScrollEnabled:NO];
    
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = originalScrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = originalScrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    
    scrollViewContentOffset.y = 0;
    scrollViewContentOffset.y += keyboardFrameEnd.size.height - (self.originalScrollView.frame.size.height - (20 + contactTextField.frame.size.height + contactTextField.frame.origin.y));
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:NO];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [self.scrollView setScrollEnabled:YES];
    
    CGSize scrollViewContentSize = CGSizeMake(self.scrollView.frame.size.width,originalScrollView.frame.size.height);
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)didTapSaveButtonAction:(id)sender {
    
    [contactTextField resignFirstResponder];
    [nameTextField resignFirstResponder];
    [descriptionTextView resignFirstResponder];
    
    if (nameTextField.text.length > 0) {
        
        if (geoPoint) {
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    
                    //NSLog(@"placemarks:%@",placemarks);
                    
                    for (CLPlacemark *placemark in placemarks) {
                        
                        NSString *postLocation = [NSString stringWithFormat:@" %@, %@", [placemark locality], [placemark administrativeArea]];
                        
                        if (postLocation) {
                            
                            //NSLog(@"postLocation:%@",postLocation);
                            
                            PFObject *location = [PFObject objectWithClassName:kFTLocationClassKey];
                            [location setObject:[placemark thoroughfare] forKey:kFTLocationAddressKey];
                            [location setObject:[placemark locality] forKey:kFTLocationCityKey];
                            [location setObject:[placemark administrativeArea] forKey:kFTLocationStateKey];
                            [location setObject:[placemark postalCode] forKey:kFTLocationPostalCodeKey];
                            [location setObject:[placemark country] forKey:kFTLocationCountryKey];
                            [location setObject:geoPoint forKey:kFTLocationGeoPointKey];
                            [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                if (!error) {
                                    
                                    PFObject *place = [PFObject objectWithClassName:kFTPlaceClassKey];
                                    [place setObject:nameTextField.text forKey:kFTPlaceNameKey];
                                    [place setObject:descriptionTextView.text forKey:kFTPlaceDescriptionKey];
                                    [place setObject:location forKey:kFTPlaceLocationKey];
                                    [place setObject:[NSNumber numberWithBool:NO] forKey:kFTPlaceVerifiedKey];
                                    
                                    if (contact) {
                                        [place setObject:contact forKey:kFTPlaceContactKey];
                                    }
                                    
                                    [place saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                        if (!error) {
                                            [FTUtility showHudMessage:@"Place submitted" WithDuration:2];
                                            if (delegate && [delegate respondsToSelector:@selector(addPlaceViewController:didAddNewplace:location:)]) {
                                                [delegate addPlaceViewController:self didAddNewplace:place location:location];
                                            }
                                        }
                                    }];
                                }
                            }];
                            
                            NSLog(@"location:%@",location);
                        }
                    }
                } else {
                    NSLog(@"ERROR: %@",error);
                }
            }];
            
        } else {
            
            [[[UIAlertView alloc] initWithTitle:@"Location not available"
                                        message:@"Your location can't be accessed at this time."
                                       delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [[[UIAlertView alloc] initWithTitle:@"Title is required"
                                    message:@"Make sure you enter a title for this location."
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
    }
}

- (void)didSwipeDownGestureAction:(id)sender {
    [contactTextField resignFirstResponder];
    [nameTextField resignFirstResponder];
    [descriptionTextView resignFirstResponder];
    //[self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - FTEditPhotoViewControllerDelegate

- (void)camViewController:(FTCamViewController *)camViewController profilePicture:(UIImage *)photo {
    //NSLog(@"%@::camViewController:photo:",VIEWCONTROLLER_SIGNUP);
    self.businessPhoto = photo;
    [self.placeImageButton setImage:photo forState:UIControlStateNormal];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [contactTextField resignFirstResponder];
    [nameTextField resignFirstResponder];
    [descriptionTextView resignFirstResponder];
    [self.navigationItem setRightBarButtonItem:nil];
}

@end
