//
//  CalculatorView.m
//  Calculator
//
//  Created by Rainer Burgstaller on 14.07.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define MAX_SCALE 100.0


@interface GraphView()
-(void) pinch:(UIPinchGestureRecognizer*)sender;
-(void) pan:(UIPanGestureRecognizer*)sender;

@property(nonatomic,strong) NSString* scaleName;
@property(nonatomic,strong) NSString* originXName;
@property(nonatomic,strong) NSString* originYName;

@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize datasource = _datasource;
@synthesize defaultsPrefix = _defaultsPrefix;
@synthesize scaleName = _scaleName;
@synthesize originXName = _originXName;
@synthesize originYName = _originYName;
@synthesize useDots = _useDots;


#define DEFAULTS_SCALE @"_scale"
#define DEFAULTS_ORIGIN_X @"_originX"
#define DEFAULTS_ORIGIN_Y @"_originY"

- (NSString*)makeKeyName:(NSString*) postfix {
    return [self.defaultsPrefix stringByAppendingString:postfix];
}

- (void) loadFromDefaults {
    CGPoint newOrigin;
    
    if (!self.defaultsPrefix) {
        self.defaultsPrefix = @"graphview";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float oldScale = 0;
    if (self.scaleName) oldScale = [defaults floatForKey:self.scaleName];
    if (oldScale == 0) oldScale = 10.0;

    self.scale = oldScale;
    newOrigin.x = self.originXName ? [defaults floatForKey:self.originXName] : 0;
    newOrigin.y = self.originYName ? [defaults floatForKey:self.originYName] : 0;
    
    if (newOrigin.x == 0 && newOrigin.y == 0) {
        newOrigin.x = self.bounds.origin.x + self.bounds.size.width / 2;
        newOrigin.y = self.bounds.origin.y + self.bounds.size.height / 2;
    }
    self.origin = newOrigin;
}

- (void) setup {
    [self loadFromDefaults];
    [self addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setDefaultsPrefix:(NSString *)defaultsPrefix {
    if (_defaultsPrefix != defaultsPrefix) {
        _defaultsPrefix = defaultsPrefix;
        self.scaleName = [defaultsPrefix stringByAppendingString:DEFAULTS_SCALE];
        self.originXName = [defaultsPrefix stringByAppendingString:DEFAULTS_ORIGIN_X];
        self.originYName = [defaultsPrefix stringByAppendingString:DEFAULTS_ORIGIN_Y];
        [self loadFromDefaults];
    }
}
- (void)setScale:(float)scale {
    if (_scale != scale) {
        _scale = scale;
        _scale = MIN(MAX_SCALE, _scale);
        _scale = MAX(0.0f, _scale);
        [self setNeedsDisplay];
        [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:self.scaleName];
    }
}

- (void) setOrigin:(CGPoint)origin {
    if (origin.x != self.origin.x || origin.y != self.origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:origin.x forKey:self.originXName];
        [defaults setFloat:origin.y forKey:self.originYName];
    }
}

- (void)setUseDots:(BOOL)useDots {
    if (_useDots != useDots) {
        _useDots = useDots;
        [self setNeedsDisplay];
    }
}

- (float) viewXToModel:(float)viewValue {
    float result = (viewValue - self.origin.x) / self.scale;
    return result;
}

- (float) modelToViewY:(float)modelY {
    // y positive is up
    return self.origin.y - (modelY * self.scale);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    int radius = 2;
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    // draw the axes
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];

    // check that we have a data source
    if (!self.datasource) return;
    
    int startX = self.bounds.origin.x;
    int endX = self.bounds.origin.x + self.bounds.size.width;
    int minY = self.bounds.origin.y;
    int maxY = minY + self.bounds.size.height;
    float pixelSize = self.contentScaleFactor;
    
    [[UIColor blueColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextBeginPath(context);
    BOOL first = YES;
    
    for (float viewX = startX; viewX < endX; viewX += pixelSize) {
        float modelX = [self viewXToModel:viewX];
        float y = [self.datasource yValue:self forX:modelX];
        float viewY = [self modelToViewY:y];

        if (viewY < minY || viewY > maxY) {
            continue;
        }
        if (self.useDots) {
            CGRect rect = CGRectMake(viewX - radius, viewY - radius, 2*radius, 2*radius);
            CGContextFillEllipseInRect(context, rect);
        } else {
            if (first) {
                first = NO;
                CGContextMoveToPoint(context, viewX, viewY);
            } else {
                CGContextAddLineToPoint(context, viewX, viewY);
            }
        }
    }
    if (!self.useDots) CGContextStrokePath(context);        
}

-(void) pinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        self.scale *= sender.scale;
        sender.scale = 1;
    }
}

-(void) pan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [sender translationInView:self];
        CGPoint curTranslation = self.origin;
        curTranslation.x += translation.x;
        curTranslation.y += translation.y;
        self.origin = curTranslation;
        [sender setTranslation:CGPointZero inView:self];
    }    
}

@end
