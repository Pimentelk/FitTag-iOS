//
//  FTSuggestionTableViewCell.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSuggestionCell.h"

@interface FTSuggestionCell()
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIImageView *suggestionView;
@property (nonatomic, strong) UILabel *displayName;
@end

@implementation FTSuggestionCell
@synthesize user;
@synthesize view;
@synthesize suggestionView;
@synthesize displayName;
@synthesize delegate;
@synthesize hashtag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        view = [[UIView alloc] initWithFrame:self.frame];
        [view setBackgroundColor:[UIColor whiteColor]];
        [view setUserInteractionEnabled:YES];
        
        for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
            [self removeGestureRecognizer:recognizer];
        }
        
        CGSize frameSize = self.frame.size;
        CGFloat viewHeight = frameSize.height-5;
        
        suggestionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewHeight)];
        [suggestionView setCenter:CGPointMake(frameSize.height/2, frameSize.height/2)];
        [suggestionView setContentMode:UIViewContentModeScaleAspectFit];
        [suggestionView.layer setCornerRadius:CORNERRADIUS(viewHeight)];
        [suggestionView setClipsToBounds:YES];
        [self.view addSubview:suggestionView];
        
        displayName = [[UILabel alloc] initWithFrame:CGRectMake(viewHeight+10, 0, frameSize.width-viewHeight-10, viewHeight+5)];
        [displayName setTextAlignment:NSTextAlignmentLeft];
        [displayName setFont:MULIREGULAR(14)];
        [self.view addSubview:displayName];
        
        [self addSubview:view];
    }
    return self;
}

- (void)setUser:(PFUser *)aUser {
    
    user = aUser;
    
    if ([user objectForKey:kFTUserProfilePicSmallKey]) {
        PFFile *file = [user objectForKey:kFTUserProfilePicSmallKey];
        
        if (file && ![file isEqual:[NSNull null]]) {
            
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    // profile image
                    UIImage *image = [UIImage imageWithData:data];
                    [suggestionView setImage:image];
                }
            }];
        }
    } else {
        // profile image is empty
        //[UIImage imageNamed:IMAGE_PROFILE_EMPTY];
    }
    
    // Get user displayname
    NSString *name = [NSString stringWithFormat:@"%@",[user objectForKey:kFTUserDisplayNameKey]];
    [displayName setText:name];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectUserAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    [view addGestureRecognizer:tapGesture];
}

- (void)setHashtag:(NSString *)aHashtag {
    
    UIImage *image = [UIImage imageNamed:@"hashtag-icon"];
    [suggestionView setImage:image];
    
    hashtag = aHashtag;    
    [displayName setText:hashtag];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHashtagAction:)];
    [tapGesture setNumberOfTapsRequired:1];
    [view addGestureRecognizer:tapGesture];
}

- (void)didSelectUserAction:(id)sender {
    if (user) {
        if (delegate && [delegate respondsToSelector:@selector(suggestionCell:didSelectUser:)]) {
            [delegate suggestionCell:self didSelectUser:user];
        }
    }
}

- (void)didSelectHashtagAction:(id)sender {
    if (hashtag) {
        if (delegate && [delegate respondsToSelector:@selector(suggestionCell:didSelectHashtag:)]) {
            [delegate suggestionCell:self didSelectHashtag:hashtag];
        }
    }
}

@end
