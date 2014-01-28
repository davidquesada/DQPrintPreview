//
//  DQPrintPreviewViewController.h
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preview.h"

@interface DQPrintPreviewViewController : UIViewController

//@property MTPDF *pdfRef;
@property Preview *preview;

-(void)reloadPreview;

#pragma mark - Animation stuffs.

-(void)setOrientation:(Orientation)orientation animated:(BOOL)animated;

@end
