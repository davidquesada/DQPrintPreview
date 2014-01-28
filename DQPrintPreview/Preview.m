//
//  Preview.m
//  DQPrintPreview
//
//  Created by David Paul Quesada on 1/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Preview.h"

@interface Preview ()
{
    MTPDF *_pdf;
    Orientation _orientation;
    CGSize _paperSize;
}
@end

@implementation Preview

- (id)init
{
    self = [super init];
    if (self) {
        self.paperSize = CGSizeMake(8.5, 11);
    }
    return self;
}

-(MTPDF *)pdf
{
    return _pdf;
}

-(void)setPdf:(MTPDF *)pdf
{
    _pdf = pdf;
    self.pageCount = pdf.pages.count;
}

-(Orientation)orientation
{
    return _orientation;
}

-(void)setOrientation:(Orientation)orientation
{
    CGSize size = self.paperSize;
    CGFloat longer = MAX(size.width, size.height);
    CGFloat narrow = MIN(size.width, size.height);
    if (orientation == OrientationLandscape)
    {
        size.width = longer;
        size.height = narrow;
    }
    else
    {
        size.width = narrow;
        size.height = longer;
    }
    _paperSize = size;
    _orientation = orientation;
}

-(CGSize)paperSize
{
    return _paperSize;
}

-(void)setPaperSize:(CGSize)paperSize
{
    _paperSize = paperSize;
    if (paperSize.width > paperSize.height)
        _orientation = OrientationLandscape;
    else
        _orientation = OrientationPortrait;
}

@end
