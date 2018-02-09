//
//  CircleBar.m
//  ProgressBar
//
//  Created by user on 09/02/2018.
//  Copyright © 2018 user. All rights reserved.
//

#import "CircleBar.h"
#import <QuartzCore/QuartzCore.h>

@interface CircleBar()

@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float progress;

@property (nonatomic, strong) NSColor *startColor;
@property (nonatomic, strong) NSColor *endColor;

@property (nonatomic, weak) IBOutlet NSTextField *percentage;

@end

@implementation CircleBar

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    self.wantsLayer = YES;

    int radius = _radius;

    NSRect outerRect = NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    NSBezierPath *outerPath = [NSBezierPath bezierPath];
    [outerPath appendBezierPathWithArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:radius startAngle:0 endAngle:0.1 clockwise:YES];

    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = [self copyQuartzPathFromNSBezierPath:outerPath];
    
//    arc.position = CGPointMake(CGRectGetMidX(self.bounds)-radius,
//                               CGRectGetMidY(self.bounds)-radius);
    
    arc.fillColor = [NSColor clearColor].CGColor;
    arc.strokeColor = [NSColor purpleColor].CGColor;
    arc.lineWidth = 20;
    arc.lineJoin = kCALineJoinRound;
    arc.lineCap = kCALineCapRound;
    arc.strokeEnd = _progress;

    _percentage.stringValue = [NSString stringWithFormat:@"%d%%",(int)(_progress*100)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = outerRect;
    gradientLayer.colors = @[(__bridge id)_startColor.CGColor,(__bridge id)_endColor.CGColor ];
//    gradientLayer.startPoint = CGPointMake(0,0.5);
//    gradientLayer.endPoint = CGPointMake(1,0.5);
    
    [self.layer addSublayer:gradientLayer];
    //Using arc as a mask instead of adding it as a sublayer.
    //[self.view.layer addSublayer:arc];
    gradientLayer.mask = arc;

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
