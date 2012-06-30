//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Rainer Burgstaller on 30.06.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clear;

@end
