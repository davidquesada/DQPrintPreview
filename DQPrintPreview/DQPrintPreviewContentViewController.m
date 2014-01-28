//
//  DQPrintPreviewContentViewController.m
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "DQPrintPreviewContentViewController.h"
#import "DQPrintPreviewPageViewController.h"

@interface UIViewController (Duh)
-(UIView *)duplicateContentView;
@end
@implementation UIViewController (Duh)

-(UIView *)duplicateContentView
{
    return [[UIView alloc] init];
}

@end

@interface DQPrintPreviewContentViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    Preview *_preview;
    UIViewController *_blankController;
    UIViewController *_blankPostController;
}
@end

@implementation DQPrintPreviewContentViewController

-(instancetype)initWithPreview:(Preview *)preview
{
    NSMutableDictionary *ops = [[NSMutableDictionary alloc] init];
    if (preview.sideStyle == SideStyleSingle)
        ops[UIPageViewControllerOptionSpineLocationKey] = @(UIPageViewControllerSpineLocationMin);
    else
        ops[UIPageViewControllerOptionSpineLocationKey] = @(UIPageViewControllerSpineLocationMid);

    UIPageViewControllerNavigationOrientation orientation;
    BOOL isHorizontal = NO;
    
    if (preview.sideStyle == SideStyleSingle)
        isHorizontal = YES;
    else if (preview.sideStyle == SideStyleDoubleLongEdge)
        isHorizontal = (preview.paperSize.height > preview.paperSize.width);
    else if (preview.sideStyle == SideStyleDoubleShortEdge)
        isHorizontal = (preview.paperSize.height < preview.paperSize.width);
    
    if (isHorizontal)
        orientation = UIPageViewControllerNavigationOrientationHorizontal;
    else
        orientation = UIPageViewControllerNavigationOrientationVertical;
    
    self = [self initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:orientation options:ops];
    if (self)
    {
        self.doubleSided = (preview.sideStyle != SideStyleSingle);
        self.delegate = self;
        self.dataSource = self;
        _preview = preview;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    id arr = @[ [self controllerForPage:0] ];
    
    if (self.spineLocation == UIPageViewControllerSpineLocationMid)
        arr = @[ [self blankController], arr[0]];
//        arr = [arr arrayByAddingObject:[self controllerForPage:1]];
    
    [self setViewControllers:arr direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(void)showVirtualPage:(int)page
{
    if (!self.doubleSided)
        [self setViewControllers:@[[self controllerForPage:page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(Preview *)preview
{
    return _preview;
}

-(void)setPreview:(Preview *)preview
{
    _preview = preview;
    [self showVirtualPage:0];
}

-(void)clearViewControllers
{
    id arr = @[[[UIViewController alloc] init] ];
    if (self.spineLocation == UIPageViewControllerSpineLocationMid)
        arr = [arr arrayByAddingObject:[[UIViewController alloc] init]];
    [self setViewControllers:arr direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(void)popoutViewControllers
{
    UIView *superview = self.view.superview;
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    NSArray *controllers = self.viewControllers;
    
    for (UIViewController *controller in self.viewControllers)
    {
        UIView *view = controller.view;
        CGRect frame = [superview convertRect:view.bounds fromView:view];
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    [self clearViewControllers];
    int i = 0;
    for (UIViewController *controller in controllers)
    {
        UIView *view = controller.view;
        [view removeFromSuperview];
        [controller willMoveToParentViewController:self.parentViewController];
        
        view.frame = [frames[i++] CGRectValue];
        [superview addSubview:view];
    }
}

-(int)pageNumber
{
    if (self.viewControllers[0] == [self blankController])
        return -1;
    DQPrintPreviewPageViewController *pagevc = self.viewControllers[0];
    return pagevc.page;
}

-(void)setPageNumber:(int)num
{
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    if (num == -1)
        [vcs addObject:[self blankController]];
    else
        [vcs addObject:[self controllerForPage:num]];
    
    if (self.spineLocation == UIPageViewControllerSpineLocationMid)
        [vcs addObject:[self controllerForPage:(num + 1)]];
    
    [self setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

/*
 The page passed to this function should be a virtual page.
 i.e. If the user wants to print pages 10,20-25, then virtual page 0 = physical page 10, virtual page 1 = physical page 20, etc...
 */
-(UIViewController *)controllerForPage:(int)page
{
    if (page >= self.preview.pageCount)
        return [self blankPostController];
    
    DQPrintPreviewPageViewController *controller = [[DQPrintPreviewPageViewController alloc] init];
    [controller setPDF:self.preview virtualPage:page];
    return controller;
}

-(UIViewController *)blankController
{
    if (!_blankController)
        _blankController = [[UIViewController alloc] init];
    return _blankController;
}

-(UIViewController *)blankPostController
{
    if (!_blankPostController)
    {
        _blankPostController = [[UIViewController alloc] init];
    }
    return _blankPostController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(DQPrintPreviewPageViewController *)viewController
{
    if (viewController == [self blankPostController])
        return nil;
    
    //TODO: Determine the number of pages in the preview and stop from overflowing on the end.
    return [self controllerForPage:viewController.page + 1];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(DQPrintPreviewPageViewController *)viewController
{
    if (viewController == [self blankPostController])
        return [self controllerForPage:(self.preview.pageCount - 1)];
    // If we are looking at the blank page at the beginning, return nil.
    if (![viewController respondsToSelector:@selector(page)])
        return nil;
    
    if (viewController.page == 0)
    {
        if (self.spineLocation == UIPageViewControllerSpineLocationMid)
            return [self blankController];
        else
            return nil;
    }
    return [self controllerForPage:viewController.page - 1];
}

@end
