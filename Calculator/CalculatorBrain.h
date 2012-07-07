//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Rainer Burgstaller on 30.06.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushVariable:(NSString *)variable;
- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clear;


// returns an object of unspecified class which
// represents the sequence of operands and operations
// since last clear
@property (nonatomic, readonly) id program;

// a string representing (to an end user) the passed program
// (programs are obtained from the program @property of a CalculatorBrain instance)
+ (NSString *)descriptionOfProgram:(id)program;

// runs the program (obtained from the program @property of a CalculatorBrain instance)
// if the last thing done in the program was pushOperand:, this returns that operand
// if the last thing done in the program was performOperation:, this evaluates it (recursively)
+ (double)runProgram:(id)program;

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

+ (NSSet *)variablesUsedInProgram:(id)program;

// Pops the top off the current program 
- (id)popTopOff;
@end
