//
//  DQPrintPreviewPageViewController.h
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Preview;

@interface DQPrintPreviewPageViewController : UIViewController
-(void)setPDF:(Preview *)pdf virtualPage:(int)page;

// A Virtual Page number.
@property(readonly) int page;

@end
