//
//  UserInitialsView.m
//  Nokbox
//
//  Created by Herbert Siojo on 11/12/13.
//  Copyright (c) 2013 Herbert Siojo. All rights reserved.
//

#import "UserInitialsView.h"
//#import "ThemeManager.h"

@interface UserInitialsView () {
    NSString *_initials;
    UIFont *_font;
    CGSize _sizeInitials;
}
@end

@implementation UserInitialsView

@synthesize fillColor, textColor;

- (instancetype)initWithFrame:(CGRect)frame initials:(NSString *)initials font:(UIFont *)font drawOffsetFromCenter:(CGPoint)drawOffsetFromCenter {
    self = [super initWithFrame:frame];
    if (self) {
        _initials = initials;
        _font = font;
        _drawOffsetFromCenter = drawOffsetFromCenter;

        self.fillColor = [UIColor colorWithRed:184/255.0f green:213/255.0f blue:32/255.0f alpha:1.0f];
        //[ThemeManager sharedManager].colorLightGray;
        self.textColor = [UIColor colorWithRed:255/255.0f green:256/255.0f blue:255/255.0f alpha:1.0f];
        // [ThemeManager sharedManager].colorDarkGray;
        
        _sizeInitials = [_initials sizeWithAttributes:@{NSFontAttributeName: _font}];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame initials:(NSString *)initials fontSize:(int)fontSize drawOffsetFromCenter:(CGPoint)drawOffsetFromCenter {
    UIFont *font = [UIFont boldSystemFontOfSize:12.0];
    // [UIFont fontWithName:[ThemeManager sharedManager].fontLightName size:fontSize];
    return [self initWithFrame:frame initials:initials font:font drawOffsetFromCenter:drawOffsetFromCenter];
}

- (instancetype)initWithFrame:(CGRect)frame initials:(NSString *)initials fontSize:(int)fontSize {
    UIFont *font = [UIFont boldSystemFontOfSize:12.0];
    // [UIFont fontWithName:[ThemeManager sharedManager].fontLightName size:fontSize];
    return [self initWithFrame:frame initials:initials font:font drawOffsetFromCenter:CGPointZero];
}

+ (NSString *)initialsForFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    NSMutableArray *initials = [NSMutableArray arrayWithCapacity:2];
    if(firstName.length > 0) {
        NSString *firstInitial = [[firstName substringToIndex:1] uppercaseString];
        [initials addObject:firstInitial];
    }
    if(lastName.length > 0) {
        NSString *lastInitial = [[lastName substringToIndex:1] uppercaseString];
        [initials addObject:lastInitial];
    }
    return [initials componentsJoinedByString:@""];
}

- (void)drawRect:(CGRect)rect {
    // Draw a circle
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect circleRect = CGRectInset(rect, 5, 5);
    CGContextAddEllipseInRect(ctx, circleRect);
    CGContextSetFillColor(ctx, CGColorGetComponents(self.fillColor.CGColor));
    CGContextFillPath(ctx);
    
    CGPoint point;
    point.x = CGRectGetMidX(rect) - _sizeInitials.width / 2;
    point.x += _drawOffsetFromCenter.x;
    point.y = CGRectGetMidY(rect) - _sizeInitials.height / 2;
    point.y += _drawOffsetFromCenter.y;

        NSDictionary *attribs = @{NSFontAttributeName : _font, NSForegroundColorAttributeName : self.textColor};
        [_initials drawAtPoint:point withAttributes:attribs];
}
@end