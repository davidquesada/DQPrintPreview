//
//  DQPrintPreviewContentViewController.h
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preview.h"

typedef struct
{
    UIPageViewControllerNavigationOrientation orientation;
    UIPageViewControllerSpineLocation spineLocation;
    BOOL doubleSided;
} PrintPreviewOptions;

@class MTPDF;


@interface DQPrintPreviewContentViewController : UIPageViewController

-(instancetype)initWithPreview:(Preview *)preview;
@property Preview *preview;

-(void)popoutViewControllers;

-(int)pageNumber;
-(void)setPageNumber:(int)num;

@end
