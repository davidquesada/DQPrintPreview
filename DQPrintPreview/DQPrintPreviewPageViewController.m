//
//  DQPrintPreviewPageViewController.m
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "DQPrintPreviewPageViewController.h"
#import "Preview.h"

@interface DQPrintPreviewPageViewController ()
@property UILabel *label;
@property(readwrite) int page;
@end

@implementation DQPrintPreviewPageViewController


-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view.backgroundColor = [UIColor colorWithWhite:.93 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text = @"WOOP";
    [self.view addSubview:label];
    self.label = label;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.label)
        return;

}

-(void)setPDF:(Preview *)pdf virtualPage:(int)page
{
    // Force the view (and label) to load.
    [self view];
    self.label.text = [NSString stringWithFormat:@"Page #%d", page];
    self.page = page;
    
    // TODO: Where do we actually want to translate this?
    int physicalPage = page;
    
    MTPDFPage *p = pdf.pdf.pages[physicalPage];
    // TODO: Calculate a good value for PixelsPerPoint, depending on the sizes of stuff.
    UIImage *image = [p imageWithPixelsPerPoint:2];
    
    UIImageView *view = (id)[self.view viewWithTag:47];
    if (!view)
    {
        view = [[UIImageView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = self.view.bounds;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.tag = 47;
        [self.view insertSubview:view atIndex:0];
    }
    view.image = image;
    //[self.view addSubview:view];
}



-(void)next
{
//    [self.p]
}

@end
