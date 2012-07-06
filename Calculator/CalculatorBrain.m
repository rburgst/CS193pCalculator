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

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *) programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand 
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (id) program {
    return [self.programStack copy];
}

- (double) performOperation:(NSString *)operation 
{
    [self.programStack addObject:operation];
    
    return [self.class runProgram:self.programStack];
}

// if the top thing on the passed stack is an operand, return it
// if the top thing on the passed stack is an operation, evaluate it (recursively)
// does not crash (but returns 0) if stack contains objects other than NSNumber or NSString

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([@"+" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"-" isEqualToString:operation]) {
            result = - [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([@"/" isEqualToString:operation]) {
            double o1 = [self popOperandOffProgramStack:stack];
            double o2 = [self popOperandOffProgramStack:stack];
            // protect against divide by zero
            if (o1 == 0) {
                result = 0;
            } else {
                result = o2 / o1;
            }
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([@"+/-" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * -1;
        } else if ([@"log" isEqualToString:operation]) {
            result = log([self popOperandOffProgramStack:stack]);
        } else if ([@"ℯ" isEqualToString:operation]) {
            result = exp([self popOperandOffProgramStack:stack]);
        }
    }
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    return @"TODO";
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self.class popOperandOffProgramStack:stack];
}

- (void)clear {
    self.programStack = nil;
}
@end
