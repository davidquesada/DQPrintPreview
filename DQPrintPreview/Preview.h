//
//  Preview.h
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTPDF.h"

typedef NS_ENUM(NSInteger, Orientation)
{
    OrientationPortrait,
    OrientationLandscape,
};

typedef NS_ENUM(NSInteger, SideStyle)
{
    SideStyleSingle,
    SideStyleDoubleLongEdge,
    SideStyleDoubleShortEdge,
};

/*
 Note (Because I don't feel like finding an actual place to put this):
 When posting to /jobs, you can set the pages_per_sheet value, for multi printing. 
    values: 1,2,4,6,9,16
 */

@interface Preview : NSObject

@property MTPDF *pdf;

@property Orientation orientation;
@property SideStyle sideStyle;
@property int pagesPerSheet; // Acceptable Values: 1, 2, 4, 6, 9, or 16.
@property BOOL scale;

@property int pageCount;

@property CGSize paperSize; // Default: 8.5w * 11h

@end


@interface Preview (UIPageViewController)
-(UIPageViewControllerNavigationOrientation)orientationForCurrentOrientation;
@end