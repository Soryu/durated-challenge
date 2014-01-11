//
//  UIColor+SER.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "UIColor+SER.h"

@implementation UIColor (SER)

// http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor
+ (UIColor *)colorFromHexString:(NSString *)hexString
{
  NSAssert(hexString != nil, @"string must not be nil");
  NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
  if([cleanString length] == 3) {
    cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
  }
  if([cleanString length] == 6) {
    cleanString = [cleanString stringByAppendingString:@"ff"];
  }
  
  unsigned int baseValue;
  [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
  
  float red = ((baseValue >> 24) & 0xFF)/255.0f;
  float green = ((baseValue >> 16) & 0xFF)/255.0f;
  float blue = ((baseValue >> 8) & 0xFF)/255.0f;
  float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
  
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
