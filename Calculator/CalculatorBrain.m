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

+ (NSOrderedSet*)operations {
    static NSOrderedSet *sOperations;
    if (!sOperations) {
        sOperations = [[NSOrderedSet alloc] initWithObjects:@"π", @"+/-", @"ℯ", @"sin", @"cos", @"log", @"sqrt", @"*", @"/", @"+", @"-", nil];
    }
    return sOperations;
}

+ (NSSet *)functions {
    static NSSet *_functions;
    if (!_functions) _functions = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"log", @"sqrt", nil];
    return _functions;
}

+ (NSSet *)noOperandFunctions {
    static NSSet *_nfunctions;
    if (!_nfunctions) _nfunctions = [[NSSet alloc] initWithObjects:@"π", @"ℯ", nil];
    return _nfunctions;    
}

+ (BOOL)isNoOperandFunction:(id)element {
    return [[self noOperandFunctions] containsObject:element];
}

+ (BOOL)isFunction:(id)element {
    return [[self functions] containsObject:element];
}

+ (BOOL)isOperation:(id)element {
    return [[self operations] containsObject:element];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (void)pushOperand:(double)operand 
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (id)popTopOff {
    id topOfStack = [self.programStack lastObject];
    if (topOfStack) [self.programStack removeLastObject];
    return topOfStack;
}

- (id) program {
    return [self.programStack copy];
}

- (id)performOperation:(NSString *)operation 
{
    [self.programStack addObject:operation];
    
    return [self.class runProgram:self.programStack];
}

// if the top thing on the passed stack is an operand, return it
// if the top thing on the passed stack is an operation, evaluate it (recursively)
// does not crash (but returns 0) if stack contains objects other than NSNumber or NSString

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    } else {
        return @"Missing operand";
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        if ([self isOperation:topOfStack]) {
            NSString *operation = topOfStack;
            
            if ([@"π" isEqualToString:operation]) {
                result = M_PI;
            } else {
                // all programs require a single operand or more
                id op1 = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
                
                if (!op1) return @"Missing operand";
                double o1 = 0;
                // check for errors in the inner operation for errors
                if ([op1 isKindOfClass:[NSString class]]) return op1;
                
                o1 = [op1 doubleValue];
                
                if ([@"ℯ" isEqualToString:operation]) {
                    result = exp(o1);
                } else if ([@"sqrt" isEqualToString:operation]) {
                    if (o1 < 0) return @"sqrt from negative number";
                    result = sqrt(o1);
                } else if ([@"sin" isEqualToString:operation]) {
                    result = sin(o1);
                } else if ([@"cos" isEqualToString:operation]) {
                    result = cos(o1);
                } else if ([@"+/-" isEqualToString:operation]) {
                    result = o1 * -1;
                } else if ([@"log" isEqualToString:operation]) {
                    if (o1 < 0) {
                        return @"log from neg. number";
                    }
                    result = log(o1);
                } else {
                    // all following operations require 2 operands
                    id op2 = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
                    if (!op2) return @"Missing operand";
                    double o2 = 0;
                    // check for errors in the inner operation for errors
                    if ([op2 isKindOfClass:[NSString class]]) return op2;
                    
                    o2 = [op2 doubleValue];
                    
                    // now all of these require 2 operands
                    if ([@"+" isEqualToString:operation]) {
                        result = o2 + o1;
                    } else if ([@"-" isEqualToString:operation]) {
                        result = o2 - o1;
                    } else if ([@"*" isEqualToString:operation]) {
                        result = o2 * o1;
                    } else if ([@"/" isEqualToString:operation]) {
                        // protect against divide by zero
                        if (o1 == 0) {
                            return @"Div by Zero";
                        } else {
                            result = o2 / o1;
                        }
                    }
                }
            }
        } else {
            // variable case
            result = [[variableValues objectForKey:topOfStack] doubleValue];
        }
    }
    
    return [NSNumber numberWithDouble:result];
}

+ (void) pushToProgram:(NSMutableArray *)stack object:(id)obj {
    [stack addObject:obj];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    if ([topOfStack isKindOfClass:[NSNumber class]]) return [topOfStack description];
    else if ([self isNoOperandFunction:topOfStack]) {
        return topOfStack;
    } else if ([self isFunction:topOfStack]) {
        return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack]];
    } else if ([self isOperation:topOfStack]) {
        id peekLeft = [stack lastObject];
        NSString *o2 = [self descriptionOfTopOfStack:stack];
        id peekRight = [stack lastObject];
        NSString *o1 = [self descriptionOfTopOfStack:stack];
        NSUInteger leftIndex = [[self operations] indexOfObject:peekLeft];
        NSUInteger rightIndex = [[self operations] indexOfObject:peekRight];
        NSUInteger curIndex = [[self operations] indexOfObject:topOfStack];
        if (leftIndex != NSNotFound && curIndex < leftIndex) {
            // left needs braces
            o2 = [NSString stringWithFormat:@"(%@)", o2];
        }
        if (rightIndex != NSNotFound && curIndex < rightIndex) {
            o1 = [NSString stringWithFormat:@"(%@)", o1];
        }

        NSString *result = [NSString stringWithFormat:@"%@ %@ %@", o1, topOfStack, o2];
        return result;
    } else if (topOfStack) {
        // a variable
        return topOfStack;
    } else {
        return @"";
    }
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray* stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSString *result = [self descriptionOfTopOfStack:stack];
    while ([stack count] > 0) {
        result = [NSString stringWithFormat:@"%@, %@", result, [self descriptionOfTopOfStack:stack]];
    }
    return result;
}

+ (NSString *) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self.class popOperandOffProgramStack:stack usingVariableValues:variableValues];
}

+ (NSString *)runProgram:(id)program {
    return [self runProgram:program usingVariableValues:nil];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *result;
    
    if (![program isKindOfClass:NSArray.class]) {
        return nil;
    }
    for (id elem in program) {
        if ([elem isKindOfClass:[NSString class]] && ![[self operations] containsObject:elem]) {
            // lazy alloc the result container
            if (!result) result = [[NSMutableSet alloc] init];
            
            [result addObject:elem];
        }
    }
    return result;
}

- (void)clear {
    self.programStack = nil;
}
@end
