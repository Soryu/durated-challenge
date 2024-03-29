//
//  UIColor+SER.h
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SER)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)brandColor;
+ (UIColor *)secondaryColor;

@end
