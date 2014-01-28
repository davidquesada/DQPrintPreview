//
//  DQPrintPreviewViewController.m
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "DQPrintPreviewViewController.h"
#import "DQPrintPreviewContentViewController.h"
#import <QuartzCore/QuartzCore.h>

CGSize scaleSize(CGSize size, CGFloat scale)
{
    size.height *= scale;
    size.width *= scale;
    return size;
}

@interface DQPrintPreviewViewController ()
{
    MTPDF *_pdfRef;
}
@property DQPrintPreviewContentViewController *contentVC;
@property(readonly) CGFloat border;

-(void)animateChangeToOrientation:(Orientation)orientation duration:(CGFloat)duration;
@end

@implementation DQPrintPreviewViewController

-(void)loadView
{
    [super loadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:self action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resizeContentViewController];
}

-(void)setupView
{
    if (self.contentVC)
        return;
    
    // Load a default pdf.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"370D1" ofType:@"pdf"];
    MTPDF *pdf = [MTPDF PDFWithContentsOfFile:path];
    self.preview = [[Preview alloc] init];
    self.preview.pdf = pdf;
    
    self.preview.orientation = OrientationLandscape;
//    self.preview.orientation = OrientationPortrait;
    
    self.preview.sideStyle = SideStyleDoubleLongEdge;
//    self.preview.sideStyle = SideStyleDoubleShortEdge;

    [self createContentView];
    
    //CGRectMake(0, 0, 300, 300);
    
    
    [self reloadPreview];
}

-(void)createContentView
{
    self.contentVC = [[DQPrintPreviewContentViewController alloc] initWithPreview:self.preview];
    self.contentVC.view.frame = self.view.bounds;
    self.contentVC.view.frame = CGRectInset(self.contentVC.view.frame, 100, 100);
    UIView *view = self.contentVC.view;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 10;
    
    [self addChildViewController:self.contentVC];
    [self.view addSubview:self.contentVC.view];
}

-(void)reloadPreview
{
    self.contentVC.preview = self.preview;
    [self resizeContentViewController];
}

-(CGRect)eligibleContentRect
{
    CGRect rect = self.view.bounds;
    CGFloat border = [self border];
    rect = CGRectInset(rect, border, border);
    return rect;
}

-(void)resizeContentViewController
{
    CGSize size = self.preview.paperSize;
    
    if (self.preview.sideStyle == SideStyleDoubleLongEdge)
    {
        if (size.height > size.width)
            size.width *= 2;
        else
            size.height *= 2;
    } else if (self.preview.sideStyle == SideStyleDoubleShortEdge)
    {
        if (size.height > size.width)
            size.height *= 2;
        else
            size.width *= 2;
    }

    CGRect area = [self eligibleContentRect];
    CGFloat myRatio = area.size.height / area.size.width;
    CGFloat ratio = size.height / size.width;
    
    // If the paper is taller (/skinnier) than the container.
    if (ratio > myRatio)
    {
        size.width *= area.size.height / size.height;
        size.height = area.size.height;
    }
    
    // Else, the paper is wider (/shorter) than the container.
    else
    {
        size.height *= area.size.width / size.width;
        size.width = area.size.width;
    }
    
    // The midpoint of [self eligibleContentRect], relative to this view's frame.
    CGPoint midpoint = CGPointMake(area.size.width / 2 + area.origin.x, area.size.height / 2 + area.origin.y);
    
    CGRect frame;
    frame.size = size;
    frame.origin.x = midpoint.x - size.width / 2;
    frame.origin.y = midpoint.y - size.height / 2;
    
    self.contentVC.view.frame = frame;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        [self resizeContentViewController];
    }];
}

-(CGFloat)border
{
    return 40;
}

-(void)reload
{
    [self reloadPreview];
}

#pragma mark - 

-(void)animateChangeToOrientation:(Orientation)orientation duration:(CGFloat)duration
{
    DQPrintPreviewContentViewController *old = self.contentVC;
    int pageno = old.pageNumber;
    NSArray *views = [old.viewControllers valueForKey:@"view"];
    
    // Add a shadow to the individual pages, so the shadow is visible when the pages are animating.
    for (UIView *view in views)
    {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOpacity = 1.0;
        view.layer.shadowRadius = 10;
    }
    
    [old popoutViewControllers];

    self.preview.orientation = orientation;
    [self createContentView];
    [self resizeContentViewController];
    self.contentVC.pageNumber = pageno;
    
    self.contentVC.view.alpha = 0.0;
    
    
    [UIView animateWithDuration:duration animations:^{
        old.view.alpha = 0.0;
        int i = 0;
        for (UIViewController *controller in self.contentVC.viewControllers)
        {
            UIView *view = controller.view;
            CGRect frame = [self.view convertRect:view.bounds fromView:view];
            [views[i++] setFrame:frame];
        }
    } completion:^(BOOL finished) {
        [old.view removeFromSuperview];
        
        self.contentVC.view.alpha = 1.0;
        for (UIView *view in views)
            [view removeFromSuperview];
    }];
}

#pragma mark - Animatable Things.

-(void)setOrientation:(Orientation)orientation animated:(BOOL)animated
{
    if (orientation == self.preview.orientation)
        return;
    
    CGFloat duration = (animated ? .35 : 0.0);
    [self animateChangeToOrientation:orientation duration:duration];
}

#pragma mark - Crappy IBActions.

-(IBAction)setPortrait:(id)sender
{
    [self setOrientation:OrientationPortrait animated:YES];
}

-(IBAction)setLandscape:(id)sender
{
    [self setOrientation:OrientationLandscape animated:YES];
}

@end
