//
//  MemberCellCollectionView.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "InspirationCellCollectionView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface InspirationCellCollectionView()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation InspirationCellCollectionView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Show gray line
        UIView *lineViewGray = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 1)];
        lineViewGray.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineViewGray];
        
        // Show white line
        UIView *lineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, frame.size.width, 1)];
        lineViewWhite.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineViewWhite];
        
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 5.0f, 195.0f, 40.0f)];
        //self.message = [[UILabel alloc] init];
        [self.message setFont:[UIFont systemFontOfSize:11]];
        [self.message setTextAlignment: NSTextAlignmentLeft];
        [self.message setTextColor: [UIColor blackColor]];
        //[self.message setBackgroundColor:[UIColor blueColor]];
        [self addSubview: self.message];
        
        self.messageInterests = [[UILabel alloc] initWithFrame:CGRectMake(self.message.frame.size.width, 5.0f, frame.size.width - self.message.frame.size.width, 40.0f)];
        //self.messageInterests = [[UILabel alloc] init];
        [self.messageInterests setFont:[UIFont systemFontOfSize:11]];
        [self.messageInterests setTextAlignment: NSTextAlignmentLeft];
        [self.messageInterests setTextColor: [UIColor redColor]];
        //[self.messageInterests setBackgroundColor:[UIColor yellowColor]];
        [self.messageInterests setAdjustsFontSizeToFitWidth:NO];
        [self.messageInterests setLineBreakMode:NSLineBreakByWordWrapping];
        [self.messageInterests setNumberOfLines:0];
        [self addSubview: self.messageInterests];
        
        self.isSelectedToggle = NO;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    NSLog(@"InspirationcellCollectionView::setImage");
    [imageView removeFromSuperview];
        
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 37.0f, 53, 62)];
    imageView.backgroundColor = [UIColor clearColor];
    
    CGRect rect = imageView.frame;
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = imageView.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
    CGFloat lcolumn = rect.size.width - sideWidth;
    CGFloat height = rect.size.height;
    CGFloat ty = (rect.size.height - height) / 2;
    CGFloat tmy = rect.size.height / 4;
    CGFloat bmy = rect.size.height - tmy;
    CGFloat by = rect.size.height;
    CGFloat rightmost = rect.size.width;
    
    [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
    
    [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
    [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
    [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
    
    hexagonMask.path = hexagonPath.CGPath;
    //hexagonBorder.path = hexagonPath.CGPath;
    //hexagonBorder.fillColor = [UIColor clearColor].CGColor;
    //hexagonBorder.strokeColor = [UIColor colorWithRed:0.478 green:0 blue:0.02 alpha:1].CGColor;
    //hexagonBorder.lineWidth = 3;
    imageView.layer.mask = hexagonMask;
    [imageView.layer addSublayer:hexagonBorder];
    [imageView setImage:image];
    [self addSubview:imageView];    
}

- (void)setImageFile:(PFFile *)imageFile
{
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            NSLog(@"No Error");
            UIImage *image = [UIImage imageWithData:data];

            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 37.0f, 53, 62)];
            imageView.backgroundColor = [UIColor clearColor];
            
            CGRect rect = imageView.frame;
            
            CAShapeLayer *hexagonMask = [CAShapeLayer layer];
            CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
            hexagonBorder.frame = imageView.layer.bounds;
            UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
            
            CGFloat sideWidth = 2 * ( 0.5 * rect.size.width / 2 );
            CGFloat lcolumn = rect.size.width - sideWidth;
            CGFloat height = rect.size.height;
            CGFloat ty = (rect.size.height - height) / 2;
            CGFloat tmy = rect.size.height / 4;
            CGFloat bmy = rect.size.height - tmy;
            CGFloat by = rect.size.height;
            CGFloat rightmost = rect.size.width;
            
            [hexagonPath moveToPoint:CGPointMake(lcolumn, ty)];
            [hexagonPath addLineToPoint:CGPointMake(rightmost, tmy)];
            [hexagonPath addLineToPoint:CGPointMake(rightmost, bmy)];
            [hexagonPath addLineToPoint:CGPointMake(lcolumn, by)];
            
            [hexagonPath addLineToPoint:CGPointMake(0, bmy)];
            [hexagonPath addLineToPoint:CGPointMake(0, tmy)];
            [hexagonPath addLineToPoint:CGPointMake(lcolumn, ty)];
            
            hexagonMask.path = hexagonPath.CGPath;
            //hexagonBorder.path = hexagonPath.CGPath;
            //hexagonBorder.fillColor = [UIColor clearColor].CGColor;
            //hexagonBorder.strokeColor = [UIColor redColor].CGColor;
            //hexagonBorder.lineWidth = 3;
            imageView.layer.mask = hexagonMask;
            [imageView.layer addSublayer:hexagonBorder];
            
            [imageView setImage:image];
            [self addSubview:imageView];
        } else {
            NSLog(@"Error");
        }
    }];
}

@end
