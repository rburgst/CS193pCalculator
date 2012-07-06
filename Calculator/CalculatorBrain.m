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
        sOperations = [[NSOrderedSet alloc] initWithObjects:@"π", @"ℯ", @"sin", @"cos", @"log", @"sqrt", @"*", @"/", @"+", @"-", nil];
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

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
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

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        if ([self.operations containsObject:topOfStack]) {
            NSString *operation = topOfStack;
            
            if ([@"+" isEqualToString:operation]) {
                result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] + [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            } else if ([@"-" isEqualToString:operation]) {
                result = - [self popOperandOffProgramStack:stack usingVariableValues:variableValues] + [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            } else if ([@"*" isEqualToString:operation]) {
                result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] * [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            } else if ([@"/" isEqualToString:operation]) {
                double o1 = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
                double o2 = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
                // protect against divide by zero
                if (o1 == 0) {
                    result = 0;
                } else {
                    result = o2 / o1;
                }
            } else if ([@"sqrt" isEqualToString:operation]) {
                result = sqrt([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            } else if ([@"π" isEqualToString:operation]) {
                result = M_PI;
            } else if ([@"sin" isEqualToString:operation]) {
                result = sin([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            } else if ([@"cos" isEqualToString:operation]) {
                result = cos([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            } else if ([@"+/-" isEqualToString:operation]) {
                result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] * -1;
            } else if ([@"log" isEqualToString:operation]) {
                result = log([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            } else if ([@"ℯ" isEqualToString:operation]) {
                result = exp([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            }
        } else {
            // variable case
            result = [[variableValues objectForKey:topOfStack] doubleValue];
        }
    }
    
    return result;
}



+ (id)popFromProgram:(NSMutableArray *)stack {
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    return topOfStack;
}

+ (void) pushToProgram:(NSMutableArray *)stack object:(id)obj {
    [stack addObject:obj];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    if ([topOfStack isKindOfClass:[NSNumber class]]) return [topOfStack description];
    else if ([[self noOperandFunctions] containsObject:topOfStack]) {
            return topOfStack;
    } else if ([[self functions] containsObject:topOfStack]) {
        return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack]];
    } else if ([[self operations] containsObject:topOfStack]) {
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

+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self.class popOperandOffProgramStack:stack usingVariableValues:variableValues];
}

+ (double)runProgram:(id)program {
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
