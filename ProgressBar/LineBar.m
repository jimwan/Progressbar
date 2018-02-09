//
//  LineBar.m
//  ProgressBar
//
//  Created by user on 09/02/2018.
//  Copyright © 2018 user. All rights reserved.
//

#import "LineBar.h"
#import <QuartzCore/QuartzCore.h>

@interface LineBar()

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float textFontSize;
@property (nonatomic, strong) NSColor *textFontColor;

@property (nonatomic, strong) NSColor *startColor;
@property (nonatomic, strong) NSColor *endColor;
@property (nonatomic, strong) NSColor *backStartColor;
@property (nonatomic, strong) NSColor *backEndColor;


@end

@implementation LineBar

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    self.wantsLayer = YES;

    

    
   
    // draw background
    NSBezierPath *backRectPath = [NSBezierPath bezierPath];
    [backRectPath moveToPoint:NSMakePoint(25, self.bounds.size.height/2)];
    [backRectPath lineToPoint:NSMakePoint(self.bounds.size.width-25, self.bounds.size.height/2)];
    

    CAShapeLayer *arcBack = [CAShapeLayer layer];
    arcBack.path = [self copyQuartzPathFromNSBezierPath:backRectPath];
    arcBack.fillColor = [NSColor clearColor].CGColor;
    arcBack.strokeColor = [NSColor purpleColor].CGColor;
    arcBack.lineWidth = _height;
    arcBack.lineJoin = kCALineJoinRound;
    arcBack.lineCap = kCALineCapRound;
    
    CAGradientLayer *gradientBackLayer = [CAGradientLayer layer];
    gradientBackLayer.frame = self.bounds;
    gradientBackLayer.colors = @[(__bridge id)_backStartColor.CGColor,(__bridge id)_backEndColor.CGColor ];
    [self.layer addSublayer:gradientBackLayer];
    gradientBackLayer.mask = arcBack;

    
    // draw progress
    NSBezierPath *rectPath = [NSBezierPath bezierPath];
    [rectPath moveToPoint:NSMakePoint(25, self.bounds.size.height/2)];
    [rectPath lineToPoint:NSMakePoint(self.bounds.size.width*_progress-25, self.bounds.size.height/2)];
    
    
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = [self copyQuartzPathFromNSBezierPath:rectPath];
    arc.fillColor = [NSColor clearColor].CGColor;
    arc.strokeColor = [NSColor purpleColor].CGColor;
    arc.lineWidth = _height;
    arc.lineJoin = kCALineJoinRound;
    arc.lineCap = kCALineCapRound;
    //arc.strokeEnd = _progress;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(__bridge id)_startColor.CGColor,(__bridge id)_endColor.CGColor ];
    [self.layer addSublayer:gradientLayer];
    gradientLayer.mask = arc;

    
    // draw percentage
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setFont:@"Helvetica-Neue"];
    [label setFontSize:_textFontSize];
    [label setFrame:NSMakeRect(self.bounds.size.width/2-100/2, 0, 100, 40)];
    [label setString:[NSString stringWithFormat:@"%d%%",(int)(_progress*100)]];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[_textFontColor CGColor]];
    [self.layer addSublayer:label];

    
}

- (CGPathRef)copyQuartzPathFromNSBezierPath:(NSBezierPath *)bezierPath
{
    NSInteger i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [bezierPath elementCount];
    if (numElements > 0) {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++) {
            switch ([bezierPath elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath) {
            CGPathCloseSubpath(path);
        }
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

@end
