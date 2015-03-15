//
//  UserInitialsView.h
//  Nokbox
//
//  Created by Herbert Siojo on 11/12/13.
//  Copyright (c) 2013 Herbert Siojo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInitialsView : UIView {
    NSString *_name;
    CGPoint _drawOffsetFromCenter;
}
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *textColor;

- (instancetype)initWithFrame:(CGRect)frame initials:(NSString *)initials fontSize:(int)fontSize drawOffsetFromCenter:(CGPoint)drawOffsetFromCenter;
- (instancetype)initWithFrame:(CGRect)frame initials:(NSString *)initials fontSize:(int)fontSize;

+ (NSString *)initialsForFirstName:(NSString *)firstName lastName:(NSString *)lastName;
@end