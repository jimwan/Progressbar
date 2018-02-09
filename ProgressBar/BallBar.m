//
//  BallBar.m
//  ProgressBar
//
//  Created by user on 09/02/2018.
//  Copyright © 2018 user. All rights reserved.
//

#import "BallBar.h"
#import <QuartzCore/QuartzCore.h>

@interface BallBar()

@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float progress;

@property (nonatomic, strong) NSColor *startColor;
@property (nonatomic, strong) NSColor *endColor;

@property (nonatomic, strong) NSColor *backStartColor;
@property (nonatomic, strong) NSColor *backEndColor;

@property (nonatomic, weak) IBOutlet NSTextField *percentage;

@property (nonatomic, assign) float textFontSize;
@property (nonatomic, strong) NSColor *textFontColor;

@end

@implementation BallBar

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    // draw background
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:_radius yRadius:_radius];

    
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = [self copyQuartzPathFromNSBezierPath:borderPath];
    backgroundLayer.fillColor = [NSColor grayColor].CGColor;
    backgroundLayer.strokeColor = [NSColor clearColor].CGColor;
    
    CAGradientLayer *gradientBackLayer = [CAGradientLayer layer];
    gradientBackLayer.frame = self.bounds;
    gradientBackLayer.colors = @[(__bridge id)_backStartColor.CGColor,(__bridge id)_backEndColor.CGColor ];
    gradientBackLayer.startPoint = NSMakePoint(0, 0);
    gradientBackLayer.endPoint = NSMakePoint(0, 1);
    gradientBackLayer.cornerRadius = _radius;
    gradientBackLayer.mask = backgroundLayer;
    [self.layer addSublayer:gradientBackLayer];
    
    
    // draw progress
    NSBezierPath *maskPath = [NSBezierPath bezierPathWithRect:NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height*_progress)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [self copyQuartzPathFromNSBezierPath:maskPath];


    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(__bridge id)_startColor.CGColor,(__bridge id)_endColor.CGColor ];
    gradientLayer.startPoint = NSMakePoint(0, 0);
    gradientLayer.endPoint = NSMakePoint(0, _progress);
    gradientLayer.cornerRadius = _radius;
    gradientLayer.mask = maskLayer;
    [self.layer addSublayer:gradientLayer];
    
    // draw percentage
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setFont:@"Helvetica-Neue"];
    [label setFontSize:_textFontSize];
    [label setFrame:NSMakeRect(self.bounds.size.width/2-80/2, self.bounds.size.height/2-40/2, 80, 40)];
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
