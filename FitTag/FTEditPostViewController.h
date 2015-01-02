//
//  FTEditPhotoViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTPostDetailsFooterView.h"
#import <CoreLocation/CoreLocation.h>
#import "FTSuggestionTableView.h"
#import "FTPlacesViewController.h"

@protocol FTEditPostViewControllerDelegate;
@interface FTEditPostViewController : UIViewController <UITextViewDelegate,
                                                        UITextFieldDelegate,
                                                        UIScrollViewDelegate,
                                                        FTSuggestionTableViewDelegate,
                                                        FTPostDetailsFooterViewDelegate,
                                                        FTPlacesViewControllerDelegate,
                                                        CLLocationManagerDelegate>

@property (nonatomic,weak) id <FTEditPostViewControllerDelegate> delegate;
- (id)initWithArray:(NSArray *)aArray;
- (id)initWithVideo:(NSData *)aVideo;
- (id)initWithImage:(UIImage *)aImage;
@end

@protocol FTEditPostViewControllerDelegate <NSObject>
@optional
- (void)setCoverPhoto:(UIImage *)image Caption:(NSString *)caption;
@end
