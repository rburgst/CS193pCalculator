//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Rainer Burgstaller on 30.06.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import "CalculatorBrain.h"
#import "math.h"

@interface CalculatorBrain () 

@property (nonatomic, strong) NSMutableArray *operandStack;

@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *) operandStack {
    if (!_operandStack) {
        _operandStack = [[NSMutableArray alloc] init];
    }
    return _operandStack;
}

- (double) popOperand {
    NSNumber *last = [self.operandStack lastObject];
    if (last != nil) {
        [self.operandStack removeLastObject];
    }
    return [last doubleValue];
}

- (void)pushOperand:(double)operand 
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double) performOperation:(NSString *)operation 
{
    double result = 0;
    if ([@"+" isEqualToString:operation]) {
        result = [self popOperand] + [self popOperand];
    } else if ([@"-" isEqualToString:operation]) {
        result = [self popOperand] - [self popOperand];
    } else if ([@"*" isEqualToString:operation]) {
        result = [self popOperand] * [self popOperand];
    } else if ([@"/" isEqualToString:operation]) {
        double o1 = [self popOperand];
        double o2 = [self popOperand];
        // protect against divide by zero
        if (o2 == 0) {
            result = 0;
        } else {
            result = o1 / o2;
        }
    } else if ([@"sqrt" isEqualToString:operation]) {
        result = sqrt([self popOperand]);
    } else if ([@"π" isEqualToString:operation]) {
        result = M_PI;
    } else if ([@"sin" isEqualToString:operation]) {
        result = sin([self popOperand]);
    } else if ([@"cos" isEqualToString:operation]) {
        result = cos([self popOperand]);
    } else if ([@"+/-" isEqualToString:operation]) {
        result = [self popOperand] * -1;
    }
    
    // push the result back up the stack
    [self pushOperand:result];
    
    return result;
}

- (void)clear {
    self.operandStack = nil;
}
@end
