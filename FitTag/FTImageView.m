//
//  FTImageView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/26/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTImageView.h"

@interface FTImageView ()
@property (nonatomic, strong) PFFile *currentFile;
@property (nonatomic, strong) NSString *url;
@end

@implementation FTImageView

@synthesize currentFile,url;
@synthesize placeholderImage;

#pragma mark - FTImageView

- (void) setFile:(PFFile *)file {
    //UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShadowsProfilePicture-43.png"]];
    //[self addSubview:border];
    
    NSString *requestURL = file.url; // Save copy of url locally (will not change in block)
    [self setUrl:file.url]; // Save copy of url on the instance
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            if ([requestURL isEqualToString:self.url]) {
                [self setImage:image];
                [self setNeedsDisplay];
            }
        } else {
            NSLog(@"Error on fetching file");
        }
    }];
}

@end
